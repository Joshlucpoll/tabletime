import 'package:flutter/material.dart';

class Period extends StatelessWidget {
  Period({Key key, this.period, this.index, this.changePeriod})
      : super(key: key);

  final period;
  final index;
  final Function changePeriod;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Expanded(
                child: FlatButton(
                    onPressed: changePeriod(index, true, context),
                    child: Container(
                        margin: EdgeInsets.all(20),
                        alignment: Alignment(0.0, 0.0),
                        child: Text("Start: ${period["start"]}",
                            style: TextStyle(fontSize: 20))))),
            Text("-"),
            Expanded(
                child: Container(
                    margin: EdgeInsets.all(10),
                    alignment: Alignment(0.0, 0.0),
                    child: Text("End: ${period["end"]}",
                        style: TextStyle(fontSize: 20))))
          ]),
    );
  }
}

class PeriodStructure extends StatelessWidget {
  final List periodStructure;
  final Function updatePeriod;

  PeriodStructure({Key key, this.periodStructure, this.updatePeriod})
      : super(key: key);

  void _addPeriod() {
    var newList = List.from(periodStructure)
      ..add({"start": "9:10", "end": "10:10"});
    updatePeriod(newList);
  }

  void _changePeriod(int index, bool start, BuildContext context) async {
    // errors
    TimeOfDay time =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: double.infinity,
        child: Column(
          children: <Widget>[
            Expanded(
                child: ListView(
                    scrollDirection: Axis.vertical,
                    children: periodStructure
                        .asMap()
                        .entries
                        .map((period) => Period(
                            period: period.value,
                            index: period.key,
                            changePeriod: _changePeriod))
                        .toList())),
            RaisedButton(
                child: Text("New Period"), onPressed: () => _addPeriod())
          ],
        ));
  }
}
