import 'package:flutter/material.dart';

import '../widgets/day.dart';

final shortDays = ["mon", "tue", "wed", "thu", "fri"];

class Week extends StatefulWidget {
  final lessons;
  final periodStructure;
  final week;

  Week({Key key, this.lessons, this.periodStructure, this.week})
      : super(key: key);

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
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
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
        SizedBox(height: 5),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: PageScrollPhysics(),
            children: shortDays
                .map(
                  (day) => Day(
                    day: widget.week[day],
                    lessons: widget.lessons,
                    periodStructure: widget.periodStructure,
                    dayNum: shortDays.indexOf(day) + 1,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
