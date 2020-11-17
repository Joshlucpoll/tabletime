import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter/gestures.dart';
import '../widgets/week.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        scrollDirection: Axis.vertical,
        physics: ScrollPhysics(),
        pageSnapping: true,
        dragStartBehavior: DragStartBehavior.start,
        children: <Widget>[new Week(), new Week()],
      ),
      floatingActionButton: SpeedDial(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        overlayColor: Colors.grey,
        curve: Cubic(0.0, 0.0, 0.58, 1.0),
        animatedIcon: AnimatedIcons.menu_close,
        closeManually: false,
        children: [
          SpeedDialChild(
              child: Icon(Icons.today),
              backgroundColor: Colors.blue,
              label: "Tasks"),
          SpeedDialChild(
              child: Icon(Icons.edit),
              backgroundColor: Colors.green,
              label: "Edit"),
          SpeedDialChild(
              child: Icon(Icons.settings),
              backgroundColor: Colors.grey,
              label: "Settings")
        ],
      ),
    );
  }
}
