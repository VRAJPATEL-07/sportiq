import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/local_notification_service.dart';

/// NotificationProvider manages in-app notifications
/// 
/// Responsibilities:
/// - Maintain list of notifications
/// - Track unread count
/// - Manage notification read/unread status
/// - Generate static test notifications using Timer
/// - Integrate with LocalNotificationService for system notifications
/// - Handle proper disposal and memory management
/// 
/// Future: Replace Timer-based generation with Firebase Cloud Messaging integration
/// TODO: Replace Timer with FCM integration in future versions
class NotificationProvider extends ChangeNotifier {
  final LocalNotificationService _notificationService;
  
  final List<AppNotification> _notifications = [];
  Timer? _notificationTimer;
  
  // List of static notification messages for demo purposes
  static const List<Map<String, String>> _staticMessages = [
    {
      'title': 'Equipment Available',
      'message': 'Football Kit is now available for borrowing'
    },
    {
      'title': 'Return Reminder',
      'message': 'Your borrowed Cricket Bat is due tomorrow'
    },
    {
      'title': 'Policy Update',
      'message': 'Admin updated equipment rental policy'
    },
    {
      'title': 'New Equipment',
      'message': 'New equipment added to inventory: Basketball'
    },
    {
      'title': 'Damage Report',
      'message': 'Your reported damaged racket has been processed'
    },
    {
      'title': 'Reservation Confirmed',
      'message': 'Your equipment reservation has been confirmed'
    },
    {
      'title': 'Event Notification',
      'message': 'Upcoming sports event: Inter-college tournament'
    },
    {
      'title': 'Maintenance Notice',
      'message': 'Equipment under maintenance, available soon'
    },
  ];

  NotificationProvider({required LocalNotificationService notificationService})
      : _notificationService = notificationService;

  /// Get all notifications
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  /// Get count of unread notifications
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Get total notification count
  int get totalCount => _notifications.length;

  /// Check if there are any unread notifications
  bool get hasUnreadNotifications => unreadCount > 0;

  /// Add a new notification to the list
  /// This method is called by the timer every 30 seconds
  /// Also triggers a system notification
  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification); // Add to beginning
    notifyListeners();
    
    // Show system notification
    _notificationService.showNotification(
      id: notification.id.hashCode,
      title: notification.title,
      body: notification.message,
    );
  }

  /// Mark a notification as read
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  /// Mark all notifications as read
  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    notifyListeners();
  }

  /// Remove a specific notification
  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  /// Clear all notifications
  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  /// Generate a random static notification message
  Map<String, String> _generateRandomMessage() {
    final random = Random();
    return _staticMessages[random.nextInt(_staticMessages.length)];
  }

  /// Start generating notifications with a timer
  /// Generates a new notification every 30 seconds
  /// 
  /// Safety:
  /// - Only starts if timer is not already running
  /// - Timer is properly cancelled in dispose()
  void startNotificationTimer() {
    if (_notificationTimer != null && _notificationTimer!.isActive) {
      debugPrint('Notification timer already running');
      return;
    }

    debugPrint('Starting notification timer - will generate notification every 30 seconds');
    
    // Generate first notification immediately
    _generateAndAddNotification();
    
    // Then generate one every 30 seconds
    _notificationTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) {
        _generateAndAddNotification();
      },
    );
  }

  /// Stop the notification timer
  void stopNotificationTimer() {
    _notificationTimer?.cancel();
    _notificationTimer = null;
    debugPrint('Notification timer stopped');
  }

  /// Internal method to generate and add a notification
  void _generateAndAddNotification() {
    final message = _generateRandomMessage();
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: message['title']!,
      message: message['message']!,
      timestamp: DateTime.now(),
      isRead: false,
    );
    addNotification(notification);
  }

  /// Override dispose to ensure timer is properly cleaned up
  /// This prevents memory leaks and ensures proper resource management
  @override
  void dispose() {
    _notificationTimer?.cancel();
    _notificationTimer = null;
    super.dispose();
  }
}
