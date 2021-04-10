import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get_it/get_it.dart';

// Screens
import './settings.dart';
import 'package:timetable/screens/loading.dart';
import 'package:timetable/screens/lessons.dart';

// Services
import '../services/database.dart';
import '../services/timetable.dart';
import '../services/notifications.dart';

// Widgets
import '../widgets/week.dart';
import '../widgets/customScrollPhysics.dart';

class Home extends StatefulWidget {
  final Database _database = GetIt.I.get<Database>();
  final Timetable _timetable = GetIt.I.get<Timetable>();
  final Notifications _notifications = GetIt.I.get<Notifications>();

  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  bool timetableData = false;
  String timetableName;
  CurrentWeek currentWeek;
  int numberOfWeeks;
  bool weekends;
  Map<String, LessonData> lessonsData;
  List<PeriodData> periodsData;
  Map<String, WeekData> weeksData;

  Map weeksEditingState;
  PageController _pageController;
  double pageIndex = 0;
  int selectedWeek;

  bool editingLessons = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  GlobalKey _currentWeekButton = GlobalKey();
  GlobalKey _editButton = GlobalKey();
  GlobalKey _body = GlobalKey();

  AnimationController _editingPaneAnimationController;

  void initialisePageController({
    int numberOfWeeks,
    CurrentWeek currentWeekData,
  }) {
    int difference =
        (DateTime.now().difference(currentWeekData.date).inDays / 7).truncate();

    int currentWeek = (currentWeekData.week + difference) % numberOfWeeks;

    currentWeek = currentWeek == 0 ? currentWeekData.week : currentWeek;

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
    widget._timetable.onTimeTableChange().listen(
      (update) {
        getUpdatedTimetable();

        if (!timetableData) {
          initialisePageController(
            numberOfWeeks: widget._timetable.numberOfWeeks,
            currentWeekData: widget._timetable.currentWeek,
          );
          setState(() {
            timetableData = true;
          });
        }
      },
    );

    widget._timetable.getFirstAppLaunch().then((firstLaunch) {
      if (firstLaunch) {
        WidgetsBinding.instance.addPostFrameCallback((_) =>
            ShowCaseWidget.of(_scaffoldKey.currentContext).startShowCase([
              _body,
              _currentWeekButton,
              _editButton,
            ]));
      }
    });

    _editingPaneAnimationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    super.initState();
  }

