import 'package:flutter/material.dart';

class Period extends StatelessWidget {
  Period({Key key, this.period, this.index}) : super(key: key);

  final period;
  final index;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(period.start + period.end),
    );
  }
}

class PeriodStructure extends StatelessWidget {

  final List periodStructure;
  final ValueChanged<List> updatePeriod;
  PeriodStructure({Key key, this.periodStructure, this.updatePeriod}) : super(key: key);

  void addPeriod() {
    var newList = periodStructure.add({
      "start": "9:10",
      "end": "10:10"
    });
    updatePeriod(newList);
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          ListView(
              children: periodStructure
                  .asMap()
                  .entries
                  .map((period) => Period(
                        period: period.value,
                        index: period.key,
                      ))
                  .toList()),
          RaisedButton(
            onPressed: 
          )
        ],
      )
    );
  }
}
