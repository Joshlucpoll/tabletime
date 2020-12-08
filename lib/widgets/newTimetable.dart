import 'package:flutter/material.dart';

class NewTimetable extends StatefulWidget {
  final String name;
  final Function updateName;

  NewTimetable({Key key, this.name, this.updateName}) : super(key: key);

  @override
  _NewTimetableState createState() => _NewTimetableState();
}

class _NewTimetableState extends State<NewTimetable> {
  final TextEditingController _tabletimeNameController =
      TextEditingController();

  @override
  void initState() {
    _tabletimeNameController.text = widget.name;
    super.initState();
  }

  @override
  void dispose() {
    _tabletimeNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: double.infinity,
        child: SafeArea(
            child: Column(children: <Widget>[
          Container(
              padding: EdgeInsets.only(top: 40.0, bottom: 40.0),
              child: Text("Create a Timetable",
                  style:
                      TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold))),
          Container(
            child: TextFormField(
              key: const ValueKey("password"),
              controller: _tabletimeNameController,
            ),
          )
        ])));
  }
}
