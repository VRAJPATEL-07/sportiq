import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

// Top-level background message handler required by firebase_messaging
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  // For safety do minimal processing in background: log and return.
  // Avoid heavy work here to remain Spark-plan safe.
  // You may handle data messages here if needed.
  // Do not call platform channels that may crash in background isolates.
}

class NotificationService {
  NotificationService._private();
  static final NotificationService instance = NotificationService._private();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    if (_initialized) return;

    // Setup local notifications (Android and iOS)
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    final InitializationSettings initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _local.initialize(initSettings, onDidReceiveNotificationResponse: (response) {
      final payload = response.payload;
      if (payload != null && payload.isNotEmpty) {
        _handleNavigationFromPayload(payload, navigatorKey);
      }
    });

    // Request notification permissions (iOS/macOS)
    if (Platform.isIOS || Platform.isMacOS) {
      await _messaging.requestPermission(alert: true, badge: true, sound: true);
    }

    // Foreground message handler: show a local notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      try {
        final notification = message.notification;
        final title = notification?.title ?? 'SportiQ';
        final body = notification?.body ?? '';
        final payload = message.data['payload'] ?? message.data['route'] ?? '';

        _showLocalNotification(title: title, body: body, payload: payload);
      } catch (e) {
        // ignore errors to avoid crashes
      }
    });

    // When a notification is opened (app in background), navigate
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final route = message.data['route'] as String?;
      final payload = message.data['payload'] as String?;
      if (route != null && route.isNotEmpty) {
        _handleNavigationFromPayload(route, navigatorKey);
      } else if (payload != null && payload.isNotEmpty) {
        _handleNavigationFromPayload(payload, navigatorKey);
      }
    });

    // Background handler for terminated state
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    _initialized = true;
  }

  Future<void> _showLocalNotification({required String title, required String body, String? payload}) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default',
      channelDescription: 'Default notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);
    try {
      await _local.show(0, title, body, details, payload: payload);
    } catch (e) {
      // ignore
    }
  }

  void _handleNavigationFromPayload(String payload, GlobalKey<NavigatorState> navigatorKey) {
    final nav = navigatorKey.currentState;
    if (nav == null) return;
    try {
      // Expect payload to be a route like '/equipment' or '/student' or '/equipment?id=...'
      if (payload.startsWith('/')) {
        nav.pushNamed(payload);
      }
    } catch (_) {}
  }

  // ═══════════════════════════════════════════════════════════
  // LAB 8: Public methods for testing and triggering notifications
  // ═══════════════════════════════════════════════════════════

  /// Show immediate local notification for testing
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String payload = '',
  }) async {
    try {
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          'sportiq_channel',
          'SportiQ Notifications',
          channelDescription: 'Equipment management notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      );
      await _local.show(id, title, body, details, payload: payload);
      debugPrint('✓ Local notification shown: $title');
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  /// Schedule a notification for delivery after specified delay
  Future<void> scheduleLocalNotification({
    required int id,
    required String title,
    required String body,
    required int secondsDelay,
    String payload = '',
  }) async {
    try {
      final location = tz.local;
      final scheduledDate = tz.TZDateTime.now(location).add(Duration(seconds: secondsDelay));

      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          'sportiq_scheduled',
          'SportiQ Scheduled Notifications',
          channelDescription: 'Scheduled equipment reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      );

      await _local.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
        androidAllowWhileIdle: true,
      );
      debugPrint('✓ Notification scheduled for $secondsDelay seconds: $title');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  /// Get FCM token for Firebase Cloud Messaging testing
  Future<String?> getFCMToken() async {
    try {
      final token = await _messaging.getToken();
      debugPrint('FCM Token: $token');
      return token;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }
}
