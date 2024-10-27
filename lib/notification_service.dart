import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_noti/logger_service.dart';
import 'package:push_noti/message_scrreen.dart';

class NotificationServices {
  //initialising firebase message plugin
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  //initialising firebase message plugin
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  //function to initialise flutter local notification plugin to show notifications for android when app is active
  void initLocalNotifications(RemoteMessage message, BuildContext context) async {
    LoggerService.info('initLocalNotifications');
    var androidInitializationSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSettings = const DarwinInitializationSettings();

    var initializationSetting =
        InitializationSettings(android: androidInitializationSettings, iOS: iosInitializationSettings);

    await _flutterLocalNotificationsPlugin.initialize(initializationSetting,
        onDidReceiveNotificationResponse: (payload) {
      // handle interaction when app is active for android
      handleMessage(message,context);
    });
  }

  void firebaseInit(BuildContext context) {
    // getDeviceToken();
    // isTokenRefresh();
    //
    // setupInteractMessage();

    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;

      debugPrint("notifications title:${notification!.title}");
      debugPrint("notifications body:${notification.body}");

      if (Platform.isIOS) {
        forgroundMessage();
      }

      if (Platform.isAndroid) {
        initLocalNotifications(message,context);
        showNotification(message);
      }
    });
  }

  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('user granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('user granted provisional permission');
    } else {
      //appsetting.AppSettings.openNotificationSettings();

      debugPrint('user denied permission');
    }
  }

  // function to show visible notification when app is active
  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      message.notification!.android!.channelId.toString(),
      message.notification!.android!.channelId.toString(),
      importance: Importance.max,
      showBadge: true,
      playSound: true,
    );

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        channel.id.toString(), channel.name.toString(),
        channelDescription: 'your channel description',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        ticker: 'ticker',
        sound: channel.sound
        //     sound: RawResourceAndroidNotificationSound('jetsons_doorbell')
        //  icon: largeIconPath
        );

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true);

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails, iOS: darwinNotificationDetails);

    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
        message.hashCode, // Unique ID for the notification
        message.notification!.title.toString(),
        message.notification!.body.toString(),
        notificationDetails,
      );
    });
  }

  //function to get device token on which we will send the notifications
  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    LoggerService.fatal('fcm token: $token');
    debugPrint('FCM token $token');
    return token!;
  }

  void isTokenRefresh() async {
    messaging.onTokenRefresh.listen((event) {
      event.toString();

      debugPrint('refresh');
    });
  }

  //handle tap on notification when app is in background or terminated
  Future<void> setupInteractMessage(BuildContext context) async {
    // when app is terminated
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      handleMessage(initialMessage, context);
    }

    //when app ins background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      LoggerService.warning('onMessageOpenedApp');
      handleMessage(event,context);
    });
  }

  void handleMessage(RemoteMessage message, BuildContext context) {

    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const MessageScreen(

        )));
    LoggerService.debug('notification tapped');
    if (message.data['type'] == 'msj') {


      // Navigator.push(context,
      //     MaterialPageRoute(builder: (context) => MessageScreen(
      //       id: message.data['id'] ,
      //     )));
    }
  }

  Future forgroundMessage() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}
