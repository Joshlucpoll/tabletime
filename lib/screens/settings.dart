import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:timetable/screens/timetables.dart';
import 'package:timetable/widgets/expandedSelection.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:timetable/screens/loading.dart';
import 'package:stacked_themes/stacked_themes.dart';
import '../theme.dart';

// widgets
import 'package:timetable/screens/lessons.dart';
import 'package:timetable/screens/periods.dart';

// Services
import '../services/database.dart';
import '../services/auth.dart';
import '../services/timetable.dart';

class SettingsPage extends StatefulWidget {
  final Database _database = GetIt.I.get<Database>();
  final Auth _auth = GetIt.I.get<Auth>();
  final Timetable _timetable = GetIt.I.get<Timetable>();

  final Function pageRouteBuilder;
  final Function setUpNotifications;

  final showShowcase;

  SettingsPage({
    Key key,
    this.pageRouteBuilder,
    this.showShowcase,
    this.setUpNotifications,
  }) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool timetableData = false;
  TextEditingController _tabletimeNameController;
  int dropdownValue;
  int themePreference = 0;
  NotificationPref notificationPref;
  WeekendEnabled weekendEnabled;
  bool weekendDaysOpen = false;

  @override
  void initState() {
    setState(() {
      themePreference = getThemeManager(context).selectedThemeIndex;
    });
    widget._timetable.onTimeTableChange().listen(
      (update) {
        if (!timetableData) {
          dropdownValue = widget._timetable.numberOfWeeks;
          _tabletimeNameController =
              TextEditingController(text: widget._timetable.timetableName);
          notificationPref = widget._timetable.notificationPref;
          weekendEnabled = widget._timetable.weekendEnabled;

          setState(() {
            timetableData = true;
          });
        }
        getUpdatedTimetable();
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    _tabletimeNameController.dispose();
    super.dispose();
  }

  void getUpdatedTimetable() {
    if (mounted) {
      _tabletimeNameController.text = widget._timetable.timetableName;
      setState(() {
        dropdownValue = widget._timetable.numberOfWeeks;
        notificationPref = widget._timetable.notificationPref;
        weekendEnabled = widget._timetable.weekendEnabled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return !timetableData
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: Text("Settings"),
            ),
            body: ListView(
              children: [
                ListTile(
                  enabled: false,
                  title: Text("Timetable"),
                ),
                ListTile(
                  onTap: () => Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          Timetables(),
                      transitionsBuilder: (
                        context,
                        animation,
                        secondaryAnimation,
                        child,
                      ) =>
                          SlideTransition(
                        position: animation.drive(
                          Tween(
                            begin: Offset(1.0, 0.0),
                            end: Offset.zero,
                          ).chain(
                            CurveTween(
                              curve: Curves.ease,
                            ),
                          ),
                        ),
                        child: Timetables(),
                      ),
                    ),
                  ),
                  leading: Icon(Icons.table_view),
                  title: Text("Timetables"),
                ),
                ListTile(
                  leading: Icon(Icons.tag),
                  trailing: DropdownButton<int>(
                    value: dropdownValue,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    underline: Container(height: 2),
                    onChanged: (int newValue) async {
                      setState(() {
                        dropdownValue = newValue;
                      });
                      final newTimetableData = widget._timetable.rawTimetable;
                      newTimetableData["number_of_weeks"] = newValue;
                      await widget._database
                          .updateTimetableData(data: newTimetableData);
                    },
                    items: <int>[1, 2, 3, 4, 5]
                        .map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(value.toString()),
                      );
                    }).toList(),
                  ),
                  title: Text("Number of Weeks"),
                ),

                Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.weekend),
                      title: Text("Weekend Days"),
                      trailing: Icon(
                        weekendDaysOpen ? Icons.expand_less : Icons.expand_more,
                      ),
                      onTap: () =>
                          setState(() => weekendDaysOpen = !weekendDaysOpen),
                    ),
                    ExpandedSection(
                      expand: weekendDaysOpen,
                      child: Column(
                        children: [
                          ListTile(
                            leading: Checkbox(
                              value: weekendEnabled.saturday,
                              onChanged: (bool selected) async {
                                setState(() {
                                  weekendEnabled = WeekendEnabled(
                                    saturday: selected,
                                    sunday: weekendEnabled.sunday,
                                  );
                                });
                                final newTimetableData =
                                    widget._timetable.rawTimetable;
                                newTimetableData["weekend_enabled"] = {
                                  "saturday": selected,
                                  "sunday": weekendEnabled.sunday,
                                };
                                await widget._database.updateTimetableData(
                                    data: newTimetableData);
                              },
                            ),
                            title: Text("Saturday"),
                          ),
                          ListTile(
                            leading: Checkbox(
                                value: weekendEnabled.sunday,
                                onChanged: (bool selected) async {
                                  setState(() {
                                    weekendEnabled = WeekendEnabled(
                                      saturday: weekendEnabled.saturday,
                                      sunday: selected,
                                    );
                                  });
                                  final newTimetableData =
                                      widget._timetable.rawTimetable;
                                  newTimetableData["weekend_enabled"] = {
                                    "saturday": weekendEnabled.saturday,
                                    "sunday": selected,
                                  };
                                  await widget._database.updateTimetableData(
                                      data: newTimetableData);
                                }),
                            title: Text("Sunday"),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                // ListTile(
                //   leading: Icon(Icons.weekend),
                //   title: Text("Weekend Days"),
                //   trailing: Switch(
                //     onChanged: (opposite) {
                //       setState(() {
                //         weekendEnabled = opposite;
                //       });
                //       final newTimetableData = widget._timetable.rawTimetable;
                //       newTimetableData["weekends"] = opposite;
                //       widget._database
                //           .updateTimetableData(data: newTimetableData);
                //     },
                //     value: weekendEnabled,
                //   ),
                // ),
                ListTile(
                  onTap: () => Navigator.push(
                    context,
                    widget.pageRouteBuilder(
                        context: context, child: LessonGenerator()),
                  ),
                  leading: Icon(Icons.class_),
                  title: Text("Edit Lessons"),
                ),
                ListTile(
                  onTap: () => Navigator.push(
                    context,
                    widget.pageRouteBuilder(
                        context: context, child: PeriodStructure()),
                  ),
                  leading: Icon(Icons.grid_on),
                  title: Text("Edit Periods"),
                ),
                ListTile(
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => new AlertDialog(
                      title: Text("Reset Timetable"),
                      content: Text(
                          "Are you sure you want to reset your timetable? This does not delete your lessons nor periods, just which lessons happen at which period"),
                      actions: [
                        TextButton(
                          style: TextButton.styleFrom(
                            primary:
                                Theme.of(context).textTheme.bodyText1.color,
                          ),
                          child: Text("Cancel"),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            primary: Colors.red,
                          ),
                          child: Text("Reset"),
                          onPressed: () {
                            widget._database.resetWeeksData();
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                  leading: Icon(Icons.local_fire_department),
                  title: Text("Reset Timetable"),
                ),
                if (!kIsWeb) ...[
                  ListTile(
                    enabled: false,
                    title: Text("Notifications"),
                  ),
                  ListTile(
                    leading: Icon(Icons.notifications_active),
                    title: Text("Notifications"),
                    trailing: Switch(
                      onChanged: (opposite) {
                        setState(() {
                          notificationPref = NotificationPref(
                            beforeMins: notificationPref.beforeMins,
                            enabled: opposite,
                          );
                          widget._timetable.setNotificationPref(
                            beforeMins: notificationPref.beforeMins,
                            enabled: opposite,
                          );
                        });
                      },
                      value: notificationPref.enabled,
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.timer),
                    title: Text("Notification Timing"),
                    trailing: Opacity(
                        opacity: 0.6,
                        child: Text(notificationPref.beforeMins.toString() +
                            " minutes")),
                  ),
                  ListTile(
                    title: Slider(
                      label: notificationPref.beforeMins.toString() +
                          " minutes before lesson",
                      min: 0,
                      max: 30,
                      value: notificationPref.beforeMins.toDouble(),
                      divisions: 60,
                      onChanged: (double value) {
                        setState(() {
                          notificationPref = NotificationPref(
                            beforeMins: value.round(),
                            enabled: notificationPref.enabled,
                          );
                        });
                      },
                      onChangeEnd: (double value) =>
                          widget._timetable.setNotificationPref(
                        beforeMins: value.toInt(),
                        enabled: notificationPref.enabled,
                      ),
                    ),
                  ),
                ],
                ListTile(
                  enabled: false,
                  title: Text("More"),
                ),
                ListTile(
                  onTap: () {
                    new Future.delayed(
                      Duration(milliseconds: 1000),
                      widget.showShowcase(),
                    );
                    Navigator.of(context).pop();
                  },
                  leading: Icon(Icons.help),
                  title: Text("Help"),
                ),
                ListTile(
                  leading: Icon(Icons.lightbulb_outline),
                  trailing: DropdownButton<int>(
                    value: themePreference,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    underline: Container(height: 2),
                    onChanged: (int newValue) {
                      setState(() {
                        themePreference = newValue;
                      });
                      AppTheme(context: context)
                          .changeTheme(themeIndex: newValue);
                    },
                    items: <int>[0, 1, 2, 3]
                        .map<DropdownMenuItem<int>>((int value) {
                      List<String> text = ["System", "Light", "Dark", "Dark+"];
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(text[value]),
                      );
                    }).toList(),
                  ),
                  title: Text("App Theme"),
                ),
                ListTile(
                  onTap: () async {
                    const url = 'https://www.buymeacoffee.com/joshlucpoll';
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  leading: Icon(Icons.support),
                  title: Text("Support me"),
                ),
                ListTile(
                  onTap: () async {
                    const url = 'https://tabletime.app';
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  leading: Icon(Icons.language),
                  title: Text("https://tabletime.app"),
                ),
                ListTile(
                  onTap: () {
                    widget._auth.signOut();
                    Navigator.of(context).pop();
                  },
                  leading: Icon(Icons.logout),
                  title: Text("Sign out"),
                ),
              ],
            ),
          );
  }
}
