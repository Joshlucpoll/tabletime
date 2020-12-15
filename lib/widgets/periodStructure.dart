import 'package:flutter/material.dart';

import '../widgets/newPeriodDialog.dart';

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
                borderRadius: BorderRadius.circular(10),
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

class PeriodStructure extends StatelessWidget {
  final List periodStructure;
  final Function updatePeriod;
  final Widget pageNavigationButtons;

  PeriodStructure(
      {Key key,
      this.periodStructure,
      this.updatePeriod,
      this.pageNavigationButtons})
      : super(key: key);

  void _addPeriod(TimeOfDay startTime, TimeOfDay endTime) {
    DateTime now = DateTime.now();
    String start = new DateTime(
            now.year, now.month, now.day, startTime.hour, startTime.minute)
        .toIso8601String();
    String end =
        new DateTime(now.year, now.month, now.day, endTime.hour, endTime.minute)
            .toIso8601String();

    List newList = List.from(periodStructure)
      ..add({"start": start, "end": end});
    updatePeriod(newList);
  }

  void _deletePeriod(int index) {
    List newList = List.from(periodStructure)..removeAt(index);
    updatePeriod(newList);
  }

  void _changePeriod(int index, bool start, BuildContext context) async {
    TimeOfDay t = await showTimePicker(
      initialTime: start
          ? TimeOfDay.fromDateTime(
              DateTime.parse(periodStructure[index]["start"]))
          : TimeOfDay.fromDateTime(
              DateTime.parse(periodStructure[index]["end"])),
      context: context,
    );

    if (t != null) {
      final now = new DateTime.now();
      String selectedTime =
          new DateTime(now.year, now.month, now.day, t.hour, t.minute)
              .toIso8601String();

      List newList = List.from(periodStructure);
      newList[index] = {
        "start": start == true ? selectedTime : newList[index]["start"],
        "end": start == false ? selectedTime : newList[index]["end"]
      };

      updatePeriod(newList);
    }
  }

  // make this a draggable scrollable sheet
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
                  children: periodStructure
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
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) {
                    return NewPeriodDialog(
                      addPeriod: _addPeriod,
                      previousEnd: periodStructure.isEmpty
                          ? DateTime.now().toIso8601String()
                          : periodStructure.last["end"],
                    );
                  },
                ),
              ),
            ),
            pageNavigationButtons,
          ],
        ),
      ),
    );
  }
}
