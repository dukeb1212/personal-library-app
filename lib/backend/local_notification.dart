import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:login_test/backend/navigator.dart';
import 'package:rxdart/rxdart.dart';

import '../main.dart';
class LocalNotification {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static final onClickNotification = BehaviorSubject<String>();
  static void onNotificationTap (NotificationResponse notificationResponse) {
    payload = notificationResponse.payload!.replaceAll('""', '');
    onClickNotification.add(notificationResponse.payload!);
  }
// Function to initialize FlutterLocalNotificationsPlugin
  Future<void> initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher'); // Change 'app_icon' to your app's launcher icon
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: onNotificationTap
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'notification_channel', // id
      'Notifications', // title
      description: 'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

// Function to display a notification
  Future<void> displayNotification(String title, String body, String payload) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails('notification_channel', 'Notifications', channelDescription: 'This channel is used for notifications.',
        importance: Importance.max, priority: Priority.high, showWhen: true);
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Change this to a unique ID for each notification
      title,
      body,
      platformChannelSpecifics,
      payload: jsonEncode(payload), // You can add custom payload here
    );
  }
}
