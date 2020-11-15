import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:restaurant_app/screens/main_menu_screen.dart';

class NotificationCheck extends StatefulWidget {
  @override
  _NotificationCheckState createState() => _NotificationCheckState();
}

class _NotificationCheckState extends State<NotificationCheck> {
  showNotification(String title, String body) async {
    var android = AndroidNotificationDetails(
        'channel id', 'channel NAME', 'channel description');
    var iOS = IOSNotificationDetails();
    var platform = NotificationDetails(android: android, iOS: iOS);
    await flutterLocalNotificationsPlugin.show(0, title, body, platform);
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('payload: $payload');
    }
  }

  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var android = AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = IOSInitializationSettings();
    var initSettings = InitializationSettings(android: android, iOS: iOS);
    flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: onSelectNotification);
    notification();
  }

  void notification() {
    String title = 'New Order';
    String body = 'You have received a new order';
    FirebaseMessaging().configure(onMessage: (Map<String, dynamic> msg) async {
      print('Foreground Message');
      var notification = msg['notification'];
      // var data = msg['data'];
      setState(() {
        title = notification['title'];
        body = notification['body'];
      });
      showNotification(title, body);
      return;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseDatabase.instance.reference().child('kk').onValue,
      builder: (context, snap) {
        if (!snap.hasData) {
          return Text('');
        }
        if (snap.data.snapshot.value == null) {
          return Text('');
        } else {
          return Text('');
        }
      },
    );
  }
}
