import 'package:flutter/material.dart';
import '../../services/notification_service.dart';

class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({super.key});

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Test'),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 20),
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lab 8: Notifications & Animations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Test local notifications, scheduled alerts, and FCM integration',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Local Notifications Section
          const Text(
            'Local Notifications',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _showImmediateNotification,
            icon: const Icon(Icons.notifications_active),
            label: const Text('Show Immediate Notification'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _scheduleNotification,
            icon: const Icon(Icons.schedule),
            label: const Text('Schedule Notification (5 sec)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            ),
          ),

          const SizedBox(height: 32),

          // FCM Section
          const Text(
            'Firebase Cloud Messaging',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Send Test Push Notification',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                const Text(
                  '1. Check console logs for FCM Token\n'
                  '2. Go to Firebase Console\n'
                  '3. Cloud Messaging → Send test message\n'
                  '4. Paste token and send\n'
                  '5. Watch for notification popup',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _printFCMToken,
                  icon: const Icon(Icons.vpn_key),
                  label: const Text('Print FCM Token to Console'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Instructions Section
          const Text(
            'Screenshots Checklist',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildChecklistItem(
                  '1',
                  'Immediate Notification',
                  'Tap button above → take screenshot of popup',
                ),
                const Divider(),
                _buildChecklistItem(
                  '2',
                  'Scheduled Notification',
                  'Schedule notification → wait 5s → screenshot when it appears',
                ),
                const Divider(),
                _buildChecklistItem(
                  '3',
                  'Tap Notification',
                  'Tap any notification → screenshot the redirected screen',
                ),
                const Divider(),
                _buildChecklistItem(
                  '4',
                  'FCM Push Notification',
                  'Send from Firebase Console → screenshot result',
                ),
                const Divider(),
                _buildChecklistItem(
                  '5',
                  'Splash Animation',
                  'Restart app → screenshot splash screen fading in',
                ),
                const Divider(),
                _buildChecklistItem(
                  '6',
                  'Dashboard Animation',
                  'Login to Dashboard → screenshot cards with scale animation',
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Tips Section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.yellow.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.yellow.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      'Pro Tips',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '• Keep app OPEN (foreground) for notification popups\n'
                  '• Check console logs for debug messages\n'
                  '• Wait for scheduled notifications (don\'t skip ahead)\n'
                  '• Use Win+Shift+S for quick Windows screenshots\n'
                  '• Organize screenshots in a /screenshots folder',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String num, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                num,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showImmediateNotification() async {
    try {
      // Trigger immediate local notification
      await NotificationService.instance.showLocalNotification(
        id: 1,
        title: 'Equipment Ready!',
        body: 'Your borrowed football is ready for pickup.',
        payload: '/equipment',
      );
      _showSnackBar('✓ Immediate notification triggered', Colors.green);
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
      debugPrint('Error showing notification: $e');
    }
  }

  void _scheduleNotification() async {
    try {
      // Trigger scheduled notification (5 seconds from now)
      await NotificationService.instance.scheduleLocalNotification(
        id: 2,
        title: 'Scheduled Reminder',
        body: 'Return your equipment within 2 hours.',
        secondsDelay: 5,
        payload: '/student',
      );
      _showSnackBar('✓ Notification scheduled (triggers in 5s)', Colors.orange);
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
      debugPrint('Error scheduling notification: $e');
    }
  }

  void _printFCMToken() async {
    try {
      final token = await NotificationService.instance.getFCMToken();
      debugPrint('═' * 60);
      debugPrint('📱 FCM TOKEN FOR LAB 8 TESTING:');
      debugPrint(token ?? 'Token not available');
      debugPrint('═' * 60);
      _showSnackBar('✓ FCM Token printed to console (check Debug tab)',
          Colors.purple);
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
      debugPrint('Error getting FCM token: $e');
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
