import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/local_notification_service.dart';

/// NotificationProvider manages real-time notifications from Firestore
/// 
/// Responsibilities:
/// - Listen to users/{userId}/notifications subcollection
/// - Maintain list of notifications in real-time
/// - Track unread count
/// - Manage notification read status in Firestore
/// - Integrate with LocalNotificationService for system notifications
class NotificationProvider extends ChangeNotifier {
  final LocalNotificationService _notificationService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;
  
  final List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;
  String? _userId;

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

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize real-time listener for current user's notifications
  void initializeForUser(String userId) {
    if (userId.isEmpty) return;
    if (_userId == userId) return; // Already initialized for this user

    _userId = userId;
    debugPrint('🔔 Initializing NotificationProvider for user: $userId');
    _sub?.cancel();
    _isLoading = true;
    notifyListeners();

    _sub = _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _error = null;
      _isLoading = false;
      
      // Track new notifications for system alerts
      final oldIds = _notifications.map((n) => n.id).toSet();
      
      _notifications.clear();
      for (final doc in snapshot.docs) {
        final notification = AppNotification.fromFirestore(doc.id, doc.data());
        _notifications.add(notification);
        
        // If this is a new unread notification and we're not doing initial load,
        // show a system notification
        if (!oldIds.contains(notification.id) && !notification.isRead && oldIds.isNotEmpty) {
          _showSystemNotification(notification);
        }
      }
      
      debugPrint('🔔 Loaded ${_notifications.length} notifications');
      notifyListeners();
    }, onError: (err) {
      debugPrint('❌ Notification listener error: $err');
      _error = err.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Mark a notification as read in Firestore
  Future<void> markAsRead(String notificationId) async {
    final userId = _userId;
    if (userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .update({'read': true});
    } catch (e) {
      debugPrint('❌ Failed to mark notification as read: $e');
    }
  }

  /// Mark all notifications as read in Firestore
  Future<void> markAllAsRead() async {
    final userId = _userId;
    if (userId == null) return;

    final batch = _firestore.batch();
    for (final n in _notifications) {
      if (!n.isRead) {
        final ref = _firestore
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .doc(n.id);
        batch.update(ref, {'read': true});
      }
    }
    await batch.commit();
  }

  /// Remove a notification from Firestore
  Future<void> removeNotification(String notificationId) async {
    final userId = _userId;
    if (userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .delete();
    } catch (e) {
      debugPrint('❌ Failed to delete notification: $e');
    }
  }

  /// Clear all notifications for the user
  Future<void> clearAll() async {
    final userId = _userId;
    if (userId == null) return;

    final batch = _firestore.batch();
    for (final n in _notifications) {
      final ref = _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(n.id);
      batch.delete(ref);
    }
    await batch.commit();
  }

  /// Helper to show system notification
  void _showSystemNotification(AppNotification notification) {
    _notificationService.showNotification(
      id: notification.id.hashCode,
      title: notification.title,
      body: notification.message,
    );
  }

  /// Compatibility methods for older code (can be removed later)
  void startNotificationTimer() {
    debugPrint('Notification timer requested but disabled in favor of real-time Firestore');
  }

  void stopNotificationTimer() {
    debugPrint('Notification timer stop requested');
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
