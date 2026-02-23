import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/equipment_provider.dart';

class ScanHistoryScreen extends StatelessWidget {
  const ScanHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EquipmentProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('Scan History')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: provider.scanHistoryStream(limit: 100),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No scans recorded yet'));
          }
          final items = snapshot.data!;
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final it = items[index];
              final ts = it['timestamp'];
              final when = (ts is Timestamp) ? ts.toDate().toString() : (ts?.toString() ?? '');
              return ListTile(
                title: Text(it['equipmentId']?.toString() ?? 'Unknown'),
                subtitle: Text('${it['scannedBy'] ?? 'unknown'} • ${it['action'] ?? 'view'}'),
                trailing: Text(when),
              );
            },
          );
        },
      ),
    );
  }
}
