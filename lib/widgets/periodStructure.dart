import 'package:cloud_firestore/cloud_firestore.dart';
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
    TimeOfDay startTime = TimeOfDay.fromDateTime(period["start"].toDate());
    return "Start: " + startTime.format(context);
  }

  String getEnd(BuildContext context) {
    TimeOfDay startTime = TimeOfDay.fromDateTime(period["end"].toDate());
    return "End: " + startTime.format(context);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 4,
        margin: EdgeInsets.only(top: 10, right: 20, bottom: 0, left: 20),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Container(
            child: ListTile(
                trailing: InkWell(
                    onTap: () => deletePeriod(index),
                    child: Icon(Icons.delete,
                        color: Theme.of(context).accentColor)),
                title: Center(
                    child: Text("Period ${index + 1}",
                        style: TextStyle(fontWeight: FontWeight.normal))),
                subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Expanded(
                          child: InkWell(
                              splashColor: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(10),
                              onTap: () => changePeriod(index, true, context),
                              child: Container(
                                  margin: EdgeInsets.all(10),
                                  alignment: Alignment(0.0, 0.0),
                                  child: Text(getStart(context))))),
                      Expanded(
                          child: InkWell(
                              splashColor: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(10),
                              onTap: () => changePeriod(index, false, context),
                              child: Container(
                                  margin: EdgeInsets.all(10),
                                  alignment: Alignment(0.0, 0.0),
                                  child: Text(getEnd(context)))))
                    ]))));
  }
}

class PeriodStructure extends StatelessWidget {
  final List periodStructure;
  final Function updatePeriod;

  PeriodStructure({Key key, this.periodStructure, this.updatePeriod})
      : super(key: key);

  void _addPeriod(TimeOfDay startTime, TimeOfDay endTime) {
    DateTime now = DateTime.now();
    Timestamp start = new Timestamp.fromDate(new DateTime(
        now.year, now.month, now.day, startTime.hour, startTime.minute));
    Timestamp end = new Timestamp.fromDate(new DateTime(
        now.year, now.month, now.day, endTime.hour, endTime.minute));

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
          ? TimeOfDay.fromDateTime(periodStructure[index]["start"].toDate())
          : TimeOfDay.fromDateTime(periodStructure[index]["end"].toDate()),
      context: context,
    );

    if (t != null) {
      final now = new DateTime.now();
      Timestamp selectedTime = Timestamp.fromDate(
          new DateTime(now.year, now.month, now.day, t.hour, t.minute));

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
            child: Column(children: <Widget>[
          Container(
              padding: EdgeInsets.only(top: 40.0, bottom: 40.0),
              child: Text("Setup Periods",
                  style:
                      TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold))),
          Expanded(
              child: ListView(
                  scrollDirection: Axis.vertical,
                  children: periodStructure
                      .asMap()
                      .entries
                      .map((period) => Period(
                          period: period.value,
                          index: period.key,
                          changePeriod: _changePeriod,
                          deletePeriod: _deletePeriod))
                      .toList())),
          Container(
              padding: EdgeInsets.all(10.0),
              width: double.infinity,
              child: RaisedButton(
                  child: Text("New Period"),
                  onPressed: () => showDialog(
                      context: context,
                      builder: (_) {
                        return NewPeriodDialog(
                            addPeriod: _addPeriod,
                            previousEnd: periodStructure.isEmpty
                                ? Timestamp.now()
                                : periodStructure.last["end"]);
                      })))
        ])));
  }
}
