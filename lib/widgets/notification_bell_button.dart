import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';

/// NotificationBellButton widget
/// 
/// A reusable notification bell button with badge for the AppBar
/// 
/// Features:
/// - Shows bell icon
/// - Displays red badge with unread count
/// - Badge hidden when count is 0
/// - Animated badge appearance
/// - Navigate to notification screen on tap
/// - Clean material design
class NotificationBellButton extends StatelessWidget {
  final VoidCallback? onTap;

  const NotificationBellButton({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, _) {
        final unreadCount = notificationProvider.unreadCount;

        return badges.Badge(
          badgeContent: Text(
            unreadCount > 99 ? '99+' : unreadCount.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          showBadge: unreadCount > 0,
          badgeStyle: badges.BadgeStyle(
            badgeColor: Colors.red,
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(
              color: Colors.white,
              width: 2,
            ),
            elevation: 2,
          ),
          position: badges.BadgePosition.topEnd(top: -8, end: -8),
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _navigateToNotifications(context),
            tooltip: 'Notifications ($unreadCount new)',
          ),
        );
      },
    );
  }

  /// Navigate to notification screen
  void _navigateToNotifications(BuildContext context) {
    // Mark all as read when opening notifications
    context.read<NotificationProvider>().markAllAsRead();
    
    // Navigate to notification screen
    Navigator.of(context).pushNamed('/notifications').then((_) {
      // Optionally refresh or perform actions after returning from notification screen
    });
  }
}
