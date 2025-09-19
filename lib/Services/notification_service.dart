import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

// Top-level background handler required by firebase_messaging
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // No heavy work here; app is in background
}

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const AndroidNotificationChannel _androidChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    if (_initialized) return;

    // Local notifications init
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _local.initialize(settings);

    // Create Android channel
    await _local.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(_androidChannel);

    // Ask permissions (iOS, Android 13+)
    final settingsPerm = await _messaging.requestPermission(alert: true, badge: true, sound: true);
    if (kDebugMode) {
      print('FCM permission status: ${settingsPerm.authorizationStatus}');
    }

    // Foreground notification presentation (iOS only)
    await _messaging.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);

    // Set listeners
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    _initialized = true;
  }

  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      if (kDebugMode) print('Error getting FCM token: $e');
      return null;
    }
  }

  void _onForegroundMessage(RemoteMessage message) {
    final RemoteNotification? notification = message.notification;
    if (notification != null) {
      _local.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: message.data.isNotEmpty ? message.data.toString() : null,
      );
    }
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    if (kDebugMode) print('Notification opened: ${message.data}');
    // TODO: route handling if needed
  }
}


