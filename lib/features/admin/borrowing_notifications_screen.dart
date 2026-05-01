import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BorrowingNotificationsScreen extends StatelessWidget {
  const BorrowingNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('MMM dd, yyyy');
    final timeFormatter = DateFormat('hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Borrowing Notifications'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Active Borrowings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Monitor who borrowed which equipment in real-time',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('borrowings')
                    .orderBy('borrowDate', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final borrowings = snapshot.data!.docs;
                  if (borrowings.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory, size: 60, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'No active borrowings',
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: borrowings.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final doc = borrowings[index];
                      final data = doc.data();
                      final equipmentName = data['equipmentName'] ?? 'Unknown Equipment';
                      final userId = data['userId'] ?? '';
                      final userName = data['userName']?.toString().trim().isNotEmpty == true
                          ? data['userName'].toString()
                          : (data['userEmail']?.toString().split('@').first ?? 'Unknown');
                      debugPrint('📌 Borrowing Card - equipmentName: $equipmentName, userName: $userName, userId: $userId');
                      final quantity = data['quantity'] ?? 1;
                      final borrowDate = data['borrowDate'] as Timestamp?;
                      final returnDate = data['returnDate'] as Timestamp?;
                      final purpose = data['purpose'] ?? 'No purpose specified';
                      final totalDays = borrowDate != null && returnDate != null
                          ? returnDate.toDate().difference(borrowDate.toDate()).inDays
                          : null;

                      final isOverdue = returnDate?.toDate().isBefore(DateTime.now()) ?? false;
                      final daysLeft = returnDate?.toDate().difference(DateTime.now()).inDays;

                      return Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          equipmentName,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Borrowed by: $userName',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isOverdue
                                          ? Colors.red.withValues(alpha: 0.1)
                                          : Colors.green.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      isOverdue ? 'OVERDUE' : 'ACTIVE',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isOverdue ? Colors.red : Colors.green,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Borrowed by: $userName',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Quantity: $quantity',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 8),
                                    if (borrowDate != null)
                                      Text(
                                        'Borrowed: ${dateFormatter.format(borrowDate.toDate())} at ${timeFormatter.format(borrowDate.toDate())}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    const SizedBox(height: 8),
                                    if (returnDate != null)
                                      Text(
                                        'Due: ${dateFormatter.format(returnDate.toDate())}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isOverdue ? Colors.red : Colors.green,
                                          fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    if (daysLeft != null && !isOverdue && daysLeft >= 0)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          'Days remaining: $daysLeft',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: daysLeft <= 2 ? Colors.orange : Colors.grey,
                                            fontWeight: daysLeft <= 2 ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    if (totalDays != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          'Borrowed for: $totalDays day${totalDays == 1 ? '' : 's'}',
                                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Purpose: $purpose',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        _showNotificationDialog(
                                          context,
                                          userName,
                                          equipmentName,
                                          userId,
                                        );
                                      },
                                      icon: const Icon(Icons.notifications_active),
                                      label: const Text('Notify'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        _showDetailsDialog(context, data);
                                      },
                                      icon: const Icon(Icons.info_outline),
                                      label: const Text('Details'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationDialog(
    BuildContext context,
    String userName,
    String equipmentName,
    String userId,
  ) {
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Notification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Send notification to $userName'),
            const SizedBox(height: 12),
            Text(
              'About: $equipmentName',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                hintText: 'Enter your message...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final message = messageController.text.trim();
              if (message.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a message')),
                );
                return;
              }

              try {
                // Save notification to Firestore
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('notifications')
                    .add({
                  'title': 'Reminder: $equipmentName',
                  'message': message,
                  'type': 'borrowing_reminder',
                  'equipmentName': equipmentName,
                  'createdAt': FieldValue.serverTimestamp(),
                  'read': false,
                });

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Notification sent to $userName'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to send notification: $e')),
                  );
                }
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Borrowing Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Equipment', data['equipmentName'] ?? 'N/A'),
              _buildDetailRow('Borrower', data['userName'] ?? 'N/A'),
              _buildDetailRow('Quantity', '${data['quantity'] ?? 0}'),
              _buildDetailRow('Purpose', data['purpose'] ?? 'N/A'),
              _buildDetailRow('Status', data['status'] ?? 'N/A'),
              if (data['borrowDate'] != null)
                _buildDetailRow(
                  'Borrowed',
                  DateFormat('MMM dd, yyyy').format((data['borrowDate'] as Timestamp).toDate()),
                ),
              if (data['returnDate'] != null)
                _buildDetailRow(
                  'Due',
                  DateFormat('MMM dd, yyyy').format((data['returnDate'] as Timestamp).toDate()),
                ),
              if (data['penalty'] != null)
                _buildDetailRow('Penalty/Day', '₹${data['penalty']}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
