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
  late List<Map<String, dynamic>> _demoEquipment;

  @override
  void initState() {
    super.initState();
    // Initialize demo equipment data
    _demoEquipment = [
      {
        'name': 'Basketball',
        'category': 'Ball Sports',
        'quantity': 10,
        'available': 8,
        'icon': Icons.sports_basketball
      },
      {
        'name': 'Soccer Ball',
        'category': 'Ball Sports',
        'quantity': 15,
        'available': 12,
        'icon': Icons.sports_soccer
      },
      {
        'name': 'Tennis Racket',
        'category': 'Racket Sports',
        'quantity': 8,
        'available': 6,
        'icon': Icons.sports_tennis
      },
      {
        'name': 'Badminton Set',
        'category': 'Racket Sports',
        'quantity': 12,
        'available': 10,
        'icon': Icons.sports_handball
      },
      {
        'name': 'Volleyball',
        'category': 'Ball Sports',
        'quantity': 6,
        'available': 5,
        'icon': Icons.sports_volleyball
      },
      {
        'name': 'Cricket Bat',
        'category': 'Bat Sports',
        'quantity': 5,
        'available': 4,
        'icon': Icons.sports_cricket
      },
      {
        'name': 'Roller Skates',
        'category': 'Accessories',
        'quantity': 4,
        'available': 2,
        'icon': Icons.sports_kabaddi
      },
      {
        'name': 'Skateboard',
        'category': 'Accessories',
        'quantity': 3,
        'available': 1,
        'icon': Icons.sports_gymnastics
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<IAuthService>(context);
    
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
                  color: auth.current.role == 'admin' ? Colors.orange.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  auth.current.role == 'admin' ? '👤 Admin' : '📚 Student',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: auth.current.role == 'admin' ? Colors.orange.shade800 : Colors.blue.shade800,
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
      body: Builder(
        builder: (builderContext) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _demoEquipment.length,
            itemBuilder: (context, index) {
              final item = _demoEquipment[index];
              final isAvailable = (item['available'] as int) > 0;
              final icon = item['icon'] as IconData;
              return _buildEquipmentCard(item, icon, isAvailable);
            },
          );
        },
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
      Map<String, dynamic> item, IconData icon, bool isAvailable) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isAvailable ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: isAvailable ? Colors.green : Colors.red, size: 28),
        ),
        title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(item['category'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isAvailable ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${item['available']}/${item['quantity']} Available',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isAvailable ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
            ),
          ],
        ),
        trailing: isAvailable
            ? ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/borrow_form', arguments: {'equipment': item}),
                icon: const Icon(Icons.shopping_cart, size: 16),
                label: const Text('Borrow'),
              )
            : Chip(
                label: const Text('Out of Stock'),
                backgroundColor: Colors.red.withOpacity(0.2),
              ),
        onTap: () => _showEquipmentDetails(item),
      ),
    );
  }

  void _showEquipmentDetails(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${item['category']}'),
            const SizedBox(height: 8),
            Text('Total: ${item['quantity']}'),
            const SizedBox(height: 8),
            Text('Available: ${item['available']}'),
            const SizedBox(height: 8),
            Text('Status: ${(item['available'] as int) > 0 ? '✅ Available' : '❌ Out of Stock'}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          if ((item['available'] as int) > 0)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/borrow_form', arguments: {'equipment': item});
              },
              child: const Text('Borrow'),
            ),
        ],
      ),
    );
  }
}
