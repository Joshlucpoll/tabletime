import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './customScrollPhysics.dart';
import './day.dart';

import '../services/timetable.dart';

final shortDays = ["mon", "tue", "wed", "thu", "fri"];
final shortDaysWeekends = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"];

class Week extends StatefulWidget {
  final WeekData week;
  final int weekNum;
  final int selectedWeek;
  final bool weekends;

  Week({
    Key key,
    this.week,
    this.weekNum,
    this.selectedWeek,
    this.weekends,
  }) : super(key: key);

  @override
  _WeekState createState() => _WeekState();
}

class _WeekState extends State<Week> with TickerProviderStateMixin {
  List weekdays = ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY"];
  List days;

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    days = widget.weekends ? [...weekdays, "SATURDAY", "SUNDAY"] : weekdays;

    _tabController = TabController(
      vsync: this,
      length: days.length,
      initialIndex: widget.selectedWeek - 1 == widget.weekNum ? day : 0,
    );
  }

  @override
  void didUpdateWidget(covariant Week oldWidget) {
    super.didUpdateWidget(oldWidget);
    days = widget.weekends ? [...weekdays, "SATURDAY", "SUNDAY"] : weekdays;

    int initialIndex = widget.selectedWeek - 1 == widget.weekNum ? day : 0;

    _tabController = TabController(
      vsync: this,
      length: days.length,
      initialIndex: initialIndex,
    );
    _tabController.animateTo(initialIndex, duration: Duration(microseconds: 1));
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
    if (dayNum > 5 && !widget.weekends) {
      dayNum = 1;
    }
    return dayNum - 1;
  }

  void onEventKey(RawKeyEvent event) async {
    if (event.runtimeType.toString() == 'RawKeyDownEvent') {
      if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
        if (_tabController.index < _tabController.length) {
          _tabController.animateTo(
            _tabController.index + 1,
            curve: Curves.ease,
            duration: Duration(milliseconds: 500),
          );
        }
      }
      if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
        if (_tabController.index > 0) {
          _tabController.animateTo(
            _tabController.index - 1,
            curve: Curves.ease,
            duration: Duration(milliseconds: 500),
          );
        }
      }
    }
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
    List timetableShortDays = widget.weekends ? shortDaysWeekends : shortDays;
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: onEventKey,
      autofocus: true,
      child: Column(
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
              physics: const CustomPageViewScrollPhysics(),
              children: timetableShortDays
                  .map(
                    (day) => Day(
                      blocks: widget.week.week[day],
                      dayNum: timetableShortDays.indexOf(day),
                      weekNum: widget.weekNum,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
