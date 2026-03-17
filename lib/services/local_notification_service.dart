import 'package:flutter/foundation.dart';
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
/// - Cross-platform (Android, iOS, macOS, Linux)
class LocalNotificationService {
  LocalNotificationService._private();
  static final LocalNotificationService instance = LocalNotificationService._private();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  bool get _supportsLocalNotifications {
    if (kIsWeb) return false;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.macOS ||
      TargetPlatform.linux => true,
      _ => false,
    };
  }

  /// Initialize local notifications
  /// Sets up Android notification channel and initialization settings
  /// 
  /// Safe to call multiple times - only initializes once
  Future<void> initialize() async {
    if (_initialized) {
      debugPrint('LocalNotificationService already initialized');
      return;
    }

    if (!_supportsLocalNotifications) {
      debugPrint('Local notifications are not enabled for this platform');
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

      const LinuxInitializationSettings linuxSettings = LinuxInitializationSettings(
        defaultActionName: 'Open notification',
      );

      // Combine all platform settings (no Windows - not supported in this version)
      final InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        macOS: macosSettings,
        linux: linuxSettings,
      );

      // Initialize the plugin
      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _handleNotificationTap,
      );

      // Create Android notification channel with high importance
      await _createAndroidNotificationChannel();

      // Request permissions for iOS 10+
        if (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS) {
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
    if (!_supportsLocalNotifications) return;
    try {
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'sportiq_notifications',
        'SportiQ Notifications',
        channelDescription: 'Notifications for sports equipment alerts',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
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
    if (!_supportsLocalNotifications) return;
    try {
      await _localNotifications.cancel(id);
      debugPrint('Notification $id cancelled');
    } catch (e) {
      debugPrint('Error cancelling notification: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    if (!_supportsLocalNotifications) return;
    try {
      await _localNotifications.cancelAll();
      debugPrint('All notifications cancelled');
    } catch (e) {
      debugPrint('Error cancelling all notifications: $e');
    }
  }

  /// Schedule a repeating notification every [minutes]. Uses `periodicallyShow`.
  ///
  /// Use a small interval (1 minute) for demo purposes. In production be mindful
  /// of platform battery constraints and user expectations.
  Future<void> schedulePeriodicNotification({int id = 0, String title = 'Check your borrowed equipment', String body = 'Reminder to check borrowed equipment', Duration interval = const Duration(minutes: 1)}) async {
    if (!_supportsLocalNotifications) return;
    try {
      // The plugin offers predefined repeat intervals; for custom minute intervals
      // we use a periodic `show` with the closest match. For flexibility we call
      // show every [interval] using a periodic Timer-like approach on Android via
      // `periodicallyShow` with RepeatInterval.everyMinute for 1 minute.
      if (interval == const Duration(minutes:1)) {
        await _localNotifications.periodicallyShow(
          id,
          title,
          body,
          RepeatInterval.everyMinute,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'sportiq_notifications',
              'SportiQ Notifications',
              channelDescription: 'Notifications for sports equipment alerts',
              importance: Importance.max,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidAllowWhileIdle: true,
        );
        debugPrint('Scheduled periodic notification every 1 minute');
      } else {
        // Fallback: show a single notification when custom intervals are requested.
        await showNotification(id: id, title: title, body: body);
      }
    } catch (e) {
      debugPrint('Error scheduling periodic notification: $e');
    }
  }
}
