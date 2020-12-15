import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timetable/services/auth.dart';

// screens
import './loading.dart';

// widgets
import '../widgets/newTimetable.dart';
import '../widgets/periodStructure.dart';
import '../widgets/setupNavigationButtons.dart';
import '../widgets/lessonGenerator.dart';

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
    print(data);
  }

  void _handleNameChange(String name) {
    setState(() {
      _data["timetable_name"] = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (gotTimetable) {
      return Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(
              child: PageView(
                controller: _pageController,
                children: [
                  NewTimetable(
                    name: _data["timetable_name"],
                    updateName: _handleNameChange,
                    pageNavigationButtons: SetupNavigationButtons(
                        changePage: _changePage, pageIndex: pageIndex),
                  ),
                  PeriodStructure(
                    periodStructure: _data["period_structure"],
                    updatePeriod: _handlePeriodStructureChange,
                    pageNavigationButtons: SetupNavigationButtons(
                        changePage: _changePage, pageIndex: pageIndex),
                  ),
                  LessonGenerator(
                    lessons: _data["lessons"],
                    pageNavigationButtons: SetupNavigationButtons(
                        changePage: _changePage, pageIndex: pageIndex),
                  ),
                  IconButton(
                    onPressed: () =>
                        Auth(auth: widget.auth, firestore: widget.firestore)
                            .signOut(),
                    icon: Icon(Icons.exit_to_app),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Loading();
    }
  }
}
