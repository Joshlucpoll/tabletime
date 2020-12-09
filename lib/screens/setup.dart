import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// input widgets
import '../widgets/newTimetable.dart';
import '../widgets/periodStructure.dart';

class Setup extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  const Setup({Key key, this.auth, this.firestore}) : super(key: key);

  @override
  _SetupState createState() => _SetupState();
}

class _SetupState extends State<Setup> {
  final _data = {
    "timetable_name": "Timetable 1",
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
    super.initState();
  }

  @override
  void dispose() {
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
        body: Column(children: <Widget>[
      Expanded(
          child: PageView(controller: _pageController, children: [
        NewTimetable(
          name: _data["timetable_name"],
          updateName: _handleNameChange,
        ),
        PeriodStructure(
            periodStructure: _data["period_structure"],
            updatePeriod: _handlePeriodStructureChange)
      ])),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Visibility(
              visible: pageIndex != 0,
              child: Container(
                  margin: EdgeInsets.all(20.0),
                  child: FlatButton(
                    onPressed: () => _changePage(next: false),
                    child: Text("Back"),
                  ))),
          Container(
              margin: EdgeInsets.all(20.0),
              child: FlatButton(
                // shape: ShapeBorder.,
                onPressed: () => _changePage(next: true),
                child: Text("Next"),
              ))
        ],
      )
    ]));
  }
}
