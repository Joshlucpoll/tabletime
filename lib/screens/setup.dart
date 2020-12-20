import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// screens
import './loading.dart';

// widgets
import '../widgets/setupWidgets/newTimetable.dart';
import '../widgets/setupWidgets/periodStructure.dart';
import '../widgets/setupNavigationButtons.dart';
import '../widgets/setupWidgets/lessonGenerator.dart';
import '../widgets/setupWidgets/addingLessons.dart';

// services
import '../services/database.dart';

class Setup extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  const Setup({Key key, this.auth, this.firestore}) : super(key: key);

  @override
  _SetupState createState() => _SetupState();
}

class _SetupState extends State<Setup> {
  Map<String, dynamic> _data;

  PageController _pageController;
  double pageIndex = 0;
  bool gotTimetable = false;

  void getTimetable() async {
    Database database = Database(firestore: widget.firestore);
    String uid = widget.auth.currentUser.uid;

    if (await database.finishedCurrentTimetable(uid: uid) == false) {
      Map<String, dynamic> data = await database.getTimetableData(uid: uid);
      setState(() {
        _data = data;
        gotTimetable = true;
      });
    }
  }

  void updateTimetable() {
    if (widget.auth.currentUser != null) {
      Database(firestore: widget.firestore)
          .updateTimetableData(uid: widget.auth.currentUser.uid, data: _data);
    }
  }

  void _endSetup() {
    Database(firestore: widget.firestore)
        .setup(uid: widget.auth.currentUser.uid, enable: false);
  }

  @override
  void initState() {
    _pageController = PageController();

    _pageController.addListener(() {
      if (_pageController.hasClients) {
        setState(() {
          pageIndex = _pageController.page;
        });
      }
    });

    getTimetable();
    super.initState();
  }

  @override
  void dispose() {
    updateTimetable();
    _pageController.dispose();
    super.dispose();
  }

  void _changePage({bool next}) {
    if (next) {
      _pageController.animateToPage(pageIndex.toInt() + 1,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    } else {
      _pageController.animateToPage(pageIndex.toInt() - 1,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    }
  }

  void _handleNameChange(String name) {
    setState(() {
      _data["timetable_name"] = name;
    });
    updateTimetable();
  }

  void _handleNumOfWeeksChange(int weeks) {
    setState(() {
      _data["number_of_weeks"] = weeks;
    });
    updateTimetable();
  }

  void _handlePeriodStructureChange(List data) {
    data.sort((a, b) {
      return (DateTime.parse(a["start"]).hour * 60 +
              DateTime.parse(a["start"]).minute)
          .compareTo(DateTime.parse(b["start"]).hour * 60 +
              DateTime.parse(b["start"]).minute);
    });
    setState(() {
      _data["period_structure"] = data;
    });
    updateTimetable();
  }

  void _handleLessonsChange(Map data) {
    setState(() {
      _data["lessons"] = data;
    });
    updateTimetable();
  }

  @override
  Widget build(BuildContext context) {
    if (gotTimetable) {
      return Scaffold(
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: <Widget>[
              Expanded(
                child: PageView(
                  controller: _pageController,
                  children: [
                    NewTimetable(
                      name: _data["timetable_name"],
                      numOfWeeks: _data["number_of_weeks"],
                      updateName: _handleNameChange,
                      updateNumOfWeeks: _handleNumOfWeeksChange,
                      pageNavigationButtons: SetupNavigationButtons(
                        changePage: _changePage,
                        pageIndex: pageIndex,
                      ),
                    ),
                    PeriodStructure(
                      periodStructure: _data["period_structure"],
                      updatePeriod: _handlePeriodStructureChange,
                      pageNavigationButtons: SetupNavigationButtons(
                        changePage: _changePage,
                        pageIndex: pageIndex,
                      ),
                    ),
                    LessonGenerator(
                      lessons: _data["lessons"],
                      updateLessons: _handleLessonsChange,
                      pageNavigationButtons: SetupNavigationButtons(
                        changePage: _changePage,
                        pageIndex: pageIndex,
                      ),
                    ),
                    AddingLessons(
                      endSetup: _endSetup,
                      pageNavigationButtons: SetupNavigationButtons(
                        changePage: _changePage,
                        pageIndex: pageIndex,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Loading();
    }
  }
}
