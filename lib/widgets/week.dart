import 'package:flutter/material.dart';

class Week extends StatefulWidget {
  final data;

  Week({Key key, this.data}) : super(key: key);

  @override
  _WeekState createState() => _WeekState();
}

class _WeekState extends State<Week> with SingleTickerProviderStateMixin {
  final List days = ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY"];

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: days.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          padding: EdgeInsets.only(top: 10),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                ),
                color: Theme.of(context).scaffoldBackgroundColor),
            isScrollable: true,
            tabs: days.map((name) => tab(name)).toList(),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
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
      ],
    );
  }
}
