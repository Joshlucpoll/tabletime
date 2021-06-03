import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

// Services
import '../services/database.dart';
import 'package:timetable/services/reload/reload.dart';

class Timetables extends StatefulWidget {
  final Database _database = GetIt.I.get<Database>();

  @override
  _TimetablesState createState() => _TimetablesState();
}

class _TimetablesState extends State<Timetables> {
  TextEditingController _tabletimeNameController;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> timetables = [];
  int selectedIndex = -1;
  bool changed = false;

  Future<void> getTimetables() async {
    List<QueryDocumentSnapshot<Map<String, dynamic>>> timetablesData =
        await widget._database.getTimetables();

    timetablesData.sort((a, b) {
      String aName = a.data()["timetable_name"];
      String bName = b.data()["timetable_name"];
      return aName.compareTo(bName);
    });

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
    _tabletimeNameController = TextEditingController();
    super.initState();
  }

  Future<void> deleteTimetable({String id}) async {
    await widget._database.deleteTimetable(id: id);
    await getTimetables();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (changed) {
          await reload(context);
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Timetables"),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async {
            await widget._database.addTimetable();
            changed = true;
            await getTimetables();
          },
        ),
        body: ListView(
          children: timetables
              .asMap()
              .entries
              .map<Widget>(
                (MapEntry<int, QueryDocumentSnapshot<Map<String, dynamic>>>
                        timetable) =>
                    ListTile(
                  leading: Radio(
                    value: timetable.key,
                    groupValue: selectedIndex,
                    onChanged: (value) async {
                      setState(() {
                        selectedIndex = value;
                      });
                      changed = true;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Reload for actions to take effect"),
                          action: SnackBarAction(
                            label: "Reload",
                            onPressed: () async {
                              await reload(context);
                            },
                          ),
                        ),
                      );
                      await widget._database
                          .switchTimetable(id: timetable.value.id);
                    },
                  ),
                  title: Text(
                    timetable.value.data()["timetable_name"],
                  ),
                  trailing: PopupMenuButton(
                    onSelected: (result) async {
                      if (result == 0) {
                        _tabletimeNameController.text =
                            timetable.value.data()["timetable_name"];

                        showDialog(
                          context: context,
                          builder: (_) => new AlertDialog(
                            title: Text("Name Timetable"),
                            content: TextFormField(
                              controller: _tabletimeNameController,
                            ),
                            actions: [
                              TextButton(
                                style: TextButton.styleFrom(
                                  primary: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .color,
                                ),
                                child: Text("Cancel"),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  primary: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .color,
                                ),
                                child: Text("Ok"),
                                onPressed: () async {
                                  await widget._database.editTimetableName(
                                    name: _tabletimeNameController.text,
                                    timetableID: timetable.value.id,
                                  );

                                  await getTimetables();
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        );
                      } else if (result == 1) {
                        if (timetables.length <= 1) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Cannot delete only timetable"),
                            ),
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (_) => new AlertDialog(
                              title: Text("Delete Timetable"),
                              content: Text(
                                  "Are you sure you want to completely delete this timetable? This action is irreversible."),
                              actions: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                    primary: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .color,
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
                                    await deleteTimetable(
                                        id: timetable.value.id);
                                    await widget._database
                                        .switchTimetable(id: timetables[0].id);
                                    await getTimetables();
                                    // check if timetable in last one and don't allow deletion
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          );
                        }
                      }
                    },
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
                          leading: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          title: Text(
                            "Delete",
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
