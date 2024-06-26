import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationManager {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initializeNotifications() async {
    // Android Initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS Initialization
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // General Initialization Settings
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> showNotification({
    required String fileName,
    String? message,
  }) async {
    // Android Notification Details
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your_channel_id', 'Your channel name',
            importance: Importance.high, priority: Priority.high, number: 1);

    // General Notification Details
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      1,
      'LOGIN SUCCESSFUL',
      '$message,$fileName',
      platformChannelSpecifics,
    );
  }

  static Future<void> showTaskNotification({
    required String fileName,
  }) async {
    // Android Notification Details
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your_channel_id', 'Your channel name',
            importance: Importance.high, priority: Priority.high, number: 1);

    // General Notification Details
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      2,
      'Work Information',
      '$fileName!',
      platformChannelSpecifics,
    );
  }

  // static Future<void> showUserNotification({
  //   required String fileName,
  //   required String message,
  //   required WidgetRef ref,
  // }) async {
  //   const AndroidNotificationDetails androidPlatformChannelSpecifics =
  //       AndroidNotificationDetails('your_channel_id', 'Your channel name',
  //           importance: Importance.high, priority: Priority.high, number: 1);
  //   const NotificationDetails platformChannelSpecifics =
  //       NotificationDetails(android: androidPlatformChannelSpecifics);
  //   await flutterLocalNotificationsPlugin.show(
  //     1,
  //     'Notification',
  //     '$message, $fileName',
  //     platformChannelSpecifics,
  //   );
  //   print(
  //       'Notification created: $message, $fileName'); // Print statement for verification
  //   final notifier = ref.read(notificationProvider.notifier);
  //   notifier.addNotification('$message, $fileName');
  // }
}
