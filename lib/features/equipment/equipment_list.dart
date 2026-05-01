// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_service_base.dart';
import '../../providers/equipment_provider.dart';

class EquipmentList extends StatefulWidget {
  const EquipmentList({super.key});

  @override
  State<EquipmentList> createState() => _EquipmentListState();
}

class _EquipmentListState extends State<EquipmentList> {
  /// All equipment data comes from Firestore via EquipmentProvider
  /// No hardcoded demo data - everything is dynamic

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<EquipmentProvider>().ensureListening();
    });
  }

  IconData _iconForCategory(String? category) {
    switch ((category ?? '').toLowerCase()) {
      case 'ball sports': return Icons.sports_soccer;
      case 'racket sports': return Icons.sports_tennis;
      case 'bat sports': return Icons.sports_cricket;
      default: return Icons.inventory_2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<IAuthService>(context);
    final equipmentProvider = Provider.of<EquipmentProvider>(context);

    // Always use live Firestore data only - no hardcoded fallbacks
    final equipmentItems = equipmentProvider.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Equipment"),
        centerTitle: true,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: auth.current.role == 'admin'
                      ? Colors.orange.withValues(alpha: 0.3)
                      : Colors.blue.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  auth.current.role == 'admin' ? '👤 Admin' : '📚 Student',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: auth.current.role == 'admin'
                        ? Colors.orange.shade800
                        : Colors.blue.shade800,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/scan'),
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan Equipment',
          ),
        ],
      ),
      body: Column(
        children: [
          // Show Firestore error banner if present
          if (equipmentProvider.error != null)
            Container(
              color: Colors.red.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      equipmentProvider.error!,
                      style: const TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          // Equipment list from Firestore
          if (equipmentProvider.isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (equipmentItems.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2, size: 60, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'No equipment available',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: equipmentItems.length,
                itemBuilder: (context, index) {
                  final item = equipmentItems[index];
                  final qty = (item['quantity'] as int?) ?? 0;
                  final avail = (item['available'] as int?) ?? qty;
                  final isAvailable = avail > 0;
                  final icon = _iconForCategory(item['category']?.toString());
                  return _buildEquipmentCard(item, icon, isAvailable, avail, qty);
                },
              ),
            ),
        ],
      ),
      floatingActionButton: auth.current.role == 'admin'
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, '/add_equipment'),
              label: const Text('Add Equipment'),
              icon: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildEquipmentCard(
    Map<String, dynamic> item,
    IconData icon,
    bool isAvailable,
    int available,
    int quantity,
  ) {
    final auth = Provider.of<IAuthService>(context, listen: false);
    final isAdmin = auth.current.role == 'admin';
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isAvailable
                    ? Colors.green.withValues(alpha: 0.2)
                    : Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon,
                  color: isAvailable ? Colors.green : Colors.red, size: 28),
            ),
            title: Text(item['name']?.toString() ?? 'Unknown',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(item['category']?.toString() ?? 'General',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isAvailable
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$available/$quantity Available',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isAvailable
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
            trailing: !isAdmin && isAvailable
                ? ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/borrow_form',
                        arguments: {'equipment': item}),
                    icon: const Icon(Icons.shopping_cart, size: 16),
                    label: const Text('Borrow'),
                  )
              : (!isAdmin && !isAvailable)
              ? Chip(
                    label: const Text('Out of Stock'),
                    backgroundColor: Colors.red.withValues(alpha: 0.2),
                 )
              : null,
            onTap: () => _showEquipmentDetails(item, available, quantity),
          ),
          if (isAdmin)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      final id = item['id']?.toString();
                      if (id != null) {
                        Navigator.pushNamed(
                          context,
                          '/add_equipment',
                          arguments: {'id': id, 'data': item},
                        );
                      }
                    },
                    icon: const Icon(Icons.edit, size: 16, color: Colors.blue),
                    label: const Text('Edit', style: TextStyle(color: Colors.blue)),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _confirmDelete(item),
                    icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                    label: const Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> item) {
    final id = item['id']?.toString();
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete demo item — seed real data first'), backgroundColor: Colors.orange),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Equipment'),
        content: Text('Are you sure you want to delete "${item['name'] ?? 'this item'}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = context.read<EquipmentProvider>();
              try {
                await provider.deleteEquipment(id: id);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('"${item['name']}" deleted successfully')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Delete failed: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  void _showEquipmentDetails(
      Map<String, dynamic> item, int available, int quantity) {
    final auth = Provider.of<IAuthService>(context, listen: false);
    final isAdmin = auth.current.role == 'admin';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item['name']?.toString() ?? 'Equipment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${item['category'] ?? 'General'}'),
            const SizedBox(height: 8),
            Text('Total: $quantity'),
            const SizedBox(height: 8),
            Text('Available: $available'),
            const SizedBox(height: 8),
            Text('Status: ${available > 0 ? '✅ Available' : '❌ Out of Stock'}'),
            if (item['description'] != null) ...[
              const SizedBox(height: 8),
              Text('Description: ${item['description']}'),
            ],
            if (item['penalty'] != null) ...[
              const SizedBox(height: 8),
              Text('Penalty/Day: ₹${item['penalty']}'),
            ],
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
          if (isAdmin && item['id'] != null)
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/add_equipment',
                  arguments: {'id': item['id'], 'data': item},
                );
              },
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Edit'),
            ),
          if (available > 0)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/borrow_form',
                    arguments: {'equipment': item});
              },
              child: const Text('Borrow'),
            ),
        ],
      ),
    );
  }
}
