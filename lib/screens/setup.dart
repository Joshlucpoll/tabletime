import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// widgets
import '../widgets/newTimetable.dart';
import '../widgets/periodStructure.dart';
import '../widgets/setupNavigationButtons.dart';

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
  Map<String, dynamic> _data = {
    "timetable_name": "My Timetable",
    "finished_setup": false,
    "number_of_weeks": 1,
    "data_created": Timestamp.now(),
    "updated": Timestamp.now(),
    "period_structure": [],
    "lessons": [],
    "weeks": [],
  };

  PageController _pageController;
  double pageIndex = 0;

  void getTimetable() async {
    Database database = Database(firestore: widget.firestore);
    String uid = widget.auth.currentUser.uid;

    if (await database.finishedCurrentTimetable(uid: uid) == false) {
      Map<String, dynamic> data = await database.getTimetableData(uid: uid);
      setState(() {
        _data = data;
      });
    }
  }

  void updateTimetable() {
    Database(firestore: widget.firestore)
        .updateTimetableData(uid: widget.auth.currentUser.uid, data: _data);
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
      return (a["start"].toDate().hour * 60 + a["start"].toDate().minute)
          .compareTo(
              b["start"].toDate().hour * 60 + b["start"].toDate().minute);
    });
    setState(() {
      _data["period_structure"] = data;
    });
  }

  void _handleNameChange(String name) {
    setState(() {
      _data["timetable_name"] = name;
    });
  }

  @override
  Widget build(BuildContext context) {
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
