import 'package:flutter/material.dart';

// widgets
import './newLessonDialog.dart';

class LessonGenerator extends StatelessWidget {
  final Map<String, dynamic> lessons;
  final Widget pageNavigationButtons;

  LessonGenerator({Key key, this.lessons, this.pageNavigationButtons})
      : super(key: key);

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
            pageNavigationButtons,
          ],
        ),
      ),
    );
  }

  addLesson(BuildContext context) {
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
            child: Form(
              // key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.1,
                    height: 5,
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(5),
                        color: Theme.of(context).splashColor),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Add Lesson",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
                    ),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.class_),
                      labelText: "Name",
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
                      prefixIcon: Icon(Icons.school),
                      labelText: "Teacher",
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
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  RaisedButton(
                    child: Text("Add"),
                    onPressed: () {},
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
