import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:timetable/main.dart';

// Services
import '../services/database.dart';

class Timetables extends StatefulWidget {
  final Database _database = GetIt.I.get<Database>();

  @override
  _TimetablesState createState() => _TimetablesState();
}

class _TimetablesState extends State<Timetables> {
  List<QueryDocumentSnapshot> timetables = [];
  int selectedIndex = -1;

  void getTimetables() async {
    List<QueryDocumentSnapshot> timetablesData =
        await widget._database.getTimetables();

    DocumentReference currentTimetable =
        await widget._database.getCurrentTimetable();

    int index =
        timetablesData.map((e) => e.id).toList().indexOf(currentTimetable.id);

    setState(() {
      timetables = timetablesData;
      selectedIndex = index;
    });
  }

  @override
  void initState() {
    getTimetables();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Timetables"),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => widget._database.addTimetable(),
      ),
      body: ListView(
        children: timetables
            .asMap()
            .entries
            .map<Widget>(
              (MapEntry<int, QueryDocumentSnapshot> timetable) => ListTile(
                leading: Radio(
                  value: timetable.key,
                  groupValue: selectedIndex,
                  onChanged: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Restart for actions to take effect"),
                        action: SnackBarAction(
                          label: "Restart",
                          onPressed: () {
                            RestartWidget.restartApp(context);
                          },
                        ),
                      ),
                    );
                    widget._database.switchTimetable(id: timetable.value.id);
                  },
                ),
                title: Text(
                  timetable.value.data()["timetable_name"],
                ),
                trailing: PopupMenuButton(
                  onSelected: (result) => print(result),
                  itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                    const PopupMenuItem(
                      value: 0,
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text("Edit Name"),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 1,
                      child: ListTile(
                        leading: Icon(Icons.delete),
                        title: Text("Delete"),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// showDialog(
//                       context: context,
//                       builder: (_) => new AlertDialog(
//                         title: Text("Name Timetable"),
//                         content: TextFormField(
//                           controller: _tabletimeNameController,
//                         ),
//                         actions: [
//                           FlatButton(
//                             child: Text("Cancel"),
//                             onPressed: () => Navigator.of(context).pop(),
//                           ),
//                           FlatButton(
//                             child: Text("Ok"),
//                             onPressed: () {
//                               final newTimetableData =
//                                   widget._timetable.rawTimetable;
//                               newTimetableData["timetable_name"] =
//                                   _tabletimeNameController.text;
//                               widget._database
//                                   .updateTimetableData(data: newTimetableData);
//                               Navigator.of(context).pop();
//                             },
//                           ),
//                         ],
//                       ),
//                     );
