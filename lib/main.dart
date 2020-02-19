// import 'dart:html';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_speed_dial/flutter_speed_dial.dart';


void main() => runApp(StartPage());

class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.white,
        accentColor: Colors.red,
        fontFamily: "Poppins",
      ),
      darkTheme: ThemeData(
        appBarTheme: AppBarTheme(
          color: Colors.grey[850],
        ),
        primaryColor: Colors.grey[900],
        accentColor: Colors.red,
        fontFamily: "Poppins",
      ),
      title: "Tabletime",
      home: Home(),
    );
  }
}



class Home extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return PageView(
      scrollDirection: Axis.vertical,
      physics: PageScrollPhysics(),
      pageSnapping: true,
      dragStartBehavior: DragStartBehavior.start,
      
      children: <Widget>[
        new Week(),
        new Week()
      ],
    );
  }
}

class Week extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController (
      length: 5,
      initialIndex: getDay(),
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          title: Text("Week"),
          centerTitle: true,
          bottom: TabBar(
            dragStartBehavior: DragStartBehavior.down,
            isScrollable: true,
            tabs: [
              Tab(
                child: Text(
                  "MONDAY",
                  style: TextStyle(
                    fontSize: 11,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "TUESDAY",
                  style: TextStyle(
                    fontSize: 11,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "WEDNESDAY",
                  style: TextStyle(
                    fontSize: 11,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "THURSDAY",
                  style: TextStyle(
                    fontSize: 11,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "FRIDAY",
                  style: TextStyle(
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          physics: PageScrollPhysics(),
          children: <Widget>[
            Tab(icon: Icon(Icons.access_alarm),),
            Tab(icon: Icon(Icons.access_alarm),),
            Tab(icon: Icon(Icons.access_alarm),),
            Tab(icon: Icon(Icons.access_alarm),),
            Tab(icon: Icon(Icons.access_alarm),)
          ],
        ),
        bottomNavigationBar: BottomAppBar(
        
        ),
        floatingActionButton: SpeedDial(
          backgroundColor: Colors.black,
          animatedIcon: AnimatedIcons.menu_close,
          closeManually: false,
          children: [
            SpeedDialChild(
              child: Icon(Icons.today),
              backgroundColor: Colors.blue, 
              label: "Tasks"
            ),
            SpeedDialChild(
              child: Icon(Icons.edit),
              backgroundColor: Colors.green, 
              label: "Edit"
            ),
            SpeedDialChild(
              child: Icon(Icons.settings),
              backgroundColor: Colors.grey, 
              label: "Settings"
            )
          ],
        ),
      ),
    );
  }
}
  int getDay() {
    DateTime date = DateTime.now();
    int dayNum = date.weekday;

    // If Saturday or Sunday, day will default to Monday
    if(dayNum > 5) {
      dayNum = 1;
    }

    return dayNum - 1;
  }
