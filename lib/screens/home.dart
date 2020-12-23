import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:timetable/screens/loading.dart';

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
  PageController _pageController;
  double pageIndex = 0;
  bool gotTimetable = false;

  @override
  void initState() {
    getTimetable();
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

  void getTimetable() async {
    DocumentReference timetableRef =
        await widget._database.getCurrentTimetable();
    print(timetableRef);

    setState(() {
      timetableRef = timetableRef;
      gotTimetable = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: widget._database.streamTimetableData(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Loading();
        } else if (snapshot.connectionState == ConnectionState.active) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Row(
                children: <Widget>[
                  Image(
                      image: AssetImage("assets/images/tabletime_logo.png"),
                      height: 25.0),
                  FlatButton(
                    onPressed: () {},
                    child: Text(
                      "Week " + (pageIndex.round() + 1).toString(),
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
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
                  onPressed: () {},
                  icon: Icon(Icons.menu),
                  splashRadius: 20,
                ),
              ],
            ),
            body: PageView(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              physics: ScrollPhysics(),
              children: new List<Widget>.filled(
                snapshot.data["number_of_weeks"],
                Week(),
              ),
            ),
          );
        } else {
          return Text("error");
        }
      },
    );
  }
}
