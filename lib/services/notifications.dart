import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'timetable.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class ScheduledNotification {
  final DateTime dateTime;
  final LessonData lesson;

  ScheduledNotification({this.dateTime, this.lesson});
}

class Notifications {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final Timetable _timetable = GetIt.I.get<Timetable>();
  tz.Location timeZone;

  Notifications() {
    _init();
  }

  Future<void> _init() async {
    tz.initializeTimeZones();

    timeZone = tz.getLocation(await FlutterNativeTimezone.getLocalTimezone());
    tz.setLocalLocation(timeZone);

    this.flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await this.flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (String payload) async {
        if (payload != null) {
          print('notification payload: $payload');
        }
      },
    );
  }

  Future<void> cancelNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> _scheduleNotification({
    int id,
    DateTime time,
    String lessonName,
    Color colour,
    int beforeMins,
  }) async {
    // Platform settings
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'lessons',
      'Lessons',
      'Get notified when a lesson is about to start',
      importance: Importance.max,
      priority: Priority.high,
      when: time.millisecondsSinceEpoch,
      color: colour,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      lessonName,
      'Your lessons is about to start!',
      tz.TZDateTime.from(
        time.subtract(
          Duration(minutes: beforeMins),
        ),
        timeZone,
      ),
      NotificationDetails(
        android: androidPlatformChannelSpecifics,
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<bool> scheduleTimetableNotifications({int beforeMins}) async {
    if (_timetable.rawTimetable == null) {
      return false;
    }

    // Clear all previously scheduled notifications
    await cancelNotifications();

    final CurrentWeek currentWeekData = _timetable.currentWeek;
    final int numberOfWeeks = _timetable.numberOfWeeks;
    final Map<String, WeekData> weeksData = _timetable.weeks;

    List<ScheduledNotification> notifications = [];

    int difference =
        (DateTime.now().difference(currentWeekData.date).inDays / 7).truncate();

    int currentWeek = (currentWeekData.week + difference) % numberOfWeeks;

    currentWeek = currentWeek == 0 ? currentWeekData.week : currentWeek;
    // Current week starts with 0
    currentWeek--;

    // WeekNum start with 0
    weeksData.forEach(
      (weekNum, weekData) {
        // Only include weeks that current timetable has
        if (int.parse(weekNum) < numberOfWeeks) {
          weekData.week.forEach(
            (dayName, dayData) => dayData.day.forEach(
              (blockData) {
                // Calculate number of weeks until next block
                int diff = int.parse(weekNum) - currentWeek;
                int weekSteps = diff.isNegative ? numberOfWeeks + diff : diff;

                DateTime start = blockData.period.start;
                DateTime now = DateTime.now();
                DateTime lastMonday =
                    now.subtract(Duration(days: now.weekday - 1));
                DateTime startOfMonday = new DateTime(
                  lastMonday.year,
                  lastMonday.month,
                  lastMonday.day,
                );

                DateTime nextBlock;
                // If block this week
                if (weekSteps == 0) {
                  // If block has already occurred this week
                  if (now.weekday > start.weekday) {
                    nextBlock = startOfMonday.add(Duration(
                      days: numberOfWeeks * 7 + start.weekday - 1,
                      hours: start.hour,
                      minutes: start.minute,
                    ));

                    // If block has already occurred this week
                  } else if (now.weekday == start.weekday &&
                      now.hour * 60 + now.minute >=
                          start.hour * 60 + start.minute) {
                    nextBlock = startOfMonday.add(Duration(
                      days: numberOfWeeks * 7 + start.weekday - 1,
                      hours: start.hour,
                      minutes: start.minute,
                    ));
                  }

                  // If block will occur this week
                  else {
                    nextBlock = startOfMonday.add(
                      Duration(
                        days: start.weekday - 1,
                        hours: start.hour,
                        minutes: start.minute,
                      ),
                    );
                  }

                  // If block isn't this week
                } else {
                  nextBlock = startOfMonday.add(
                    Duration(
                      days: weekSteps * 7 + start.weekday - 1,
                      hours: start.hour,
                      minutes: start.minute,
                    ),
                  );
                }

                notifications.add(
                  ScheduledNotification(
                    dateTime: nextBlock,
                    lesson: blockData.lesson,
                  ),
                );
              },
            ),
          );
        }
      },
    );

    // Sort notifications into chronological order
    notifications.sort((m1, m2) {
      var r = m1.dateTime.compareTo(m2.dateTime);
      if (r != 0) return r;
      return m1.dateTime.compareTo(m2.dateTime);
    });

    // Repeat notifications until 50 scheduled notifications has been reached
    int notificationsLength = notifications.length;
    int multiplier = (50 / notificationsLength).ceil();

    for (var i = 1; i < multiplier; i++) {
      for (var j = 0; j < notificationsLength; j++) {
        notifications.add(
          ScheduledNotification(
            dateTime: notifications[j].dateTime.add(
                  Duration(days: numberOfWeeks * 7 * i),
                ),
            lesson: notifications[j].lesson,
          ),
        );
      }
    }
    notifications.removeRange(50, notifications.length);

    // Schedule notifications
    notifications.asMap().forEach(
          (int index, ScheduledNotification element) => _scheduleNotification(
            id: index,
            lessonName: element.lesson.name,
            time: element.dateTime,
            beforeMins: beforeMins,
            colour: element.lesson.colour,
          ),
        );
    return true;
  }
}
