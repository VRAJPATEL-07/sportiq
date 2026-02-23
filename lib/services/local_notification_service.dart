import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// LocalNotificationService handles local notifications
/// 
/// This service is separate from NotificationService which handles Firebase Cloud Messaging.
/// This is specifically for:
/// - Timer-based test notifications
/// - Local notification display
/// - System notification bar integration
/// 
/// Features:
/// - Singleton pattern for single instance
/// - Android channel configuration with high importance
/// - Sound and vibration support
/// - Cross-platform (Android, iOS, macOS, Windows, Linux)
class LocalNotificationService {
  LocalNotificationService._private();
  static final LocalNotificationService instance = LocalNotificationService._private();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialize local notifications
  /// Sets up Android notification channel and initialization settings
  /// 
  /// Safe to call multiple times - only initializes once
  Future<void> initialize() async {
    if (_initialized) {
      debugPrint('LocalNotificationService already initialized');
      return;
    }

    try {
      // Android initialization with custom channel
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher', // Use app icon for notifications
      );

      // iOS initialization
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // macOS initialization
      const DarwinInitializationSettings macosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Combine all platform settings
      final InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        macOS: macosSettings,
      );

      // Initialize the plugin
      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _handleNotificationTap,
      );

      // Create Android notification channel with high importance
      await _createAndroidNotificationChannel();

      // Request permissions for iOS 10+
      if (Platform.isIOS || Platform.isMacOS) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
        
        await _localNotifications
            .resolvePlatformSpecificImplementation<
                MacOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
      }

      _initialized = true;
      debugPrint('LocalNotificationService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing LocalNotificationService: $e');
    }
  }

  /// Create Android notification channel with high importance
  /// 
  /// Configuration:
  /// - ID: 'sportiq_notifications' - unique channel identifier
  /// - Name: 'SportiQ Notifications' - user-visible name
  /// - Description: Used for sports equipment alerts
  /// - Priority: High - shows as banner in Android 13+
  /// - Importance: Max - shows notification above all others
  /// - Sound: Enabled
  /// - Vibration: Enabled
  /// - Enable lights for older Android versions
  Future<void> _createAndroidNotificationChannel() async {
    try {
      final androidPlugin = 
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin == null) return;

      const androidChannel = AndroidNotificationChannel(
        'sportiq_notifications',
        'SportiQ Notifications',
        description: 'Notifications for sports equipment alerts and updates',
        importance: Importance.max,
        enableVibration: true,
        enableLights: true,
        ledColor: Color.fromARGB(255, 255, 0, 0),
        playSound: true,
      );

      await androidPlugin.createNotificationChannel(androidChannel);
      
      debugPrint('Android notification channel created successfully');
    } catch (e) {
      debugPrint('Error creating Android notification channel: $e');
    }
  }

  /// Show a notification
  /// 
  /// Parameters:
  /// - id: Unique identifier for the notification (use hashCode)
  /// - title: Notification title
  /// - body: Notification message body
  /// 
  /// Features:
  /// - Shows in Android notification bar
  /// - Shows on iOS as banner/alert
  /// - Uses configured channel settings
  /// - High importance/priority for visibility
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'sportiq_notifications',
        'SportiQ Notifications',
        channelDescription: 'Notifications for sports equipment alerts',
        importance: Importance.max,
        priority: Priority.high,
        sound: const RawResourceAndroidNotificationSound('notification_sound'),
        icon: '@mipmap/ic_launcher',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        enableLights: true,
        enableVibration: true,
        color: const Color.fromARGB(255, 33, 150, 243),
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        id,
        title,
        body,
        details,
        payload: payload,
      );

      debugPrint('Notification shown: $title');
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  /// Handle notification tap
  /// Called when user taps on a notification
  void _handleNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // TODO: Navigate to notification screen or specific content based on payload
  }

  /// Cancel a notification
  Future<void> cancelNotification(int id) async {
    try {
      await _localNotifications.cancel(id);
      debugPrint('Notification $id cancelled');
    } catch (e) {
      debugPrint('Error cancelling notification: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
      debugPrint('All notifications cancelled');
    } catch (e) {
      debugPrint('Error cancelling all notifications: $e');
    }
  }
}
