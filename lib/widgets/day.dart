import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import 'package:timetable/screens/home.dart';

// Widgets
import './expandedSelection.dart';

class BlockCard extends StatefulWidget {
  final lesson;
  final period;
  final int dayNum;
  final int weekNum;
  final int selectedWeek;

  BlockCard({
    Key key,
    this.lesson,
    this.period,
    this.dayNum,
    this.weekNum,
    this.selectedWeek,
  }) : super(key: key);
  @override
  _BlockCardState createState() => _BlockCardState();
}

class _BlockCardState extends State<BlockCard> {
  final DateFormat formatter = DateFormat.Hm();
  bool expanded = false;

  bool get isCurrentLesson {
    if (widget.weekNum + 1 == widget.selectedWeek) {
      DateTime now = DateTime.now();
      if (now.weekday == widget.dayNum + 1) {
        DateTime start = DateTime.parse(widget.period["start"]);
        DateTime end = DateTime.parse(widget.period["end"]);
        if ((now.hour * 60 + now.minute) >= (start.hour * 60 + start.minute) &&
            (now.hour * 60 + now.minute) <= (end.hour * 60 + end.minute)) {
          return true;
        }
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
        splashColor: backgroundColour.withOpacity(1),
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

class EditingBlock extends StatelessWidget {
  final period;
  final periodNum;
  final lesson;
  final int dayNum;
  final int weekNum;

  EditingBlock({
    Key key,
    this.period,
    this.periodNum,
    this.lesson,
    this.dayNum,
    this.weekNum,
  }) : super(key: key);

  final DateFormat formatter = DateFormat.Hm();

  @override
  Widget build(BuildContext context) {
    Color backgroundColour = lesson == null
        ? Theme.of(context).cardColor
        : Color.fromRGBO(
            lesson["colour"]["red"],
            lesson["colour"]["green"],
            lesson["colour"]["blue"],
            1,
          );

    Color textColour = lesson == null
        ? Theme.of(context).textTheme.bodyText1.color
        : useWhiteForeground(backgroundColour)
            ? const Color(0xffffffff)
            : const Color(0xff000000);

    return DragTarget<String>(
      onWillAccept: (data) => lesson == null ? true : false,
      onAccept: (data) => InheritedWeeksModify.of(context).addBlockToWeeks(
        block: {"period": periodNum, "lesson": data},
        weekNum: weekNum,
        dayNum: dayNum,
      ),
      builder: (context, List<String> candidateData, rejectedData) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: backgroundColour,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      formatter.format(DateTime.parse(period["start"])),
                      style: TextStyle(
                        color: textColour,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    lesson == null
                        ? "Period " + (periodNum + 1).toString()
                        : lesson["name"],
                    style: TextStyle(
                      color: textColour,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.centerRight,
                    child: Text(
                      formatter.format(DateTime.parse(period["end"])),
                      style: TextStyle(
                        color: textColour,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: lesson != null,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      height: 30,
                      width: 30,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.close,
                        color: textColour,
                      ),
                    ),
                    onTap: () =>
                        InheritedWeeksModify.of(context).removeBlockFromWeeks(
                      weekNum: weekNum,
                      dayNum: dayNum,
                      period: periodNum,
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class Day extends StatelessWidget {
  final List blocks;
  final int dayNum;
  final int weekNum;

  Day({
    Key key,
    this.blocks,
    this.dayNum,
    this.weekNum,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inheritedState = InheritedWeeksModify.of(context);
    return SingleChildScrollView(
      child: Column(
        children: inheritedState.periodStructure.asMap().entries.map<Widget>(
          (period) {
            if (inheritedState.editingLessons) {
              final shortDays = ["mon", "tue", "wed", "thu", "fri"];

              List editingBlocks = inheritedState
                  .weeksEditingState[weekNum.toString()][shortDays[dayNum]];

              for (var editingBlock in editingBlocks) {
                if (editingBlock["period"] == period.key) {
                  return EditingBlock(
                    period: period.value,
                    lesson: inheritedState.lessons[editingBlock["lesson"]],
                    dayNum: dayNum,
                    weekNum: weekNum,
                    periodNum: period.key,
                  );
                }
              }
              return EditingBlock(
                period: period.value,
                lesson: null,
                periodNum: period.key,
                weekNum: weekNum,
                dayNum: dayNum,
              );
            } else {
              for (var block in blocks) {
                if (block["period"] == period.key) {
                  return BlockCard(
                    period: inheritedState.periodStructure[block["period"]],
                    lesson: inheritedState.lessons[block["lesson"]],
                    dayNum: dayNum,
                    weekNum: weekNum,
                    selectedWeek: inheritedState.selectedWeek,
                  );
                }
              }
              return Container();
            }
          },
        ).toList(),
      ),
    );
  }
}
