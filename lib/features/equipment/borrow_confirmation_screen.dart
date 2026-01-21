import 'package:flutter/material.dart';

class BorrowConfirmationScreen extends StatelessWidget {
  const BorrowConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Borrow Confirmation"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Confirm Borrowing",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.sports_soccer, size: 40, color: Colors.blue),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Football",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text("Standard size football for matches."),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Borrow Date:"),
                        Text("Jan 21, 2026"),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Return Date:"),
                        Text("Jan 28, 2026"),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Penalty per day:"),
                        Text("\$5.00"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "By confirming, you agree to return the equipment on time to avoid penalties.",
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Equipment borrowed successfully!")),
                      );
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: const Text("Confirm Borrow"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}