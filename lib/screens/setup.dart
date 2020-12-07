import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// input widgets
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
    "number_of_weeks": 1,
    "data_created": Timestamp.now(),
    "updated": Timestamp.now(),
    "period_structure": [],
    "lessons": [],
    "weeks": [],
  };

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            child: PeriodStructure(
                periodStructure: _data["period_structure"],
                updatePeriod: _handlePeriodStructureChange)));
  }
}
