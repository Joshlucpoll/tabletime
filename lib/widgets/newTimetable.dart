import 'package:flutter/material.dart';

class NewTimetable extends StatefulWidget {
  final String name;
  final Function updateName;

  NewTimetable({Key key, this.name, this.updateName}) : super(key: key);

  @override
  _NewTimetableState createState() => _NewTimetableState();
}

class _NewTimetableState extends State<NewTimetable> {
  TextEditingController _tabletimeNameController;

  @override
  void initState() {
    _tabletimeNameController = TextEditingController(text: widget.name);
    _tabletimeNameController.addListener(() {
      widget.updateName(_tabletimeNameController.text);
    });
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
              padding: EdgeInsets.only(
                  top: 40.0, bottom: 40.0, left: 20.0, right: 20.0),
              child: Text("Create a Timetable",
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  style:
                      TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold))),
          Expanded(
              child: Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Name your Timetable",
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                  ),
                ),
                SizedBox(height: 20.0),
                Container(
                    constraints: BoxConstraints(maxWidth: 500),
                    child: TextField(
                      controller: _tabletimeNameController,
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.edit,
                        ),
                      )),
                    )),
              ],
            ),
          )),
        ])));
  }
}
