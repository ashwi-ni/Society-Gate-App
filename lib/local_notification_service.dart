import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static void initialize() {
    // initializationSettings for Android
    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
    );

    // Initialize without onSelectNotification
    _notificationsPlugin.initialize(
      initializationSettings,
      // Use onDidReceiveNotificationResponse instead
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        print("onDidReceiveNotificationResponse");
        String? payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          print("Router Value1234 $payload");

          // Navigator.of(context).push(
          //   MaterialPageRoute(
          //     builder: (context) => DemoScreen(
          //       id: payload,
          //     ),
          //   ),
          // );
        }
      },
    );
  }

  static void createAndDisplayNotification(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          "pushnotificationapp",
          "pushnotificationappchannel",
          channelDescription: "This channel is used for important notifications.",
          importance: Importance.max,
          priority: Priority.high,
        ),
      );

      await _notificationsPlugin.show(
        id,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
        payload: message.data['_id'],
      );
    } on Exception catch (e) {
      print(e);
    }
  }
}
