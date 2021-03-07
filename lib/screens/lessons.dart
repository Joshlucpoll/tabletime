import 'package:flutter/material.dart';
import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get_it/get_it.dart';

// Widgets
import 'package:timetable/screens/loading.dart';

// Services
import 'package:timetable/services/database.dart';
import 'package:timetable/services/timetable.dart';

class LessonGenerator extends StatefulWidget {
  final Database _database = GetIt.I.get<Database>();
  final Timetable _timetable = GetIt.I.get<Timetable>();

  @override
  _LessonGeneratorState createState() => _LessonGeneratorState();
}

class _LessonGeneratorState extends State<LessonGenerator> {
  Color currentColour =
      Colors.primaries[Random().nextInt(Colors.primaries.length)];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _teacherController = TextEditingController();
  final _roomController = TextEditingController();

  bool timetableData = false;
  String timetableName;
  CurrentWeek currentWeek;
  int numberOfWeeks;
  Map<String, LessonData> lessonsData;
  List<PeriodData> periodsData;
  Map<String, WeekData> weeksData;

  @override
  void initState() {
    super.initState();
    widget._timetable.onTimeTableChange().listen(
      (update) {
        getUpdatedTimetable();

        if (!timetableData) {
          setState(() {
            timetableData = true;
          });
        }
      },
    );
  }

  void getUpdatedTimetable() {
    if (mounted) {
      setState(() {
        timetableName = widget._timetable.timetableName;
        currentWeek = widget._timetable.currentWeek;
        numberOfWeeks = widget._timetable.numberOfWeeks;
        lessonsData = widget._timetable.lessons;
        periodsData = widget._timetable.periods;
        weeksData = widget._timetable.weeks;
      });
    }
  }

  void _addLesson({String name, Color colour, String teacher, String room}) {
    setState(() {
      currentColour =
          Colors.primaries[Random().nextInt(Colors.primaries.length)];
    });
    final data = {
      "name": name,
      "colour": {
        "red": colour.red,
        "green": colour.green,
        "blue": colour.blue,
      },
      "teacher": teacher,
      "room": room,
    };

    Map<String, dynamic> rawTimetable = widget._timetable.rawTimetable;

    final newLessons = rawTimetable["lessons"];
    newLessons[Uuid().v1()] = data;

    final newTimetable = rawTimetable;
    newTimetable["lessons"] = newLessons;

    widget._database.updateTimetableData(data: newTimetable);
  }

  void _editLesson(
      {String id, String name, Color colour, String teacher, String room}) {
    setState(() {
      currentColour =
          Colors.primaries[Random().nextInt(Colors.primaries.length)];
    });
    final data = {
      "name": name,
      "colour": {
        "red": colour.red,
        "green": colour.green,
        "blue": colour.blue,
      },
      "teacher": teacher,
      "room": room,
    };

    Map<String, dynamic> rawTimetable = widget._timetable.rawTimetable;

    final newLessons = rawTimetable["lessons"];
    newLessons[id] = data;

    final newTimetable = rawTimetable;
    newTimetable["lessons"] = newLessons;

    widget._database.updateTimetableData(data: newTimetable);
  }

