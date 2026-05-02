import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_service_base.dart';
import '../../providers/equipment_provider.dart';

/// Full-screen view of a single equipment item with real-time data from
/// Firestore and a proper borrow flow that creates borrowing records.
class EquipmentDetailScreen extends StatelessWidget {
  final Map<String, dynamic> equipment;

  const EquipmentDetailScreen({super.key, required this.equipment});

  @override
  Widget build(BuildContext context) {
    final docId = equipment['id']?.toString();

    // If we have a Firestore doc id, stream real-time updates
    if (docId != null && docId.isNotEmpty) {
      return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('equipment')
            .doc(docId)
            .snapshots(),
        builder: (context, snapshot) {
          // Use live data when available, otherwise fall back to passed-in data
          Map<String, dynamic> liveData;
          if (snapshot.hasData && snapshot.data!.exists) {
            liveData = Map<String, dynamic>.from(snapshot.data!.data()!);
            liveData['id'] = snapshot.data!.id;
          } else {
            liveData = equipment;
          }
          return _DetailBody(equipment: liveData);
        },
      );
    }

    // No doc id — just show the static data
    return _DetailBody(equipment: equipment);
  }
}

class _DetailBody extends StatelessWidget {
  final Map<String, dynamic> equipment;
  const _DetailBody({required this.equipment});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<IAuthService>(context, listen: false);
    final isAdmin = auth.current.role == 'admin';

    final name = equipment['name']?.toString() ?? 'Unknown Equipment';
    final category = equipment['category']?.toString() ?? 'General';
    final totalQty = (equipment['quantity'] as int?) ?? 0;
    final available = (equipment['available'] as int?) ?? totalQty;
    final status = equipment['status']?.toString() ?? 'unknown';
    final description = equipment['description']?.toString();
    final penalty = equipment['penalty'];
    final isAvailable = available > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Equipment header card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isAvailable
                                ? Colors.green.withValues(alpha: 0.15)
                                : Colors.red.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.inventory_2,
                            size: 40,
                            color: isAvailable ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isAvailable
                                      ? Colors.green.withValues(alpha: 0.15)
                                      : Colors.red.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  isAvailable ? '✅ Available' : '❌ Out of Stock',
                                  style: TextStyle(
                                    color: isAvailable ? Colors.green.shade700 : Colors.red.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Details card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _DetailRow(label: 'Category', value: category),
                    _DetailRow(label: 'Total Quantity', value: '$totalQty'),
                    _DetailRow(
                      label: 'Available',
                      value: '$available / $totalQty',
                      valueColor: isAvailable ? Colors.green : Colors.red,
                    ),
                    _DetailRow(label: 'Status', value: status.toUpperCase()),
                    if (description != null && description.isNotEmpty)
                      _DetailRow(label: 'Description', value: description),
                    if (penalty != null)
                      _DetailRow(label: 'Penalty/Day', value: '₹$penalty'),
                    _DetailRow(
                      label: 'Equipment ID',
                      value: equipment['id']?.toString() ?? 'N/A',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            if (!isAdmin && isAvailable)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/borrow_form',
                      arguments: {'equipment': equipment},
                    );
                  },
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Borrow This Equipment'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

            if (!isAdmin && !isAvailable)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.block),
                  label: const Text('Out of Stock'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.grey,
                  ),
                ),
              ),

            if (isAdmin) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/add_equipment',
                      arguments: {'id': equipment['id'], 'data': equipment},
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Equipment'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
