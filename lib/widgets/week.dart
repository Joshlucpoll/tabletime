import 'package:flutter/material.dart';

class Week extends StatelessWidget {
  int getDay() {
    DateTime date = DateTime.now();
    int dayNum = date.weekday;

    // If Saturday or Sunday, day will default to Monday
    if (dayNum > 5) {
      dayNum = 1;
    }
    return dayNum - 1;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      initialIndex: getDay(),
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          title: Text(
            "Week",
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(
                child: Text(
                  "MONDAY",
                  style: TextStyle(
                    fontSize: 11,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "TUESDAY",
                  style: TextStyle(
                    fontSize: 11,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "WEDNESDAY",
                  style: TextStyle(
                    fontSize: 11,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "THURSDAY",
                  style: TextStyle(
                    fontSize: 11,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "FRIDAY",
                  style: TextStyle(
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
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
