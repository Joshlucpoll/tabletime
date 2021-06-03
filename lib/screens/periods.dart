import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get_it/get_it.dart';

// Widgets
import 'package:timetable/screens/loading.dart';

// Services
import 'package:timetable/services/database.dart';
import 'package:timetable/services/timetable.dart';

class Period extends StatelessWidget {
  Period({
    Key key,
    this.period,
    this.index,
    this.changePeriod,
    this.deletePeriod,
  }) : super(key: key);

  final PeriodData period;
  final int index;
  final Function changePeriod;
  final Function deletePeriod;

  String getStart(BuildContext context) {
    final DateFormat formatter = DateFormat.Hm();
    return formatter.format(period.start);
  }

  String getEnd(BuildContext context) {
    final DateFormat formatter = DateFormat.Hm();
    return formatter.format(period.end);
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
            onTap: () async => await deletePeriod(index),
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
                onTap: () async => await changePeriod(index, true, context),
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
  final Timetable _timetable = GetIt.I.get<Timetable>();

  @override
  PeriodStructureState createState() => PeriodStructureState();
}

class PeriodStructureState extends State<PeriodStructure> {
  DateTime currentStartTime;
  DateTime currentEndTime;

  bool timetableData = false;
  String timetableName;
  CurrentWeek currentWeek;
  int numberOfWeeks;
  Map<String, LessonData> lessonsData;
  List<PeriodData> periodsData;
  Map<String, WeekData> weeksData;

  @override
  void initState() {
    super.initState();
    widget._timetable.onTimeTableChange().listen(
      (update) {
        getUpdatedTimetable();

        if (!timetableData) {
          setState(() {
            timetableData = true;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getUpdatedTimetable() {
    if (mounted) {
      setState(() {
        timetableName = widget._timetable.timetableName;
        currentWeek = widget._timetable.currentWeek;
        numberOfWeeks = widget._timetable.numberOfWeeks;
        lessonsData = widget._timetable.lessons;
        periodsData = widget._timetable.periods;
        weeksData = widget._timetable.weeks;
      });
    }
  }

  Future<void> _addPeriod(DateTime startTime, DateTime endTime) async {
    String start = startTime.toIso8601String();
    String end = endTime.toIso8601String();

    Map<String, dynamic> rawTimetable = widget._timetable.rawTimetable;

    Map newPeriodRaw = {"start": start, "end": end};

    List newList = List.from(rawTimetable["period_structure"])
      ..add(newPeriodRaw);

    // sorts list into chronological order with start times
    newList.sort((a, b) {
      int aTime = DateTime.parse(a["start"]).hour * 60 +
          DateTime.parse(a["start"]).minute;
      int bTime = DateTime.parse(b["start"]).hour * 60 +
          DateTime.parse(b["start"]).minute;
      return aTime - bTime;
    });

    final newTimetable = rawTimetable;
    newTimetable["period_structure"] = newList;

    await widget._database.updateTimetableData(data: newTimetable);
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

  bool _periodInWeeksData(int index) {
    for (WeekData weekData in weeksData.values) {
      for (DayData dayData in weekData.week.values) {
        for (BlockData blockData in dayData.day) {
          if (periodsData.indexOf(blockData.period) == index) {
            return true;
          }
        }
      }
    }
    return false;
  }

  Future<void> _removePeriod(int index) async {
    if (_periodInWeeksData(index)) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Are you sure you want to delete Period " +
              (index + 1).toString() +
              "?"),
          content: Text("Period " +
              (index + 1).toString() +
              " has lessons associated with it, deleting it will also remove those lessons from your timetable"),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                primary: Theme.of(context).textTheme.bodyText1.color,
              ),
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(
                primary: Colors.red,
              ),
              child: Text("Continue"),
              onPressed: () async {
                Map<String, dynamic> rawTimetable =
                    widget._timetable.rawTimetable;

                final newWeeks = rawTimetable["weeks"];

                newWeeks.values.forEach(
                  (week) => week.values.forEach(
                    (day) {
                      List blocksToRemove = [];
                      day.forEach((block) {
                        if (block["period"] == index) {
                          blocksToRemove.add(block);
                        } else if (block["period"] > index) {
                          block["period"] = block["period"] - 1;
                        }
                      });
                      blocksToRemove.forEach((block) => day.remove(block));
                    },
                  ),
                );

                final newTimetable = rawTimetable;
                newTimetable["weeks"] = newWeeks;

                await widget._database.updateTimetableData(data: newTimetable);

                await _deletePeriod(index);
                Navigator.of(context).pop();
              },
            )
          ],
        ),
      );
    } else {
      await _deletePeriod(index);
    }
  }

  Future<void> _deletePeriod(int index) async {
    Map<String, dynamic> rawTimetable = widget._timetable.rawTimetable;

    List newList = List.from(rawTimetable["period_structure"])..removeAt(index);

    final newTimetable = rawTimetable;
    newTimetable["period_structure"] = newList;

    await widget._database.updateTimetableData(data: newTimetable);
  }

  void _changePeriod(int index, bool start, BuildContext context) async {
    Map<String, dynamic> rawTimetable = widget._timetable.rawTimetable;

    TimeOfDay t = await showTimePicker(
      initialTime: start
          ? TimeOfDay.fromDateTime(
              DateTime.parse(rawTimetable["period_structure"][index]["start"]))
          : TimeOfDay.fromDateTime(
              DateTime.parse(rawTimetable["period_structure"][index]["end"])),
      context: context,
    );

    if (t != null) {
      final now = new DateTime.now();
      String selectedTime =
          new DateTime(now.year, now.month, now.day, t.hour, t.minute)
              .toIso8601String();

      List newList = List.from(rawTimetable["period_structure"]);
      newList[index] = {
        "start": start == true ? selectedTime : newList[index]["start"],
        "end": start == false ? selectedTime : newList[index]["end"]
      };

      // sorts list into chronological order with start times
      newList.sort((a, b) {
        int aTime = DateTime.parse(a["start"]).hour * 60 +
            DateTime.parse(a["start"]).minute;
        int bTime = DateTime.parse(b["start"]).hour * 60 +
            DateTime.parse(b["start"]).minute;
        return aTime - bTime;
      });

      final newTimetable = rawTimetable;
      newTimetable["period_structure"] = newList;

      widget._database.updateTimetableData(data: newTimetable);
    }
  }

  @override
  Widget build(BuildContext context) {
    return timetableData == false
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: Text("Setup Periods"),
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () => _periodSheet(
                context,
                periodsData.isEmpty
                    ? DateTime.now().toIso8601String()
                    : periodsData.last.end.toIso8601String(),
              ),
            ),
            body: SafeArea(
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 500),
                  child: periodsData.isEmpty
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
                          children: periodsData
                              .asMap()
                              .entries
                              .map<Widget>(
                                (period) => Period(
                                    period: period.value,
                                    index: period.key,
                                    changePeriod: _changePeriod,
                                    deletePeriod: _removePeriod),
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
                          ElevatedButton(
                            child: Text("Add"),
                            onPressed: () async {
                              await _addPeriod(
                                  currentStartTime, currentEndTime);
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