  void _removeLesson({String id}) {
    Map<String, dynamic> rawTimetable = widget._timetable.rawTimetable;

    final newLessons = rawTimetable["lessons"];
    newLessons.remove(id);

    final newTimetable = rawTimetable;
    newTimetable["lessons"] = newLessons;

    widget._database.updateTimetableData(data: newTimetable);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return timetableData == false
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: Text("Setup Lessons"),
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () => _lessonSheet(context, null),
            ),
            body: SafeArea(
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 700),
                  child: lessonsData.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("You haven't added any lessons yet"),
                              Text("Click the add button to start"),
                            ],
                          ),
                        )
                      : GridView.count(
                          padding: EdgeInsets.only(
                            top: 20,
                            left: 20,
                            right: 20,
                            bottom: 80,
                          ),
                          crossAxisCount: 2,
                          children: lessonsData.values
                              .map<Widget>((lesson) => _lesson(context, lesson))
                              .toList(),
                        ),
                ),
              ),
            ),
          );
  }

  Widget _lesson(BuildContext context, LessonData lesson) {
    Color colour = lesson.colour;
    Color textColor = useWhiteForeground(colour)
        ? const Color(0xffffffff)
        : const Color(0xff000000);

    return Card(
      color: colour,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        padding: EdgeInsets.all(10.0),
        child: GridTile(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                      color: textColor,
                    ),
                  ),
                  if (lesson.teacher != "")
                    Text(
                      "Teacher: " + lesson.teacher,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 12,
                        color: textColor.withAlpha(155),
                      ),
                    ),
                  if (lesson.room != "")
                    Text(
                      "Room: " + lesson.room,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 12,
                        color: textColor.withAlpha(155),
                      ),
                    ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: textColor,
                    ),
                    onPressed: () => _lessonSheet(context, lesson),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: textColor,
                    ),
                    onPressed: () => _removeLesson(id: lesson.id),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  _lessonSheet(BuildContext context, LessonData lesson) {
    if (lesson != null) {
      _nameController.text = lesson.name;
      _teacherController.text = lesson.teacher;
      _roomController.text = lesson.room;
      setState(() {
        currentColour = lesson.colour;
      });
    }
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
      ),
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusScope.of(context).unfocus(),
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        width: 30,
                        height: 5,
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(5),
                            color: Theme.of(context).splashColor),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        top: 25,
                        right: 20,
                        left: 20,
                        bottom: MediaQuery.of(context).viewInsets.bottom + 20),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.all(10),
                              child: Text(
                                lesson == null ? "Add Lesson" : "Edit Lesson",
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.w500),
                              ),
                            ),
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.class_),
                                hintText: "Name",
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 0, style: BorderStyle.none),
                                ),
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                            ),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      titlePadding: const EdgeInsets.all(0.0),
                                      contentPadding: const EdgeInsets.all(0.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                      ),
                                      actions: [
                                        TextButton(
                                          child: Text("Ok"),
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                        ),
                                      ],
                                      content: SingleChildScrollView(
                                        child: MaterialPicker(
                                          pickerColor: currentColour,
                                          onColorChanged: (colour) {
                                            setState(() {
                                              currentColour = colour;
                                            });
                                          },
                                          enableLabel: true,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                height: 50,
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                padding: EdgeInsets.only(left: 10.0),
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: currentColour,
                                ),
                                child: Text(
                                  "Colour",
                                  style: TextStyle(
                                    color: useWhiteForeground(currentColour)
                                        ? const Color(0xffffffff)
                                        : const Color(0xff000000),
                                  ),
                                ),
                              ),
                            ),
                            TextFormField(
                              controller: _teacherController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.school),
                                hintText: "Teacher",
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 0, style: BorderStyle.none),
                                ),
                              ),
                            ),
                            TextFormField(
                              controller: _roomController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.place),
                                hintText: "Room",
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 0, style: BorderStyle.none),
                                ),
                              ),
                            ),
                            RaisedButton(
                              child: Text(lesson == null ? "Add" : "Save"),
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  if (lesson == null) {
                                    _addLesson(
                                      name: _nameController.text,
                                      colour: currentColour,
                                      teacher: _teacherController.text,
                                      room: _roomController.text,
                                    );
                                  } else {
                                    _editLesson(
                                      id: lesson.id,
                                      name: _nameController.text,
                                      colour: currentColour,
                                      teacher: _teacherController.text,
                                      room: _roomController.text,
                                    );
                                  }
                                  Navigator.pop(context);
                                  _nameController.text = "";
                                  _teacherController.text = "";
                                  _roomController.text = "";
                                }
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
