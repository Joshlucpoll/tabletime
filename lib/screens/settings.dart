import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:showcaseview/showcaseview.dart';

// widgets
import '../widgets/setupWidgets/lessonGenerator.dart';
import 'package:timetable/widgets/setupWidgets/periodStructure.dart';

// Services
import '../services/database.dart';
import '../services/auth.dart';

class SettingsPage extends StatefulWidget {
  final Database _database = GetIt.I.get<Database>();
  final Auth _auth = GetIt.I.get<Auth>();
  final Map<String, dynamic> timetableData;
  final showShowcase;

  SettingsPage({
    Key key,
    this.timetableData,
    this.showShowcase,
  }) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController _tabletimeNameController;
  int dropdownValue;

  @override
  void initState() {
    dropdownValue = widget.timetableData["number_of_weeks"];
    _tabletimeNameController =
        TextEditingController(text: widget.timetableData["timetable_name"]);
    super.initState();
  }

  PageRouteBuilder pageRouteBuilder({BuildContext context, Widget child}) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
      ) =>
          SlideTransition(
        position: animation.drive(
          Tween(
            begin: Offset(1.0, 0.0),
            end: Offset.zero,
          ).chain(
            CurveTween(
              curve: Curves.ease,
            ),
          ),
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: ListView(
        children: [
          ListTile(
            enabled: false,
            title: Text("Timetable"),
          ),
          ListTile(
            onTap: () {
              _tabletimeNameController.text =
                  widget.timetableData["timetable_name"];
              showDialog(
                context: context,
                builder: (_) => new AlertDialog(
                  title: Text("Name Timetable"),
                  content: TextFormField(
                    controller: _tabletimeNameController,
                  ),
                  actions: [
                    FlatButton(
                      child: Text("Cancel"),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    FlatButton(
                      child: Text("Ok"),
                      onPressed: () {
                        final newTimetableData = widget.timetableData;
                        newTimetableData["timetable_name"] =
                            _tabletimeNameController.text;
                        widget._database
                            .updateTimetableData(data: newTimetableData);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              );
            },
            leading: Icon(Icons.edit),
            title: Text("Timetable Name"),
          ),
          ListTile(
            onTap: () {},
            leading: Icon(Icons.format_list_numbered),
            trailing: DropdownButton<int>(
              value: dropdownValue,
              icon: Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              underline: Container(height: 2),
              onChanged: (int newValue) {
                setState(() {
                  dropdownValue = newValue;
                });
                final newTimetableData = widget.timetableData;
                newTimetableData["number_of_weeks"] = newValue;
                widget._database.updateTimetableData(data: newTimetableData);
              },
              items:
                  <int>[1, 2, 3, 4, 5].map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
            ),
            title: Text("Number of Weeks"),
          ),
          ListTile(
            onTap: () => Navigator.push(
              context,
              pageRouteBuilder(context: context, child: LessonGenerator()),
            ),
            leading: Icon(Icons.class_),
            title: Text("Edit Lessons"),
          ),
          ListTile(
            onTap: () => Navigator.push(
              context,
              pageRouteBuilder(context: context, child: PeriodStructure()),
            ),
            leading: Icon(Icons.calendar_today),
            title: Text("Edit Periods"),
          ),
          ListTile(
            onTap: () => showDialog(
              context: context,
              builder: (_) => new AlertDialog(
                title: Text("Reset Timetable"),
                content: Text(
                    "Are you sure you want to reset your timetable? This does not delete your lessons nor periods, just which lessons happen at which period"),
                actions: [
                  FlatButton(
                    child: Text("Cancel"),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  FlatButton(
                    textColor: Colors.red,
                    child: Text("Reset"),
                    onPressed: () {
                      widget._database.resetWeeksData();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            leading: Icon(Icons.local_fire_department),
            title: Text("Reset Timetable"),
          ),
          ListTile(
            enabled: false,
            title: Text("More"),
          ),
          ListTile(
            onTap: () {
              // showShowcase();
              // Navigator.of(context).pop();
            },
            leading: Icon(Icons.help),
            title: Text("Help"),
          ),
          ListTile(
            onTap: () {
              widget._auth.signOut();
              Navigator.of(context).pop();
            },
            leading: Icon(Icons.exit_to_app),
            title: Text("Sign out"),
          ),
        ],
      ),
    );
  }
}
