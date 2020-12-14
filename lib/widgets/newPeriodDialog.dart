import 'package:flutter/material.dart';

class NewPeriodDialog extends StatefulWidget {
  final Function addPeriod;
  final String previousEnd;

  NewPeriodDialog({Key key, this.addPeriod, this.previousEnd});

  @override
  _NewPeriodDialogState createState() => _NewPeriodDialogState();
}

class _NewPeriodDialogState extends State<NewPeriodDialog> {
  TimeOfDay currentStartTime;
  TimeOfDay currentEndTime;

  @override
  void initState() {
    super.initState();

    setState(() {
      currentStartTime =
          new TimeOfDay.fromDateTime(DateTime.parse(widget.previousEnd));
      currentEndTime = new TimeOfDay.fromDateTime(
          DateTime.parse(widget.previousEnd).add(new Duration(hours: 1)));
    });
  }

  void _changeCurrentPeriod({bool start, BuildContext context}) async {
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add a Period'),
      content: Container(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
            FlatButton(
              onPressed: () =>
                  _changeCurrentPeriod(start: true, context: context),
              child: Container(
                // padding: EdgeInsets.all(5),
                child: Text(
                  "Start: " + currentStartTime.format(context),
                ),
              ),
            ),
            FlatButton(
              onPressed: () =>
                  _changeCurrentPeriod(start: false, context: context),
              child: Container(
                // padding: EdgeInsets.all(5),
                child: Text(
                  "End: " + currentEndTime.format(context),
                ),
              ),
            )
          ])),
      actions: <Widget>[
        TextButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("Add"),
          onPressed: () {
            widget.addPeriod(currentStartTime, currentEndTime);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
