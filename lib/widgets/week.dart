import 'package:flutter/material.dart';

class Week extends StatelessWidget {
  final List days = ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY"];

  int get day {
    DateTime date = DateTime.now();
    int dayNum = date.weekday;

    // If Saturday or Sunday, day will default to Monday
    if (dayNum > 5) {
      dayNum = 1;
    }
    return dayNum - 1;
  }

  Widget tab(String text) {
    return Tab(
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      initialIndex: day,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Row(children: <Widget>[
            Image(
                image: AssetImage("assets/images/tabletime_logo.png"),
                height: 25.0),
            Container(
                margin: EdgeInsets.only(left: 10.0),
                child: Text("Week",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 25)))
          ]),
          bottom: TabBar(
              indicator: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5)),
                  color: Theme.of(context).scaffoldBackgroundColor),
              isScrollable: true,
              tabs: days.map((name) => tab(name)).toList()),
        ),
        body: TabBarView(
          physics: PageScrollPhysics(),
          children: <Widget>[
            Tab(
              icon: Icon(Icons.access_alarm),
            ),
            Tab(
              icon: Icon(Icons.access_alarm),
            ),
            Tab(
              icon: Icon(Icons.access_alarm),
            ),
            Tab(
              icon: Icon(Icons.access_alarm),
            ),
            Tab(
              icon: Icon(Icons.access_alarm),
            )
          ],
        ),
      ),
    );
  }
}
