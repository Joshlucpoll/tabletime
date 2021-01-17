import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

// Widgets
import 'package:timetable/screens/loading.dart';

// Services
import '../../services/database.dart';

class Period extends StatelessWidget {
  Period({
    Key key,
    this.period,
    this.index,
    this.changePeriod,
    this.deletePeriod,
  }) : super(key: key);

  final period;
  final index;
  final Function changePeriod;
  final Function deletePeriod;

  String getStart(BuildContext context) {
    final DateFormat formatter = DateFormat.Hm();
    return formatter.format(DateTime.parse(period["start"]));
  }

  String getEnd(BuildContext context) {
    final DateFormat formatter = DateFormat.Hm();
    return formatter.format(DateTime.parse(period["end"]));
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
  final Database _database = GetIt.I.get<Database>();

  @override
  PeriodStructureState createState() => PeriodStructureState();
}

class PeriodStructureState extends State<PeriodStructure> {
  DateTime currentStartTime;
  DateTime currentEndTime;

  Stream<DocumentSnapshot> subscription;
  Map<String, dynamic> timetable;

  @override
  void initState() {
    super.initState();
    setupStream();
  }

  void setupStream() async {
    subscription = await widget._database.streamTimetableData();
    subscription.listen(
      (docSnapshot) => setState(() => timetable = docSnapshot.data()),
    );
  }

  void _addPeriod(DateTime startTime, DateTime endTime) {
    String start = startTime.toIso8601String();
    String end = endTime.toIso8601String();

    List newList = List.from(timetable["period_structure"])
      ..add({"start": start, "end": end});

    final newTimetable = timetable;
    newTimetable["period_structure"] = newList;

    widget._database.updateTimetableData(data: newTimetable);
  }

  void _changeNewPeriod(
      {bool start, BuildContext context, Function newState}) async {
    TimeOfDay t = await showTimePicker(
      initialTime: start
          ? TimeOfDay.fromDateTime(currentStartTime)
          : TimeOfDay.fromDateTime(currentEndTime),
      context: context,
    );
    if (t != null) {
      DateTime now = new DateTime.now();
      if (start) {
        newState(() {
          currentStartTime =
              new DateTime(now.year, now.month, now.day, t.hour, t.minute);
          currentEndTime =
              new DateTime(now.year, now.month, now.day, t.hour, t.minute)
                  .add(new Duration(minutes: 60));
        });
      } else {
        newState(() {
          currentEndTime =
              new DateTime(now.year, now.month, now.day, t.hour, t.minute);
        });
      }
    }
  }

  void _deletePeriod(int index) {
    List newList = List.from(timetable["period_structure"])..removeAt(index);

    final newTimetable = timetable;
    newTimetable["period_structure"] = newList;

    widget._database.updateTimetableData(data: newTimetable);
  }

  void _changePeriod(int index, bool start, BuildContext context) async {
    TimeOfDay t = await showTimePicker(
      initialTime: start
          ? TimeOfDay.fromDateTime(
              DateTime.parse(timetable["period_structure"][index]["start"]))
          : TimeOfDay.fromDateTime(
              DateTime.parse(timetable["period_structure"][index]["end"])),
      context: context,
    );

    if (t != null) {
      final now = new DateTime.now();
      String selectedTime =
          new DateTime(now.year, now.month, now.day, t.hour, t.minute)
              .toIso8601String();

      List newList = List.from(timetable["period_structure"]);
      newList[index] = {
        "start": start == true ? selectedTime : newList[index]["start"],
        "end": start == false ? selectedTime : newList[index]["end"]
      };

      final newTimetable = timetable;
      newTimetable["period_structure"] = newList;

      widget._database.updateTimetableData(data: newTimetable);
    }
  }

  @override
  Widget build(BuildContext context) {
    return timetable == null
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: Text("Setup Periods"),
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () => _periodSheet(
                context,
                timetable["period_structure"].isEmpty
                    ? DateTime.now().toIso8601String()
                    : timetable["period_structure"].last["end"],
              ),
            ),
            body: SafeArea(
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 500),
                  child: timetable["period_structure"].isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("You haven't added any periods yet"),
                              Text("Click the add button to start"),
                            ],
                          ),
                        )
                      : ListView(
                          padding: EdgeInsets.only(top: 20.0, bottom: 80.0),
                          scrollDirection: Axis.vertical,
                          children: timetable["period_structure"]
                              .asMap()
                              .entries
                              .map<Widget>(
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
            ),
          );
  }

  _periodSheet(BuildContext context, String previousEnd) {
    setState(() {
      currentStartTime = DateTime.parse(previousEnd);
      currentEndTime = DateTime.parse(previousEnd).add(new Duration(hours: 1));
    });

    final DateFormat formatter = DateFormat.Hm();

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
                                    start: true,
                                    context: context,
                                    newState: setState,
                                  ),
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
                                          formatter.format(currentStartTime),
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
                                    start: false,
                                    context: context,
                                    newState: setState,
                                  ),
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
                                          formatter.format(currentEndTime),
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
