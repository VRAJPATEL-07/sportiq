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

    // Guard: if logging out or not admin, show a safe fallback
    if (auth.current.loggingOut || auth.current.role != 'admin') {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Consumer<EquipmentProvider>(
      builder: (context, provider, _) {
        final items = provider.items;

        int effectiveAvail(Map<String, dynamic> e) {
          final total = (e['quantity'] as int?) ?? 0;
          final availableQty = (e['available'] as int?) ?? total;
          return availableQty.clamp(0, total);
        }

        // Compute stats
        final totalEquipment = items.length;
        final totalQty = items.fold<int>(0, (sum, e) => sum + ((e['quantity'] as int?) ?? 0));
        final totalAvailableQty = items.fold<int>(0, (sum, e) => sum + effectiveAvail(e));
        final borrowedQty = (totalQty - totalAvailableQty).clamp(0, totalQty);
        final skusWithStock = items.where((e) => effectiveAvail(e) > 0).length;

        // Count by category
        final Map<String, int> byCategory = {};
        for (final item in items) {
          final cat = (item['category'] ?? 'General').toString();
          byCategory[cat] = (byCategory[cat] ?? 0) + 1;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Reports & Analytics'),
            centerTitle: true,
            elevation: 0,
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 300));
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
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
                      label: 'Available Qty',
                      value: '$totalAvailableQty',
                      color: Colors.green,
                    ),
                    _StatCard(
                      icon: Icons.assignment_return,
                      label: 'Borrowed Qty',
                      value: '$borrowedQty',
                      color: Colors.orange,
                    ),
                    _StatCard(
                      icon: Icons.category,
                      label: 'In-stock SKUs',
                      value: '$skusWithStock',
                      color: Colors.purple,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

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
                    final q = (item['quantity'] as int?) ?? 0;
                    final av = effectiveAvail(item);
                    final isBorrowed = q > 0 && av <= 0;
                    final partial = q > 0 && av > 0 && av < q;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isBorrowed
                              ? Colors.orange.withValues(alpha: 0.15)
                              : (partial
                                  ? Colors.amber.withValues(alpha: 0.15)
                                  : Colors.green.withValues(alpha: 0.15)),
                          child: Icon(
                            isBorrowed
                                ? Icons.assignment_return
                                : (partial ? Icons.pie_chart : Icons.check_circle),
                            color: isBorrowed
                                ? Colors.orange
                                : (partial ? Colors.amber.shade800 : Colors.green),
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
                                    : (partial
                                        ? Colors.amber.withValues(alpha: 0.2)
                                        : Colors.green.withValues(alpha: 0.2)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isBorrowed
                                    ? 'All on loan'
                                    : (partial ? 'Partially Borrowed' : 'Available'),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isBorrowed
                                      ? Colors.orange.shade700
                                      : (partial ? Colors.amber.shade900 : Colors.green.shade700),
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text('Avail: $av/$q', style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
