import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get_it/get_it.dart';

// Screens
import './settings.dart';
import 'package:timetable/screens/loading.dart';

// Services
import '../services/database.dart';

// Widgets
import '../widgets/week.dart';
import '../widgets/customScrollPhysics.dart';

class Home extends StatefulWidget {
  final Database _database = GetIt.I.get<Database>();

  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

// https://api.flutter.dev/flutter/widgets/Draggable-class.html

class _HomeState extends State<Home> {
  DocumentReference timetableRef;
  Map<String, dynamic> timetableData;
  Map weeksEditingState;
  PageController _pageController;
  double pageIndex = 0;
  int selectedWeek;

  bool editingLessons = false;

  void initialisePageController(timetable) {
    int difference = (DateTime.now()
                .difference(DateTime.parse(timetable["current_week"]["date"]))
                .inDays /
            7)
        .truncate();

    int currentWeek = (timetable["current_week"]["week"] + difference) %
        timetable["number_of_weeks"];

    currentWeek =
        currentWeek == 0 ? timetable["current_week"]["week"] : currentWeek;

    if (this.mounted) {
      setState(() => selectedWeek = currentWeek);
    }

    _pageController = PageController(initialPage: currentWeek - 1);
    if (this.mounted) {
      setState(() {
        pageIndex = (currentWeek - 1).roundToDouble();
      });
    }

    _pageController.addListener(() {
      if (_pageController.hasClients) {
        if (this.mounted) {
          setState(() {
            pageIndex = _pageController.page;
          });
        }
      }
    });
  }

  @override
  void initState() {
    // widget._database.setWeeks();
    widget._database
        .streamTimetableData()
        .then((stream) => stream.listen((timetable) {
              if (timetableData == null) {
                initialisePageController(timetable.data());
              }
              if (this.mounted) {
                setState(() {
                  timetableData = timetable.data();
                });
              }
            }));
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void addBlockToWeeks({Map<String, dynamic> block, int weekNum, int dayNum}) {
    final shortDays = ["mon", "tue", "wed", "thu", "fri"];

    Map newWeeks = json.decode(json.encode(weeksEditingState));

    newWeeks[weekNum.toString()][shortDays[dayNum]].add(block);

    setState(() => weeksEditingState = newWeeks);
  }

  void removeBlockFromWeeks({int weekNum, int dayNum, int period}) {
    final shortDays = ["mon", "tue", "wed", "thu", "fri"];

    Map newWeeks = json.decode(json.encode(weeksEditingState));

    List dayBlocks = newWeeks[weekNum.toString()][shortDays[dayNum]];

    for (var block in dayBlocks) {
      if (block["period"] == period) {
        newWeeks[weekNum.toString()][shortDays[dayNum]].remove(block);
      }
    }
    setState(() => weeksEditingState = newWeeks);
  }

  void changeCurrentWeek({BuildContext context, int week}) async {
    String retVal = await widget._database.setCurrentWeek(currentWeek: week);
    String outputText =
        retVal == "Success" ? "Current week is now " + week.toString() : retVal;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(outputText),
      ),
    );

    if (retVal == "Success") setState(() => selectedWeek = week);
  }

  void toggleEditingWeeks(bool editing) async {
    if (!editing) {
      if (weeksEditingState.toString() == timetableData["weeks"].toString())
        await widget._database.updateWeeksData(weeks: weeksEditingState);
    }
    setState(() {
      editingLessons = editing;
      if (editing)
        weeksEditingState = json.decode(json.encode(timetableData["weeks"]));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (timetableData == null) {
      return Loading();
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Row(
            children: <Widget>[
              Image(
                image: AssetImage("assets/images/tabletime_logo.png"),
                height: 25.0,
              ),
              editingLessons
                  ? Container(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        "Editing Week " + (pageIndex.round() + 1).toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                    )
                  : FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      onPressed: () => changeCurrentWeek(
                        context: context,
                        week: pageIndex.round() + 1,
                      ),
                      child: Text(
                        "Week " + (pageIndex.round() + 1).toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: selectedWeek == (pageIndex.round() + 1)
                              ? Theme.of(context).textTheme.bodyText1.color
                              : Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .color
                                  .withOpacity(0.5),
                        ),
                      ),
                    ),
            ],
          ),
          actions: editingLessons
              ? [
                  IconButton(
                    icon: Icon(Icons.close),
                    splashRadius: 20,
                    onPressed: () => toggleEditingWeeks(false),
                  ),
                ]
              : [
                  IconButton(
                    onPressed: () => toggleEditingWeeks(true),
                    icon: Icon(Icons.edit),
                    splashRadius: 20,
                  ),
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsPage(),
                      ),
                    ),
                    icon: Icon(Icons.menu),
                    splashRadius: 20,
                  ),
                ],
        ),
        body: InheritedWeeksModify(
          lessons: timetableData["lessons"],
          periodStructure: timetableData["period_structure"],
          editingLessons: editingLessons,
          weeksEditingState: weeksEditingState,
          addBlockToWeeks: addBlockToWeeks,
          removeBlockFromWeeks: removeBlockFromWeeks,
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  physics: const CustomPageViewScrollPhysics(),
                  children: new List<Widget>.generate(
                    timetableData["number_of_weeks"],
                    (int index) => Week(
                      week: timetableData["weeks"][index.toString()],
                      weekNum: index,
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: editingLessons,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: Offset(0, -1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Drag Lessons",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close),
                              splashRadius: 20,
                              onPressed: () => toggleEditingWeeks(false),
                            )
                          ],
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: timetableData["lessons"]
                                .entries
                                .map<Widget>((lesson) {
                              Color backgroundColour = Color.fromRGBO(
                                lesson.value["colour"]["red"],
                                lesson.value["colour"]["green"],
                                lesson.value["colour"]["blue"],
                                1,
                              );
                              Color textColour =
                                  useWhiteForeground(backgroundColour)
                                      ? const Color(0xffffffff)
                                      : const Color(0xff000000);

                              Widget lessonPill = Material(
                                color: Colors.transparent,
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.all(10),
                                  margin: EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                    color: backgroundColour,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    lesson.value["name"],
                                    style: TextStyle(color: textColour),
                                  ),
                                ),
                              );
                              return Draggable<String>(
                                maxSimultaneousDrags: 1,
                                dragAnchor: DragAnchor.child,
                                affinity: Axis.vertical,
                                data: lesson.key,
                                child: lessonPill,
                                feedback: lessonPill,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

class InheritedWeeksModify extends InheritedWidget {
  final lessons;
  final periodStructure;
  final bool editingLessons;
  final Map weeksEditingState;
  final Function removeBlockFromWeeks;
  final Function addBlockToWeeks;

  InheritedWeeksModify({
    Key key,
    this.lessons,
    this.periodStructure,
    this.editingLessons,
    this.weeksEditingState,
    this.addBlockToWeeks,
    this.removeBlockFromWeeks,
    Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;

  static InheritedWeeksModify of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InheritedWeeksModify>();
}
