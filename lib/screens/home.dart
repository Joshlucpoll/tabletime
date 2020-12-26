import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:timetable/screens/loading.dart';

// Screens
import './settings.dart';

// Services
import '../services/database.dart';

// Widgets
import '../widgets/week.dart';

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
  PageController _pageController;
  double pageIndex = 0;

  @override
  void initState() {
    // GetIt.I.get<Database>().updateWeeks();
    GetIt.I
        .get<Database>()
        .streamTimetableData()
        .then((stream) => stream.listen((timetable) {
              setState(() {
                timetableData = timetable.data();
              });
            }));

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
                  height: 25.0),
              FlatButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                onPressed: () {},
                child: Text(
                  "Week " + (pageIndex.round() + 1).toString(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () => widget._database.setup(enable: true),
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
        body: PageView(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          physics: ScrollPhysics(),
          children: new List<Widget>.generate(
            timetableData["number_of_weeks"],
            (int index) => Week(
                lessons: timetableData["lessons"],
                periodStructure: timetableData["period_structure"],
                week: timetableData["weeks"][index.toString()]),
          ),
        ),
      );
    }
  }
}
