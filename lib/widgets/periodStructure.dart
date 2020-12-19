import 'package:flutter/material.dart';

class Period extends StatelessWidget {
  Period(
      {Key key, this.period, this.index, this.changePeriod, this.deletePeriod})
      : super(key: key);

  final period;
  final index;
  final Function changePeriod;
  final Function deletePeriod;

  String getStart(BuildContext context) {
    TimeOfDay startTime =
        TimeOfDay.fromDateTime(DateTime.parse(period["start"]));
    return startTime.format(context);
  }

  String getEnd(BuildContext context) {
    TimeOfDay endTime = TimeOfDay.fromDateTime(DateTime.parse(period["end"]));
    return endTime.format(context);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(top: 5, right: 20, bottom: 5, left: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        padding: EdgeInsets.all(10),
        child: ListTile(
          trailing: InkWell(
            onTap: () => deletePeriod(index),
            child: Icon(Icons.delete),
          ),
          title: Container(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              "Period ${index + 1}",
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
          ),
          subtitle: Row(
            children: <Widget>[
              InkWell(
                borderRadius: BorderRadius.circular(5),
                onTap: () => changePeriod(index, true, context),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Theme.of(context)
                        .scaffoldBackgroundColor
                        .withOpacity(0.7),
                  ),
                  padding: EdgeInsets.all(7),
                  child: Row(
                    children: [
                      Text(
                        getStart(context),
                      ),
                      SizedBox(width: 10),
                      Icon(
                        Icons.edit,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: Text("to")),
              InkWell(
                borderRadius: BorderRadius.circular(5),
                onTap: () => changePeriod(index, false, context),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Theme.of(context)
                        .scaffoldBackgroundColor
                        .withOpacity(0.7),
                  ),
                  padding: EdgeInsets.all(7),
                  child: Row(
                    children: [
                      Text(
                        getEnd(context),
                      ),
                      SizedBox(width: 10),
                      Icon(
                        Icons.edit,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PeriodStructure extends StatefulWidget {
  final List periodStructure;
  final Function updatePeriod;
  final Widget pageNavigationButtons;

  PeriodStructure(
      {Key key,
      this.periodStructure,
      this.updatePeriod,
      this.pageNavigationButtons})
      : super(key: key);

  @override
  PeriodStructureState createState() => PeriodStructureState();
}

class PeriodStructureState extends State<PeriodStructure> {
  TimeOfDay currentStartTime;
  TimeOfDay currentEndTime;

  void _addPeriod(TimeOfDay startTime, TimeOfDay endTime) {
    DateTime now = DateTime.now();
    String start = new DateTime(
            now.year, now.month, now.day, startTime.hour, startTime.minute)
        .toIso8601String();
    String end =
        new DateTime(now.year, now.month, now.day, endTime.hour, endTime.minute)
            .toIso8601String();

    List newList = List.from(widget.periodStructure)
      ..add({"start": start, "end": end});
    widget.updatePeriod(newList);
  }

  void _changeNewPeriod({bool start, BuildContext context}) async {
    TimeOfDay t = await showTimePicker(
      initialTime: start ? currentStartTime : currentEndTime,
      context: context,
    );
    if (t != null) {
      if (start) {
        DateTime now = new DateTime.now();

        setState(() {
          currentStartTime = t;
          currentEndTime = new TimeOfDay.fromDateTime(
              new DateTime(now.year, now.month, now.day, t.hour, t.minute)
                  .add(new Duration(minutes: 60)));
        });
      } else {
        setState(() {
          currentEndTime = t;
        });
      }
    }
  }

  void _deletePeriod(int index) {
    List newList = List.from(widget.periodStructure)..removeAt(index);
    widget.updatePeriod(newList);
  }

  void _changePeriod(int index, bool start, BuildContext context) async {
    TimeOfDay t = await showTimePicker(
      initialTime: start
          ? TimeOfDay.fromDateTime(
              DateTime.parse(widget.periodStructure[index]["start"]))
          : TimeOfDay.fromDateTime(
              DateTime.parse(widget.periodStructure[index]["end"])),
      context: context,
    );

    if (t != null) {
      final now = new DateTime.now();
      String selectedTime =
          new DateTime(now.year, now.month, now.day, t.hour, t.minute)
              .toIso8601String();

      List newList = List.from(widget.periodStructure);
      newList[index] = {
        "start": start == true ? selectedTime : newList[index]["start"],
        "end": start == false ? selectedTime : newList[index]["end"]
      };

      widget.updatePeriod(newList);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                  top: 20.0, bottom: 20.0, left: 20.0, right: 20.0),
              child: Text(
                "Setup Periods",
                style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Container(
                constraints: BoxConstraints(maxWidth: 500),
                child: ListView(
                  scrollDirection: Axis.vertical,
                  children: widget.periodStructure
                      .asMap()
                      .entries
                      .map(
                        (period) => Period(
                            period: period.value,
                            index: period.key,
                            changePeriod: _changePeriod,
                            deletePeriod: _deletePeriod),
                      )
                      .toList(),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
              width: double.infinity,
              constraints: BoxConstraints(maxWidth: 500),
              child: RaisedButton(
                child: Text("New Period"),
                onPressed: () => _periodSheet(
                  context,
                  widget.periodStructure.isEmpty
                      ? DateTime.now().toIso8601String()
                      : widget.periodStructure.last["end"],
                ),
              ),
            ),
            widget.pageNavigationButtons,
          ],
        ),
      ),
    );
  }

  _periodSheet(BuildContext context, previousEnd) {
    setState(() {
      currentStartTime =
          new TimeOfDay.fromDateTime(DateTime.parse(previousEnd));
      currentEndTime = new TimeOfDay.fromDateTime(
          DateTime.parse(previousEnd).add(new Duration(hours: 1)));
    });

    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusScope.of(context).unfocus(),
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        width: 30,
                        height: 5,
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(5),
                            color: Theme.of(context).splashColor),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        top: 25,
                        right: 20,
                        left: 20,
                        bottom: MediaQuery.of(context).viewInsets.bottom + 20),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.all(10),
                            child: Text(
                              "Add Period",
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 10,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  borderRadius: BorderRadius.circular(5),
                                  onTap: () => _changeNewPeriod(
                                      start: true, context: context),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.9),
                                    ),
                                    padding: EdgeInsets.all(7),
                                    child: Row(
                                      children: [
                                        Text(
                                          currentStartTime.format(context),
                                        ),
                                        SizedBox(width: 10),
                                        Icon(
                                          Icons.edit,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(child: Text("to")),
                                InkWell(
                                  borderRadius: BorderRadius.circular(5),
                                  onTap: () => _changeNewPeriod(
                                      start: false, context: context),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.9),
                                    ),
                                    padding: EdgeInsets.all(7),
                                    child: Row(
                                      children: [
                                        Text(
                                          currentEndTime.format(context),
                                        ),
                                        SizedBox(width: 10),
                                        Icon(
                                          Icons.edit,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          RaisedButton(
                            child: Text("Add"),
                            onPressed: () {
                              _addPeriod(currentStartTime, currentEndTime);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
