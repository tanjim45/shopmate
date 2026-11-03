
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  // Request notification permission
  Future<void> requestPermission() async {
    NotificationSettings settings =
        await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint(
      'Notification Permission: ${settings.authorizationStatus}',
    );
  }

  // Get FCM Token
  Future<String?> getFCMToken() async {
    try {
      final token = await _messaging.getToken();

      debugPrint('FCM Token: $token');

      return token;
    } catch (e) {
      debugPrint('FCM Token Error: $e');
      return null;
    }
  }

  // Listen to foreground messages
  void listenToMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground Message Received');

      debugPrint('Title: ${message.notification?.title}');
      debugPrint('Body: ${message.notification?.body}');
    });
  }
}
