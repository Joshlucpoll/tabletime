import 'package:flutter/material.dart';

class NewLessonDialog extends StatefulWidget {
  final Function addLesson;

  NewLessonDialog({Key key, this.addLesson});

  @override
  _NewLessonDialogState createState() => _NewLessonDialogState();
}

class _NewLessonDialogState extends State<NewLessonDialog> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.fromLTRB(20, 50, 20, 20),
      scrollable: true,
      title: Text('Add a Lesson'),
      content: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.assignment),
                labelText: "Name",
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            )
          ],
        ),
      ),
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
            widget.addLesson();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
