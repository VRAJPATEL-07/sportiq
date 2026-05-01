import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/auth_service_base.dart';
import '../../providers/borrowing_provider.dart';
import 'package:intl/intl.dart';

class MyBorrowedItemsScreen extends StatefulWidget {
  const MyBorrowedItemsScreen({super.key});

  @override
  State<MyBorrowedItemsScreen> createState() => _MyBorrowedItemsScreenState();
}

class _MyBorrowedItemsScreenState extends State<MyBorrowedItemsScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize borrowing provider for current user
    final auth = Provider.of<IAuthService>(context, listen: false);
    final borrowingProvider = Provider.of<BorrowingProvider>(context, listen: false);
    final userId = auth.current.userId;
    if (userId != null && userId.isNotEmpty) {
      borrowingProvider.initializeForUser(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Borrowed Items"),
      ),
      body: Consumer<BorrowingProvider>(
        builder: (context, borrowingProvider, _) {
          if (borrowingProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (borrowingProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${borrowingProvider.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            );
          }

          final items = borrowingProvider.borrowedItems;

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No borrowed items',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Borrow equipment from the Equipment List',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Currently Borrowed",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'You have ${items.length} borrowed item(s)',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildBorrowedItemCard(context, item);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBorrowedItemCard(BuildContext context, Map<String, dynamic> item) {
    final borrowingProvider = Provider.of<BorrowingProvider>(context, listen: false);
    
    // Parse data from Firestore
    final name = item['equipmentName']?.toString() ?? 'Unknown Equipment';
    final qty = (item['quantity'] as int?) ?? 1;
    final purpose = item['purpose']?.toString() ?? 'Not specified';
    
    // Handle DateTime fields
    final borrowDateRaw = item['borrowDate'];
    final returnDateRaw = item['returnDate'];
    
    DateTime borrowDate = DateTime.now();
    DateTime returnDate = DateTime.now().add(const Duration(days: 1));
    
    if (borrowDateRaw is Timestamp) {
      borrowDate = borrowDateRaw.toDate();
    } else if (borrowDateRaw is DateTime) {
      borrowDate = borrowDateRaw;
    }
    
    if (returnDateRaw is Timestamp) {
      returnDate = returnDateRaw.toDate();
    } else if (returnDateRaw is DateTime) {
      returnDate = returnDateRaw;
    }
    
    final formatter = DateFormat('MMM dd, yyyy');
    final borrowDateStr = formatter.format(borrowDate);
    final returnDateStr = formatter.format(returnDate);
    
    final isOverdue = borrowingProvider.isOverdue(returnDate);
    final status = item['status']?.toString() ?? 'borrowed';
    final displayStatus = isOverdue ? 'Overdue' : (status == 'returned' ? 'Returned' : 'On Time');
    
    final penalty = (item['penalty'] as num?)?.toDouble() ?? 0.0;
    final hasPenalty = isOverdue && status == 'borrowed';

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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.inventory_2, size: 32, color: Colors.blue),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Qty: $qty • Purpose: $purpose',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: hasPenalty
                        ? Colors.red
                        : (status == 'returned' ? Colors.grey : Colors.green),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    displayStatus,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Borrowed: $borrowDateStr", style: const TextStyle(fontSize: 12)),
                Text("Return: $returnDateStr", style: const TextStyle(fontSize: 12)),
              ],
            ),
            if (hasPenalty) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Penalty: ₹${penalty.toStringAsFixed(2)} per day",
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/penalty_details');
                    },
                    child: const Text("View Details"),
                  ),
                ],
              ),
            ],
            if (status == 'borrowed')
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        final auth = Provider.of<IAuthService>(context, listen: false);
                        final uid = auth.current.userId;
                        await borrowingProvider.returnEquipment(
                          borrowingId: item['id']?.toString() ?? '',
                          userId: uid,
                        );
                        if (mounted) {
                          messenger.showSnackBar(
                            const SnackBar(content: Text('✅ Equipment returned successfully')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          messenger.showSnackBar(
                            SnackBar(content: Text('❌ Error: $e')),
                          );
                        }
                      }
                    },
                    child: const Text('Return Equipment'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}