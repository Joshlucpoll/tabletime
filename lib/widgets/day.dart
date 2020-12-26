import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';

class Period extends StatelessWidget {
  final lesson;
  final period;

  Period({Key key, this.lesson, this.period}) : super(key: key);

  final DateFormat formatter = DateFormat.Hm();

  @override
  Widget build(BuildContext context) {
    Color backgroundColour = Color.fromRGBO(
      lesson["colour"]["red"],
      lesson["colour"]["green"],
      lesson["colour"]["blue"],
      1,
    );

    Color textColour = useWhiteForeground(backgroundColour)
        ? const Color(0xffffffff)
        : const Color(0xff000000);

    return Card(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: backgroundColour,
      child: ExpansionTile(
        title: Row(
          children: [
            Text(
              formatter.format(DateTime.parse(period["start"])),
              style: TextStyle(color: textColour),
            ),
            Text(
              lesson["name"],
              style: TextStyle(color: textColour, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        children: [
          Text(
            "|",
            style: TextStyle(color: textColour),
          ),
        ],
      ),
    );
  }
}

class Day extends StatelessWidget {
  final lessons;
  final periodStructure;
  final List day;

  Day({Key key, this.lessons, this.periodStructure, this.day})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: day
          .map(
            (day) => Period(
              period: periodStructure[day["period"]],
              lesson: lessons[day["lesson"]],
            ),
          )
          .toList(),
    );
  }
}
