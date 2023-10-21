
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/timezone.dart' as tz;
//use latest_all not latest
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:to_do_app/UI/notification_page.dart';
import 'package:to_do_app/models/task.dart';

@immutable
class NotifyHelper {
  final _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final BehaviorSubject<String> notificationSubject =
      BehaviorSubject<String>();

  Future<void> scheduledNotification(BuildContext context,int hour, int minute, Task task) async {
    tz.initializeTimeZones();
    _configureNotificationSubject(context);
    //assignment for _local field in tz
    //without this line you'll get error because _local isn't initialized
    tz.setLocalLocation(
        tz.getLocation(await FlutterTimezone.getLocalTimezone()));

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      task.id!,
      task.title,
      task.note,
      _nextInstanceOfTenAM(hour, minute, task.date!),
      const NotificationDetails(
          android: AndroidNotificationDetails(
        'your channel id',
        'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.max,
      )),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      //DateTimeComponents.time for daily notification at the time you determined
      matchDateTimeComponents: DateTimeComponents.time,
      payload: '${task.title}|${task.note}'
    );
  }

  tz.TZDateTime _nextInstanceOfTenAM(int hour, int minutes, String date) {

    var formattedDate = DateFormat.yMd().parse(date);
    final tz.TZDateTime fd = tz.TZDateTime.from(formattedDate, tz.local);

    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, fd.year, fd.month, fd.day, hour, minutes);

    print('scheduledDate = $scheduledDate');

      // scheduledDate = tz.TZDateTime(tz.local, now.year, now.month,
      //     fd.day + 1, hour, minutes);
      // print('next scheduledDate = $scheduledDate');
    
    return scheduledDate;
  }

  //Immediate notification
  displayNotification({required String title, required String body}) async {
    print("doing test");
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      importance: Importance.max,
      priority: Priority.high,
    );

    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    //Core part of the method (What will be written in the notification)
    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: title,
    );
  }

  void requestIOSPermissions() {
    _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  

  void _configureNotificationSubject(BuildContext context) {
    notificationSubject.stream.listen((String payload) async {
      Navigator.push(context,MaterialPageRoute(builder:(_) =>NotificationPage(payload: payload) ,));
    });
  }

  cancelNotification(int notificationId) async {
    await _flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  initializeNotification() async {
    // this is for latest iOS settings
    //a
    const DarwinInitializationSettings IOSInitializationSettings =
        DarwinInitializationSettings(); //for IOS
    //b
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings("@mipmap/ic_launcher"); //for Android

    //c (a,b)
    InitializationSettings initializationSettings =
        const InitializationSettings(
      iOS: IOSInitializationSettings,
      android: androidInitializationSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        if(details.payload!=null) {
          notificationSubject.add(details.payload!);
        }
      },
    );
    //_configureNotificationSubject();
  }

  // tz.TZDateTime _getScheduledDate(int hour, int minute) {
  //   final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  //   tz.TZDateTime scheduledDate =
  //       tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
  //   if (scheduledDate.isBefore(now)) {
  //     scheduledDate = scheduledDate.add(Duration(days: 1));
  //   }
  //   return scheduledDate;
  // }
}
