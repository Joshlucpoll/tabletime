import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class Notifications {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Notifications() {
    init();
  }

  Future<void> init() async {
    tz.initializeTimeZones();

    tz.setLocalLocation(tz.getLocation(
      await FlutterNativeTimezone.getLocalTimezone(),
    ));

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

  tz.TZDateTime _nextInstanceOfLesson() {}

  Future<void> scheduleNotification({int epochTime}) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'lessons',
      'Lessons',
      'Get notified when a lesson is about to start',
      importance: Importance.max,
      priority: Priority.high,
      when: epochTime,
      color: Colors.yellow,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      '<LessonsName>',
      'Your lessons is about to start!',
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      NotificationDetails(
        android: androidPlatformChannelSpecifics,
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  void scheduleTimetableNotifications({
    Map weeks,
    List periodStructure,
    Map lessons,
    var currentWeekData,
    int numberOfWeeks,
  }) {
    int difference = (DateTime.now()
                .difference(DateTime.parse(currentWeekData["date"]))
                .inDays /
            7)
        .truncate();

    int currentWeek = (currentWeekData["week"] + difference) % numberOfWeeks;

    currentWeek = currentWeek == 0 ? currentWeekData["week"] : currentWeek;

    sendNotification();
    weeks.forEach(
      (weekNum, week) => week.forEach(
        (dayName, day) => day.forEach(
          (period) {
            // print(
            // "Week: $weekNum day: $dayName lesson: ${lessons[period["lesson"]]["name"]} start: ${periodStructure[period["period"]]["start"]} end: ${periodStructure[period["period"]]["end"]}");
          },
        ),
      ),
    );
  }

  void sendNotification() async {
    await scheduleNotification(
        epochTime: DateTime.now().millisecondsSinceEpoch);

    List<PendingNotificationRequest> pending =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();

    pending.forEach((request) {
      print("${request.id}  ${request.title} ${request.body}");
    });
  }
}