  void getUpdatedTimetable() {
    if (mounted) {
      setState(() {
        timetableName = widget._timetable.timetableName;
        currentWeek = widget._timetable.currentWeek;
        numberOfWeeks = widget._timetable.numberOfWeeks;
        weekends = widget._timetable.weekends;
        lessonsData = widget._timetable.lessons;
        periodsData = widget._timetable.periods;
        weeksData = widget._timetable.weeks;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _editingPaneAnimationController.dispose();
    super.dispose();
  }

  void addBlockToWeeks({Map<String, dynamic> block, int weekNum, int dayNum}) {
    final shortDays = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"];

    Map newWeeks = json.decode(json.encode(weeksEditingState));

    newWeeks[weekNum.toString()][shortDays[dayNum]].add(block);

    setState(() => weeksEditingState = newWeeks);
  }

  void removeBlockFromWeeks({int weekNum, int dayNum, int period}) {
    final shortDays = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"];

    Map newWeeks = json.decode(json.encode(weeksEditingState));

    List dayBlocks = newWeeks[weekNum.toString()][shortDays[dayNum]];

    for (var block in dayBlocks) {
      if (block["period"] == period) {
        newWeeks[weekNum.toString()][shortDays[dayNum]].remove(block);
        break;
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

  void toggleEditingWeeks({bool editing, bool save}) async {
    if (!editing) {
      if (save) {
        await widget._database.updateWeeksData(weeks: weeksEditingState);
      }
      _editingPaneAnimationController.reverse();
    } else {
      _editingPaneAnimationController.forward();
    }

    setState(() {
      editingLessons = editing;
      if (editing)
        // Temporary state for editing
        weeksEditingState = widget._timetable.rawTimetable["weeks"];
    });
  }

  void setUpNotifications() {
    widget._notifications.scheduleTimetableNotifications();
  }

  void onEventKey(RawKeyEvent event) async {
    if (event.runtimeType.toString() == 'RawKeyDownEvent') {
      if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
        _pageController.nextPage(
            curve: Curves.ease, duration: Duration(milliseconds: 500));
      }
      if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
        _pageController.previousPage(
            curve: Curves.ease, duration: Duration(milliseconds: 500));
      }
    }
  }

  PageRouteBuilder pageRouteBuilder({BuildContext context, Widget child}) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
      ) =>
          SlideTransition(
        position: animation.drive(
          Tween(
            begin: Offset(1.0, 0.0),
            end: Offset.zero,
          ).chain(
            CurveTween(
              curve: Curves.ease,
            ),
          ),
        ),
        child: child,
      ),
    );
  }

  Widget showcase({
    GlobalKey key,
    String title,
    String description,
    Widget child,
  }) {
    return Showcase(
      key: key,
      title: title,
      description: description,
      disableAnimation: true,
      animationDuration: Duration(microseconds: 1),
      contentPadding: EdgeInsets.all(10),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (timetableData == false) {
      return Loading();
    } else {
      return ShowCaseWidget(
        onFinish: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Help Screen Finished"),
              action: SnackBarAction(
                label: "Repeat",
                onPressed: () {
                  WidgetsBinding.instance.addPostFrameCallback((_) =>
                      ShowCaseWidget.of(_scaffoldKey.currentContext)
                          .startShowCase([
                        _body,
                        _currentWeekButton,
                        _editButton,
                      ]));
                },
              ),
            ),
          );
        },
        builder: Builder(
          builder: (context) => Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Row(
                children: <Widget>[
                  Image(
                    image: AssetImage("assets/images/tabletime_logo.png"),
                    height: 25.0,
                  ),
                  showcase(
                    key: _currentWeekButton,
                    title: "Current Week",
                    description: "Tap to change current week",
                    child: editingLessons
                        ? Container(
                            padding: EdgeInsets.only(left: 10),
                            child: Text(
                              "Editing Week " +
                                  (pageIndex.round() + 1).toString(),
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
                                    ? Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .color
                                    : Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .color
                                        .withOpacity(0.5),
                              ),
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
                        onPressed: () {
                          if (weeksEditingState.toString() !=
                              widget._timetable.rawTimetable["weeks"]
                                  .toString()) {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text("Cancel Editing?"),
                                content: Text(
                                    "You are about to discard unsaved changes."),
                                actions: [
                                  FlatButton(
                                    child: Text("Cancel"),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                  FlatButton(
                                    textColor: Colors.red,
                                    child: Text("Continue"),
                                    onPressed: () {
                                      toggleEditingWeeks(
                                          editing: false, save: false);
                                      Navigator.of(context).pop();
                                    },
                                  )
                                ],
                              ),
                            );
                          } else {
                            toggleEditingWeeks(editing: false, save: false);
                          }
                        },
                      ),
                    ]
                  : [
                      showcase(
                        key: _editButton,
                        title: "Edit Button",
                        description: "Tap to edit timetable",
                        child: IconButton(
                          onPressed: () =>
                              toggleEditingWeeks(editing: true, save: true),
                          icon: Icon(Icons.edit),
                          splashRadius: 20,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.push(
                          context,
                          pageRouteBuilder(
                            context: context,
                            child: SettingsPage(
                              showShowcase: () =>
                                  WidgetsBinding.instance.addPostFrameCallback(
                                (_) => ShowCaseWidget.of(
                                  _scaffoldKey.currentContext,
                                ).startShowCase(
                                  [
                                    _body,
                                    _currentWeekButton,
                                    _editButton,
                                  ],
                                ),
                              ),
                              pageRouteBuilder: pageRouteBuilder,
                              setUpNotifications: setUpNotifications,
                            ),
                          ),
                        ),
                        icon: Icon(Icons.settings),
                        splashRadius: 20,
                      ),
                    ],
            ),
            body: InheritedWeeksModify(
              lessons: lessonsData,
              periodStructure: periodsData,
              selectedWeek: selectedWeek,
              editingLessons: editingLessons,
              weeksEditingState: weeksEditingState,
              addBlockToWeeks: addBlockToWeeks,
              removeBlockFromWeeks: removeBlockFromWeeks,
              child: RawKeyboardListener(
                focusNode: FocusNode(),
                onKey: onEventKey,
                autofocus: true,
                child: Stack(
                  children: [
                    Center(
                      child: showcase(
                        key: _body,
                        title: "Lessons View",
                        description: kIsWeb
                            ? "Press arrow keys left/right to switch days\n or press arrow keys up/down to switch weeks"
                            : "Swipe left/right to switch days\n or swipe up/down to switch weeks",
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          width: MediaQuery.of(context).size.width,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Expanded(
                          child: PageView(
                            controller: _pageController,
                            scrollDirection: Axis.vertical,
                            physics: const CustomPageViewScrollPhysics(),
                            children: new List<Widget>.generate(
                              numberOfWeeks,
                              (int index) => Week(
                                week: weeksData[index.toString()],
                                weekNum: index,
                                selectedWeek: selectedWeek,
                                weekends: weekends,
                              ),
                            ),
                          ),
                        ),
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(0.0, 1.0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                                parent: _editingPaneAnimationController,
                                curve: Curves.ease),
                          ),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .shadowColor
                                      .withOpacity(0.1),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Drag Lessons",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      FlatButton(
                                        color: Theme.of(context).canvasColor,
                                        padding: EdgeInsets.all(0),
                                        child: Text("Save"),
                                        onPressed: () => toggleEditingWeeks(
                                          editing: false,
                                          save: true,
                                        ),
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
                                      children: new List.from(
                                        lessonsData.values
                                            .map<Widget>((lesson) =>
                                                DraggablePill(lesson: lesson))
                                            .toList(),
                                      )..add(
                                          Material(
                                            color: Colors.transparent,
                                            child: Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 5),
                                              child: InkWell(
                                                onTap: () => Navigator.push(
                                                  context,
                                                  pageRouteBuilder(
                                                    context: context,
                                                    child: LessonGenerator(),
                                                  ),
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  padding: EdgeInsets.all(7),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .canvasColor
                                                        .withOpacity(0.7),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        lessonsData.isEmpty
                                                            ? Icons.add
                                                            : Icons.edit,
                                                        size: 16,
                                                      ),
                                                      Container(
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                          horizontal: 5,
                                                        ),
                                                        child: Text(
                                                          lessonsData.isEmpty
                                                              ? "Add Lessons"
                                                              : "Edit Lessons",
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}

class DraggablePill extends StatefulWidget {
  final LessonData lesson;

  DraggablePill({Key key, this.lesson}) : super(key: key);

  @override
  _DraggablePillState createState() => _DraggablePillState();
}

class _DraggablePillState extends State<DraggablePill> {
  Offset position = Offset(0.0, 0.0);

  @override
  Widget build(BuildContext context) {
    Color backgroundColour = widget.lesson.colour;
    Color textColour = useWhiteForeground(backgroundColour)
        ? const Color(0xffffffff)
        : const Color(0xff000000);

    Widget lessonPill(bool dragging) => Material(
          color: Colors.transparent,
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(7),
            margin: EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: backgroundColour,
              borderRadius: BorderRadius.circular(
                dragging ? 10 : 20,
              ),
            ),
            child: Text(
              widget.lesson.name,
              style: TextStyle(color: textColour),
            ),
          ),
        );

    Widget remainingChild = Material(
      color: Colors.transparent,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(4),
        margin: EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: backgroundColour,
          ),
          color: backgroundColour.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          widget.lesson.name,
          style: TextStyle(color: Colors.transparent),
        ),
      ),
    );

    return Align(
      alignment: Alignment(position.dx, position.dy),
      child: Draggable<String>(
        maxSimultaneousDrags: 1,
        dragAnchor: DragAnchor.child,
        affinity: Axis.vertical,
        data: widget.lesson.id,
        child: lessonPill(false),
        feedback: lessonPill(true),
        childWhenDragging: remainingChild,
        onDraggableCanceled: (velocity, offset) {
          setState(() {
            position = offset;
          });
        },
      ),
    );
  }
}

class InheritedWeeksModify extends InheritedWidget {
  final Map<String, LessonData> lessons;
  final List<PeriodData> periodStructure;
  final int selectedWeek;
  final bool editingLessons;
  final Map weeksEditingState;
  final Function removeBlockFromWeeks;
  final Function addBlockToWeeks;

  InheritedWeeksModify({
    Key key,
    this.lessons,
    this.periodStructure,
    this.selectedWeek,
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
