import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'api_client.dart';

/// Top-level handler for background FCM messages (must be top-level function).
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // No-op — OS shows the notification automatically.
  // Add custom logic here if needed (e.g., local DB updates).
}

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize FCM and local notifications. Call once at app startup.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permission (iOS and Android 13+)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      if (kDebugMode) debugPrint('[Push] Permission denied');
      return;
    }

    // Initialize local notifications for foreground display
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create Android notification channel
    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        'muud_default',
        'Muud Notifications',
        description: 'Default notification channel for Muud Health',
        importance: Importance.high,
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen(_showForegroundNotification);

    // Handle taps on notifications when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened from a terminated state notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    // Listen for token refreshes
    _messaging.onTokenRefresh.listen(_onTokenRefresh);
  }

  /// Get the current FCM token and register it with the backend.
  Future<void> registerToken() async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;

      final platform = Platform.isIOS ? 'ios' : 'android';
      await ApiClient.post('/notifications/register-device', body: {
        'token': token,
        'platform': platform,
      });
    } catch (e) {
      if (kDebugMode) debugPrint('[Push] Token registration failed: $e');
    }
  }

  /// Unregister the current device token on logout.
  Future<void> unregisterToken() async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;

      await ApiClient.delete('/notifications/unregister-device?token=$token');
    } catch (e) {
      if (kDebugMode) debugPrint('[Push] Token unregister failed: $e');
    }
  }

  void _onTokenRefresh(String token) {
    final platform = Platform.isIOS ? 'ios' : 'android';
    ApiClient.post('/notifications/register-device', body: {
      'token': token,
      'platform': platform,
    });
  }

  void _showForegroundNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'muud_default',
          'Muud Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: message.data['type'],
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Route based on notification type
    final type = message.data['type'];
    if (kDebugMode) debugPrint('[Push] Tapped notification type: $type');
    // TODO: Navigate to relevant screen based on type
    // e.g., 'chat' -> open chat, 'friend_request' -> open people tab
  }

  void _onNotificationTap(NotificationResponse response) {
    final type = response.payload;
    if (kDebugMode) debugPrint('[Push] Local notification tapped: $type');
    // TODO: Navigate based on type
  }
}
