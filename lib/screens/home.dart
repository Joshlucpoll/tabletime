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

  void changeCurrentWeek({BuildContext context, int week}) async {
    String retVal = await widget._database.setCurrentWeek(currentWeek: week);
    String outputText =
        retVal == "Success" ? "Current Week is now " + week.toString() : retVal;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(outputText),
      ),
    );
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
                onPressed: () => changeCurrentWeek(
                  context: context,
                  week: pageIndex.round() + 1,
                ),
                child: Text(
                  "Week " + (pageIndex.round() + 1).toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
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
              week: timetableData["weeks"][index.toString()],
            ),
          ),
        ),
      );
    }
  }
}
