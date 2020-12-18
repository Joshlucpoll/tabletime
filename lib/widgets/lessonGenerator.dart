import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

// widgets
import './newLessonDialog.dart';

class LessonGenerator extends StatefulWidget {
  final Map<String, dynamic> lessons;
  final Widget pageNavigationButtons;

  LessonGenerator({Key key, this.lessons, this.pageNavigationButtons})
      : super(key: key);

  @override
  _LessonGeneratorState createState() => _LessonGeneratorState();
}

class _LessonGeneratorState extends State<LessonGenerator> {
  Color currentColour =
      Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);

  void changeColour(Color color) => setState(() {
        print(color);
        currentColour = color;
      });

  void addPeriod(data) {}

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
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
              width: double.infinity,
              constraints: BoxConstraints(maxWidth: 500),
              child: RaisedButton(
                child: Text("New Lesson"),
                onPressed: () => addLesson(context),
              ),
            ),
            widget.pageNavigationButtons,
          ],
        ),
      ),
    );
  }

  addLesson(BuildContext context, Color colour, Function changeColour) {
    return showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            padding: EdgeInsets.only(
                top: 10,
                right: 20,
                left: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 30,
                  height: 5,
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(5),
                      color: Theme.of(context).splashColor),
                ),
                Form(
                  // key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "Add Lesson",
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.w500),
                          ),
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.class_),
                            labelText: "Name",
                            border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: 0, style: BorderStyle.none),
                            ),
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  titlePadding: const EdgeInsets.all(0.0),
                                  contentPadding: const EdgeInsets.all(0.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  content: SingleChildScrollView(
                                    child: MaterialPicker(
                                      pickerColor: colour,
                                      onColorChanged: changeColour,
                                      enableLabel: true,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Container(
                            height: 50,
                            padding: EdgeInsets.only(left: 10.0),
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: colour,
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
                        SizedBox(height: 10),
                        TextFormField(
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.school),
                            labelText: "Teacher",
                            border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: 0, style: BorderStyle.none),
                            ),
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.place),
                            labelText: "Room",
                            border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: 0, style: BorderStyle.none),
                            ),
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        RaisedButton(child: Text("Add"), onPressed: () {})
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
