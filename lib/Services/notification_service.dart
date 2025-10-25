import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:tour_ease/Services/maps_service.dart';

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
    
    // Initialize with onDidReceiveNotificationResponse callback
    await _local.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

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
      // Convert data to JSON string for payload
      String? payload;
      if (message.data.isNotEmpty) {
        try {
          payload = json.encode(message.data);
        } catch (e) {
          if (kDebugMode) print('Error encoding notification data: $e');
        }
      }

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
        payload: payload,
      );
    }
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    if (kDebugMode) print('Notification opened: ${message.data}');
    _handleNotificationData(message.data);
  }

  // Handle local notification taps
  void _onNotificationResponse(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final Map<String, dynamic> data = json.decode(response.payload!);
        _handleNotificationData(data);
      } catch (e) {
        if (kDebugMode) print('Error parsing notification payload: $e');
      }
    }
  }

  // Handle notification data and check for location information
  void _handleNotificationData(Map<String, dynamic> data) {
    if (kDebugMode) print('Handling notification data: $data');
    
    // Check for route data (pickup + destination)
    if (data.containsKey('pickup_location') && data.containsKey('destination')) {
      _openRouteFromNotification(data['pickup_location'], data['destination']);
    } else if (data.containsKey('start_location') && data.containsKey('end_location')) {
      _openRouteFromNotification(data['start_location'], data['end_location']);
    } else if (data.containsKey('pickup_latitude') && data.containsKey('pickup_longitude') && 
               data.containsKey('destination_latitude') && data.containsKey('destination_longitude')) {
      // Handle route with coordinates
      try {
        final double startLat = double.parse(data['pickup_latitude'].toString());
        final double startLng = double.parse(data['pickup_longitude'].toString());
        final double endLat = double.parse(data['destination_latitude'].toString());
        final double endLng = double.parse(data['destination_longitude'].toString());
        _openRouteWithCoordinatesFromNotification(startLat, startLng, endLat, endLng);
      } catch (e) {
        if (kDebugMode) print('Error parsing route coordinates: $e');
      }
    }
    // Fallback to single location handling
    else if (data.containsKey('location')) {
      _openLocationFromNotification(data['location']);
    } else if (data.containsKey('pickup_location')) {
      _openLocationFromNotification(data['pickup_location']);
    } else if (data.containsKey('destination')) {
      _openLocationFromNotification(data['destination']);
    } else if (data.containsKey('latitude') && data.containsKey('longitude')) {
      try {
        final double lat = double.parse(data['latitude'].toString());
        final double lng = double.parse(data['longitude'].toString());
        _openCoordinatesFromNotification(lat, lng, data['location_label']);
      } catch (e) {
        if (kDebugMode) print('Error parsing coordinates: $e');
      }
    }
  }

  // Open location in maps from notification
  Future<void> _openLocationFromNotification(String location) async {
    if (location.isNotEmpty) {
      final mapsService = MapsService();
      await mapsService.openLocation(location);
    }
  }

  // Open coordinates in maps from notification
  Future<void> _openCoordinatesFromNotification(double lat, double lng, String? label) async {
    final mapsService = MapsService();
    await mapsService.openCoordinates(lat, lng, label: label);
  }

  // Open route directions from notification
  Future<void> _openRouteFromNotification(String startLocation, String endLocation) async {
    if (startLocation.isNotEmpty && endLocation.isNotEmpty) {
      final mapsService = MapsService();
      await mapsService.openDirections(startLocation, endLocation);
    }
  }

  // Open route directions with coordinates from notification
  Future<void> _openRouteWithCoordinatesFromNotification(
    double startLat, double startLng, double endLat, double endLng) async {
    final mapsService = MapsService();
    await mapsService.openDirectionsWithCoordinates(startLat, startLng, endLat, endLng);
  }

  /// Show a local notification with location data
  /// This can be used to test location-based notifications
  Future<void> showLocationNotification({
    required String title,
    required String body,
    String? location,
    double? latitude,
    double? longitude,
    String? locationLabel,
  }) async {
    final Map<String, dynamic> data = {};
    
    if (location != null) {
      data['location'] = location;
    }
    
    if (latitude != null && longitude != null) {
      data['latitude'] = latitude.toString();
      data['longitude'] = longitude.toString();
      if (locationLabel != null) {
        data['location_label'] = locationLabel;
      }
    }

    String? payload;
    if (data.isNotEmpty) {
      try {
        payload = json.encode(data);
      } catch (e) {
        if (kDebugMode) print('Error encoding location data: $e');
      }
    }

    await _local.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
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
      payload: payload,
    );
  }

  /// Show a local notification with route data
  /// This will open directions between two locations when tapped
  Future<void> showRouteNotification({
    required String title,
    required String body,
    String? pickupLocation,
    String? destination,
    double? pickupLatitude,
    double? pickupLongitude,
    double? destinationLatitude,
    double? destinationLongitude,
  }) async {
    final Map<String, dynamic> data = {};
    
    if (pickupLocation != null && destination != null) {
      data['pickup_location'] = pickupLocation;
      data['destination'] = destination;
    }
    
    if (pickupLatitude != null && pickupLongitude != null && 
        destinationLatitude != null && destinationLongitude != null) {
      data['pickup_latitude'] = pickupLatitude.toString();
      data['pickup_longitude'] = pickupLongitude.toString();
      data['destination_latitude'] = destinationLatitude.toString();
      data['destination_longitude'] = destinationLongitude.toString();
    }

    String? payload;
    if (data.isNotEmpty) {
      try {
        payload = json.encode(data);
      } catch (e) {
        if (kDebugMode) print('Error encoding route data: $e');
      }
    }

    await _local.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
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
      payload: payload,
    );
  }
}


