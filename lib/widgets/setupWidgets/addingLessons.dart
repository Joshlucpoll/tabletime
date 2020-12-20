import 'package:flutter/material.dart';

class AddingLessons extends StatelessWidget {
  final Function endSetup;
  final Widget pageNavigationButtons;

  AddingLessons({Key key, this.endSetup, this.pageNavigationButtons})
      : super(key: key);

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
                "Add Lessons",
                style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Center(
                child: RaisedButton(
                  onPressed: () => endSetup(),
                  child: Text("Add Lessons to Timetable"),
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
