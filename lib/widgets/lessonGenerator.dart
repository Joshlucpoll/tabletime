import 'package:flutter/material.dart';
import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class LessonGenerator extends StatefulWidget {
  final Map<String, dynamic> lessons;
  final Function updateLessons;
  final Widget pageNavigationButtons;

  LessonGenerator({
    Key key,
    this.lessons,
    this.updateLessons,
    this.pageNavigationButtons,
  }) : super(key: key);

  @override
  _LessonGeneratorState createState() => _LessonGeneratorState();
}

class _LessonGeneratorState extends State<LessonGenerator> {
  Color currentColour =
      Colors.primaries[Random().nextInt(Colors.primaries.length)];

  final _nameController = TextEditingController();
  final _teacherController = TextEditingController();
  final _roomController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

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
    final newLessons = widget.lessons;
    newLessons[Uuid().v1()] = data;
    widget.updateLessons(newLessons);
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
    final newLessons = widget.lessons;
    newLessons[id] = data;
    widget.updateLessons(newLessons);
  }

  void _removeLesson({String id}) {
    final newLessons = widget.lessons;
    newLessons.remove(id);
    widget.updateLessons(newLessons);
  }

  @override
  void dispose() {
    super.dispose();
  }

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
                "Setup Lessons",
                style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Container(
                constraints: BoxConstraints(maxWidth: 500),
                child: GridView.count(
                    crossAxisCount: 2,
                    children: widget.lessons.entries
                        .map(
                            (entry) => _lesson(context, entry.key, entry.value))
                        .toList()),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
              width: double.infinity,
              constraints: BoxConstraints(maxWidth: 500),
              child: RaisedButton(
                child: Text("New Lesson"),
                onPressed: () => _lessonSheet(context, null),
              ),
            ),
            widget.pageNavigationButtons,
          ],
        ),
      ),
    );
  }

  Widget _lesson(BuildContext context, String id, data) {
    Color colour = Color.fromRGBO(
      data["colour"]["red"],
      data["colour"]["green"],
      data["colour"]["blue"],
      1,
    );
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
                    data["name"],
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                      color: textColor,
                    ),
                  ),
                  if (data["teacher"] != "")
                    Text(
                      "Teacher: " + data["teacher"],
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 12,
                        color: textColor.withAlpha(155),
                      ),
                    ),
                  if (data["room"] != "")
                    Text(
                      "Room: " + data["room"],
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
                    onPressed: () => _lessonSheet(context, id),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: textColor,
                    ),
                    onPressed: () => _removeLesson(id: id),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  _lessonSheet(BuildContext context, String editId) {
    if (editId != null) {
      final lesson = widget.lessons[editId];
      _nameController.text = lesson["name"];
      _teacherController.text = lesson["teacher"];
      _roomController.text = lesson["room"];
      setState(() {
        currentColour = Color.fromRGBO(
          lesson["colour"]["red"],
          lesson["colour"]["green"],
          lesson["colour"]["blue"],
          1,
        );
      });
    }
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
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
                                editId == null ? "Add Lesson" : "Edit Lesson",
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
                              child: Text(editId == null ? "Add" : "Save"),
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  if (editId == null) {
                                    _addLesson(
                                      name: _nameController.text,
                                      colour: currentColour,
                                      teacher: _teacherController.text,
                                      room: _roomController.text,
                                    );
                                  } else {
                                    _editLesson(
                                      id: editId,
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
