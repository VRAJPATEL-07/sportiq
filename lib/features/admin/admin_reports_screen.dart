// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/equipment_provider.dart';
import '../../auth/auth_service_base.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<IAuthService>(context, listen: false);

    // Guard: only admins
    if (auth.current.role != 'admin') {
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/unauthorized'));
      return const SizedBox.shrink();
    }

    return Consumer<EquipmentProvider>(
      builder: (context, provider, _) {
        final items = provider.items;

        // Compute stats
        final totalEquipment = items.length;
        final available = items.where((e) {
          final status = (e['status'] ?? 'available').toString().toLowerCase();
          final qty = (e['quantity'] as int?) ?? 0;
          return status == 'available' && qty > 0;
        }).length;
        final borrowed = items.where((e) {
          final status = (e['status'] ?? '').toString().toLowerCase();
          return status == 'borrowed' || status == 'issued';
        }).length;

        // Count by category
        final Map<String, int> byCategory = {};
        for (final item in items) {
          final cat = (item['category'] ?? 'General').toString();
          byCategory[cat] = (byCategory[cat] ?? 0) + 1;
        }

        // Total quantity across all items
        final totalQty = items.fold<int>(0, (sum, e) => sum + ((e['quantity'] as int?) ?? 0));

        return Scaffold(
          appBar: AppBar(
            title: const Text('Reports & Analytics'),
            centerTitle: true,
            elevation: 0,
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              // EquipmentProvider listens to Firestore in real-time, no manual refresh needed
              await Future.delayed(const Duration(milliseconds: 300));
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Summary cards row
                const Text(
                  'Overview',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    _StatCard(
                      icon: Icons.inventory_2,
                      label: 'Total Items',
                      value: '$totalEquipment',
                      color: Colors.blue,
                    ),
                    _StatCard(
                      icon: Icons.check_circle,
                      label: 'Available',
                      value: '$available',
                      color: Colors.green,
                    ),
                    _StatCard(
                      icon: Icons.assignment_return,
                      label: 'Borrowed',
                      value: '$borrowed',
                      color: Colors.orange,
                    ),
                    _StatCard(
                      icon: Icons.category,
                      label: 'Total Qty',
                      value: '$totalQty',
                      color: Colors.purple,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Equipment by category
                const Text(
                  'Equipment by Category',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (byCategory.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: Text('No equipment data available.')),
                    ),
                  )
                else
                  ...byCategory.entries.map((entry) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.withValues(alpha: 0.15),
                            child: const Icon(Icons.category, color: Colors.blue),
                          ),
                          title: Text(entry.key),
                          trailing: Chip(
                            label: Text('${entry.value} item${entry.value != 1 ? 's' : ''}'),
                            backgroundColor: Colors.blue.withValues(alpha: 0.15),
                          ),
                        ),
                      )),
                const SizedBox(height: 24),

                // Full equipment list with status
                const Text(
                  'Equipment Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: Text('No equipment found.')),
                    ),
                  )
                else
                  ...items.map((item) {
                    final status = (item['status'] ?? 'available').toString().toLowerCase();
                    final isBorrowed = status == 'borrowed' || status == 'issued';
                    final qty = (item['quantity'] as int?) ?? 0;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isBorrowed
                              ? Colors.orange.withValues(alpha: 0.15)
                              : Colors.green.withValues(alpha: 0.15),
                          child: Icon(
                            isBorrowed ? Icons.assignment_return : Icons.check_circle,
                            color: isBorrowed ? Colors.orange : Colors.green,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          item['name']?.toString() ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(item['category']?.toString() ?? 'General'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isBorrowed
                                    ? Colors.orange.withValues(alpha: 0.2)
                                    : Colors.green.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isBorrowed ? 'Borrowed' : 'Available',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isBorrowed ? Colors.orange.shade700 : Colors.green.shade700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text('Qty: $qty', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
            ),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
