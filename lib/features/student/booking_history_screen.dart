import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_service_base.dart';
import 'package:intl/intl.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<IAuthService>(context, listen: false);
    final userId = auth.current.userId;
    final formatter = DateFormat('MMM dd, yyyy');

    if (userId == null || userId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Booking History')),
        body: const Center(child: Text('Please login to view booking history')),
      );
    }

    final stream = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('borrowings_history')
        .orderBy('movedAt', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Past Bookings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Review your previous bookings and return status.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: stream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No booking history yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final d = docs[index].data();
                      final title = d['equipmentName']?.toString() ?? 'Unknown';
                      final category = d['category']?.toString() ?? 'General';
                      final borrow = d['borrowDate'];
                      final returned = d['returnedAt'] ?? d['movedAt'] ?? d['createdAt'];
                      DateTime borrowDt = DateTime.now();
                      DateTime returnDt = DateTime.now();
                      if (borrow is Timestamp) borrowDt = borrow.toDate();
                      if (borrow is DateTime) borrowDt = borrow;
                      if (returned is Timestamp) returnDt = returned.toDate();
                      if (returned is DateTime) returnDt = returned;
                      final status = d['status']?.toString() ?? 'Returned';
                      final penalty = (d['penalty'] as num?)?.toDouble() ?? 0.0;
                      final late = status.toLowerCase().contains('overdue') || status.toLowerCase().contains('late');

                      return Card(
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: late ? Colors.orange.withValues(alpha: 0.15) : Colors.green.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.history,
                                      color: late ? Colors.orange : Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          category,
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: late ? Colors.orange.withValues(alpha: 0.15) : Colors.green.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        color: late ? Colors.orange.shade800 : Colors.green.shade800,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text('Borrowed on: ${formatter.format(borrowDt)}'),
                              const SizedBox(height: 6),
                              Text('Returned on: ${formatter.format(returnDt)}'),
                              const SizedBox(height: 6),
                              Text(
                                'Penalty: ₹${penalty.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: late ? Colors.orange.shade700 : Colors.grey.shade700,
                                  fontWeight: late ? FontWeight.w600 : FontWeight.normal,
                                ),
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
}