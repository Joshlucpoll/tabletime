import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter/gestures.dart';

// Services
import '../services/auth.dart';

// Widgets
import '../widgets/week.dart';

class Home extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  const Home({Key key, this.auth, this.firestore}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
              label: "Tasks",
              onTap: () {
                Auth(auth: widget.auth).signOut();
              }),
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
