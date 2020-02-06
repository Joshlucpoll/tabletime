// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';


void main() => runApp(StartPage());

class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Tabletime",
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

int getDay() {
  DateTime date = DateTime.now();
  int dayNum = date.weekday;
  return dayNum - 1;
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageView(
      scrollDirection: Axis.vertical,
      physics: PageScrollPhysics(),
      pageSnapping: true,
      dragStartBehavior: DragStartBehavior.start,
      children: <Widget>[
        new Week(),
        new Week()
      ],
    );
  }
}

class Week extends StatefulWidget {
  
  // Week(int weekNum) {
  //   this.weekNum = weekNum;
  // }
  
  @override
  _WeekState createState() => _WeekState();
}

class _WeekState extends State<Week> {

  // _WeekState(weekNum) {
  //   this.weekNum = weekNum
  // }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController (
      length: 5,
      initialIndex: getDay(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Week"),
          bottom: TabBar(
            dragStartBehavior: DragStartBehavior.down,
            isScrollable: true,
            tabs: [
              Tab(text: "Monday"),
              Tab(text: "Tuesday"),
              Tab(text: "Wednesday"),
              Tab(text: "Thursday"),
              Tab(text: "Friday")
            ],
          ),
        ),
        body: TabBarView(
          physics: PageScrollPhysics(),
          children: <Widget>[
            Tab(icon: Icon(Icons.access_alarm),),
            Tab(icon: Icon(Icons.access_alarm),),
            Tab(icon: Icon(Icons.access_alarm),),
            Tab(icon: Icon(Icons.access_alarm),),
            Tab(icon: Icon(Icons.access_alarm),)
          ],
        ),
      ),
    );
  }
}