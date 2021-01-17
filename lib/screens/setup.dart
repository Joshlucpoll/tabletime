import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

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
import '../services/auth.dart';

class Setup extends StatefulWidget {
  final Auth _auth = GetIt.I.get<Auth>();
  final Database _database = GetIt.I.get<Database>();

  Setup({Key key}) : super(key: key);

  @override
  _SetupState createState() => _SetupState();
}

class _SetupState extends State<Setup> {
  Map<String, dynamic> _data;

  PageController _pageController;
  double pageIndex = 0;
  bool gotTimetable = false;

  void getTimetable() async {
    Future.delayed(const Duration(seconds: 1), () async {
      Map<String, dynamic> data = await widget._database.getTimetableData();
      setState(() {
        _data = data;
        gotTimetable = true;
      });
    });
  }

  void updateTimetable() {
    if (widget._auth.uid != null) {
      widget._database.updateTimetableData(data: _data);
    }
  }

  void _endSetup() {
    widget._database.setup(enable: false);
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
                    PeriodStructure(),
                    LessonGenerator(),
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
