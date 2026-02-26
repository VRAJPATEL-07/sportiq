import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/equipment_provider.dart';

/// Simple full-screen view of a single equipment item with borrow/return
/// actions. Used by scanner/manual lookup and equipment list tap.
class EquipmentDetailScreen extends StatefulWidget {
  final Map<String, dynamic> equipment;

  const EquipmentDetailScreen({super.key, required this.equipment});

  @override
  State<EquipmentDetailScreen> createState() => _EquipmentDetailScreenState();
}

class _EquipmentDetailScreenState extends State<EquipmentDetailScreen> {
  late Map<String, dynamic> _equipment;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    // create a local copy to allow status updates without mutating the
    // original map passed by the caller (which might be reused elsewhere).
    _equipment = Map<String, dynamic>.from(widget.equipment);
  }

  Future<void> _changeStatus(String newStatus) async {
    setState(() => _processing = true);
    try {
      await Provider.of<EquipmentProvider>(context, listen: false)
          .updateStatus(_equipment['id']?.toString() ?? '', newStatus);
      if (!mounted) return;
      setState(() {
        _equipment['status'] = newStatus;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Equipment updated: $newStatus')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _equipment['status']?.toString() ?? 'unknown';
    final isAvailable = status.toLowerCase() == 'available';

    return Scaffold(
      appBar: AppBar(
        title: Text(_equipment['name']?.toString() ?? 'Equipment Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _equipment['name']?.toString() ?? '',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('ID: ${_equipment['equipmentId'] ?? _equipment['id'] ?? ''}'),
            const SizedBox(height: 8),
            Text('Category: ${_equipment['category'] ?? '—'}'),
            const SizedBox(height: 8),
            Text('Status: $status'),
            const SizedBox(height: 16),
            if (_processing) const Center(child: CircularProgressIndicator()),
            Row(
              children: [
                if (isAvailable)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _processing
                          ? null
                          : () => _changeStatus('Borrowed'),
                      child: const Text('Issue Equipment'),
                    ),
                  ),
                if (!isAvailable)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _processing
                          ? null
                          : () => _changeStatus('Available'),
                      child: const Text('Return Equipment'),
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
