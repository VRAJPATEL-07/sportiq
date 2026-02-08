import 'package:flutter/material.dart';

class MyBorrowedItemsScreen extends StatelessWidget {
  const MyBorrowedItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Borrowed Items"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Currently Borrowed",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Track your borrowed equipment and due dates.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildBorrowedItemCard(
                    context,
                    title: "Cricket Bat",
                    description: "Wooden bat for cricket games.",
                    icon: Icons.sports_cricket,
                    borrowDate: "Jan 15, 2026",
                    returnDate: "Jan 22, 2026",
                    status: "On Time",
                    hasPenalty: false,
                  ),
                  _buildBorrowedItemCard(
                    context,
                    title: "Basketball",
                    description: "Official size basketball.",
                    icon: Icons.sports_basketball,
                    borrowDate: "Jan 10, 2026",
                    returnDate: "Jan 17, 2026",
                    status: "Overdue",
                    hasPenalty: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBorrowedItemCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required String borrowDate,
    required String returnDate,
    required String status,
    required bool hasPenalty,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 40, color: Colors.blue),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(description),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: hasPenalty ? Colors.red : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Borrowed: $borrowDate"),
                Text("Return: $returnDate"),
              ],
            ),
            if (hasPenalty) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Penalty: \$10.00", style: TextStyle(color: Colors.red)),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/penalty_details');
                    },
                    child: const Text("View Details"),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}