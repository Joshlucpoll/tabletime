import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';

// Widgets
import './expandedSelection.dart';

class Period extends StatefulWidget {
  final lesson;
  final period;
  final int dayNum;

  Period({
    Key key,
    this.lesson,
    this.period,
    this.dayNum,
  }) : super(key: key);
  @override
  _PeriodState createState() => _PeriodState();
}

class _PeriodState extends State<Period> {
  final DateFormat formatter = DateFormat.Hm();
  bool expanded = false;

  bool get isCurrentLesson {
    DateTime now = DateTime.now();
    if (now.weekday == widget.dayNum) {
      DateTime start = DateTime.parse(widget.period["start"]);
      DateTime end = DateTime.parse(widget.period["end"]);
      if ((now.hour * 60 + now.minute) >= (start.hour * 60 + start.minute) &&
          (now.hour * 60 + now.minute) <= (end.hour * 60 + end.minute)) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColour = Color.fromRGBO(
      widget.lesson["colour"]["red"],
      widget.lesson["colour"]["green"],
      widget.lesson["colour"]["blue"],
      1,
    );

    Color textColour = useWhiteForeground(backgroundColour)
        ? const Color(0xffffffff)
        : const Color(0xff000000);

    return Card(
      margin: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: backgroundColour,
      child: InkWell(
        onTap: () => setState(() => expanded = !expanded),
        splashColor: backgroundColour,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 70,
                    alignment: Alignment.center,
                    child: Text(
                      formatter.format(DateTime.parse(widget.period["start"])),
                      style: TextStyle(
                          color: textColour,
                          fontSize: 20,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(maxWidth: 10),
                  ),
                  Text(
                    widget.lesson["name"],
                    style: TextStyle(
                      color: textColour,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  Visibility(
                    visible: isCurrentLesson,
                    child: Container(
                      decoration: BoxDecoration(
                        color: textColour,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: EdgeInsets.all(5),
                      child: Text(
                        "Now",
                        style: TextStyle(
                          color: backgroundColour,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              ExpandedSection(
                expand: expanded,
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      alignment: Alignment.center,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            child: Text(
                              "to",
                              style: TextStyle(color: textColour, height: 1),
                            ),
                          ),
                          Text(
                            formatter
                                .format(DateTime.parse(widget.period["end"])),
                            style: TextStyle(
                                color: textColour,
                                fontSize: 20,
                                fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      constraints: BoxConstraints(maxWidth: 10),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.lesson["teacher"] != "")
                          Text(
                            "Teacher: " + widget.lesson["teacher"],
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                              color: textColour.withAlpha(155),
                            ),
                          ),
                        if (widget.lesson["room"] != "")
                          Text(
                            "Room: " + widget.lesson["room"],
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                              color: textColour.withAlpha(155),
                            ),
                          ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Day extends StatelessWidget {
  final lessons;
  final periodStructure;
  final List day;
  final int dayNum;

  Day({
    Key key,
    this.lessons,
    this.periodStructure,
    this.day,
    this.dayNum,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: day.map(
        (day) {
          if (day["period"] >= 0 && day["period"] < periodStructure.length) {
            return Period(
              period: periodStructure[day["period"]],
              lesson: lessons[day["lesson"]],
              dayNum: dayNum,
            );
          } else {
            return Container();
          }
        },
      ).toList(),
    );
  }
}
