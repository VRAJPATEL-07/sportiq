/// AppNotification Model
/// Represents a notification that can be displayed to users
/// 
/// Fields:
/// - id: Unique identifier for the notification
/// - title: Short title of the notification
/// - message: Full message content
/// - timestamp: When the notification was created
/// - isRead: Whether the notification has been marked as read
/// 
/// This model is designed to be scalable for future Firebase Cloud Messaging
/// integration without requiring major changes to the provider logic.
class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  /// Create AppNotification from Firestore document
  factory AppNotification.fromFirestore(String id, Map<String, dynamic> data) {
    return AppNotification(
      id: id,
      title: data['title'] ?? 'Notification',
      message: data['message'] ?? '',
      timestamp: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      isRead: data['read'] ?? data['isRead'] ?? false,
    );
  }

  /// Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'createdAt': timestamp,
      'read': isRead,
    };
  }

  /// Create a copy of this notification with modified fields
  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  String toString() => 'AppNotification(id: $id, title: $title, isRead: $isRead)';
}
