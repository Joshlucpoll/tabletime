import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_shortcuts/keyboard_shortcuts.dart';

import './customScrollPhysics.dart';
import './day.dart';

import '../services/timetable.dart';

final shortDays = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"];

class Week extends StatefulWidget {
  final WeekData week;
  final int weekNum;
  final int selectedWeek;
  final WeekendEnabled weekendEnabled;

  Week({
    Key key,
    this.week,
    this.weekNum,
    this.selectedWeek,
    this.weekendEnabled,
  }) : super(key: key);

  @override
  _WeekState createState() => _WeekState();
}

class _WeekState extends State<Week> with TickerProviderStateMixin {
  List days;

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    days = ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY"];

    if (widget.weekendEnabled.saturday) {
      days.add("SATURDAY");
    }
    if (widget.weekendEnabled.sunday) {
      days.add("SUNDAY");
    }

    _tabController = TabController(
      vsync: this,
      length: days.length,
      initialIndex: widget.selectedWeek - 1 == widget.weekNum ? day : 0,
    );
  }

  @override
  void didUpdateWidget(covariant Week oldWidget) {
    super.didUpdateWidget(oldWidget);
    days = ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY"];

    if (widget.weekendEnabled.saturday) {
      days.add("SATURDAY");
    }
    if (widget.weekendEnabled.sunday) {
      days.add("SUNDAY");
    }

    int currentIndex = _tabController.index;
    if (currentIndex >= days.length) {
      currentIndex = days.length - 1;
    }

    _tabController = TabController(
      vsync: this,
      length: days.length,
      initialIndex: currentIndex,
    );
    _tabController.animateTo(currentIndex, duration: Duration(microseconds: 1));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int get day {
    DateTime date = DateTime.now();
    int dayNum = date.weekday;

    WeekendEnabled x = widget.weekendEnabled;
    if (dayNum > 5) {
      if (!x.saturday && x.sunday) {
        dayNum = 7;
      } else if (!x.saturday && !x.sunday) {
        dayNum = 1;
      } else if (!x.sunday) {
        if (dayNum == 7) {
          dayNum = 1;
        }
      }
    }
    return dayNum - 1;
  }

  void shortcutChangeDay({bool next}) {
    if (next) {
      if (_tabController.index < _tabController.length) {
        _tabController.animateTo(
          _tabController.index + 1,
          curve: Curves.ease,
          duration: Duration(milliseconds: 500),
        );
      }
    } else {
      if (_tabController.index > 0) {
        _tabController.animateTo(
          _tabController.index - 1,
          curve: Curves.ease,
          duration: Duration(milliseconds: 500),
        );
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
    return KeyBoardShortcuts(
      keysToPress: {LogicalKeyboardKey.arrowRight},
      onKeysPressed: () => shortcutChangeDay(next: true),
      child: KeyBoardShortcuts(
        keysToPress: {LogicalKeyboardKey.arrowLeft},
        onKeysPressed: () => shortcutChangeDay(next: false),
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
                children: shortDays
                    .where((day) {
                      if (day == "sat" && !widget.weekendEnabled.saturday) {
                        return false;
                      }
                      if (day == "sun" && !widget.weekendEnabled.sunday) {
                        return false;
                      }
                      return true;
                    })
                    .map(
                      (day) => Day(
                        blocks: widget.week.week[day],
                        dayNum: shortDays.indexOf(day),
                        weekNum: widget.weekNum,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
