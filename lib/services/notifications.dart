import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
        AndroidInitializationSettings('ic_stat_name');

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
    DateTime dateTime,
    LessonData lesson,
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
      when: dateTime.millisecondsSinceEpoch,
      color: lesson.colour,
    );

    String name = lesson.name;
    String teacher = lesson.teacher == "" ? "" : " with ${lesson.teacher}";
    String room = lesson.room == "" ? "" : "in room ${lesson.room} ";
    String body =
        "Your $name lesson" + teacher + " " + room + "is about to start";

    tz.TZDateTime tzDateTime = tz.TZDateTime.from(dateTime, timeZone);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      name,
      body,
      tzDateTime.subtract(Duration(minutes: beforeMins)),
      NotificationDetails(
        android: androidPlatformChannelSpecifics,
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> scheduleTimetableNotifications({
    CurrentWeek currentWeekData,
    int numberOfWeeks,
    Map<String, WeekData> weeksData,
    int beforeMins,
  }) async {
    // Clear all previously scheduled notifications
    await cancelNotifications();

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
                final shortDays = ["mon", "tue", "wed", "thu", "fri"];

                // Calculate number of weeks until next block
                int diff = int.parse(weekNum) - currentWeek;
                int weekSteps = diff.isNegative ? numberOfWeeks + diff : diff;

                DateTime start = blockData.period.start;
                // Mon = 0
                int dayNum = shortDays.indexOf(dayName);
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
                  if (now.weekday > dayNum + 1) {
                    nextBlock = startOfMonday.add(Duration(
                      days: numberOfWeeks * 7 + dayNum,
                      hours: start.hour,
                      minutes: start.minute,
                    ));

                    // If block has already occurred this week
                  } else if (now.weekday == dayNum + 1 &&
                      now.hour * 60 + now.minute >=
                          start.hour * 60 + start.minute) {
                    nextBlock = startOfMonday.add(Duration(
                      days: numberOfWeeks * 7 + dayNum,
                      hours: start.hour,
                      minutes: start.minute,
                    ));
                  }

                  // If block will occur this week
                  else {
                    nextBlock = startOfMonday.add(
                      Duration(
                        days: dayNum,
                        hours: start.hour,
                        minutes: start.minute,
                      ),
                    );
                  }

                  // If block isn't this week
                } else {
                  nextBlock = startOfMonday.add(
                    Duration(
                      days: weekSteps * 7 + dayNum,
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

    if (notifications.length != 0) {
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
              lesson: element.lesson,
              dateTime: element.dateTime,
              beforeMins: beforeMins,
            ),
          );
    }
  }
}
