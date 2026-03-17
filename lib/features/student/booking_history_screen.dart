import 'package:flutter/material.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  static const List<Map<String, dynamic>> _history = [
    {
      'title': 'Basketball',
      'category': 'Ball Sports',
      'borrowedOn': 'Mar 10, 2026',
      'returnedOn': 'Mar 13, 2026',
      'status': 'Returned',
      'penalty': 0.0,
    },
    {
      'title': 'Cricket Bat',
      'category': 'Bat Sports',
      'borrowedOn': 'Mar 5, 2026',
      'returnedOn': 'Mar 8, 2026',
      'status': 'Returned',
      'penalty': 0.0,
    },
    {
      'title': 'Tennis Racket',
      'category': 'Racket Sports',
      'borrowedOn': 'Feb 25, 2026',
      'returnedOn': 'Mar 1, 2026',
      'status': 'Late Return',
      'penalty': 5.0,
    },
  ];

  @override
  Widget build(BuildContext context) {
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
              child: ListView.separated(
                itemCount: _history.length,
                separatorBuilder: (_, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _history[index];
                  final bool late = item['status'] == 'Late Return';
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
                                  color: late
                                      ? Colors.orange.withValues(alpha: 0.15)
                                      : Colors.green.withValues(alpha: 0.15),
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
                                      item['title'] as String,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      item['category'] as String,
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: late
                                      ? Colors.orange.withValues(alpha: 0.15)
                                      : Colors.green.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  item['status'] as String,
                                  style: TextStyle(
                                    color: late ? Colors.orange.shade800 : Colors.green.shade800,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text('Borrowed on: ${item['borrowedOn']}'),
                          const SizedBox(height: 6),
                          Text('Returned on: ${item['returnedOn']}'),
                          const SizedBox(height: 6),
                          Text(
                            'Penalty: \$${(item['penalty'] as num).toStringAsFixed(2)}',
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}