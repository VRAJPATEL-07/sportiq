import 'package:flutter/material.dart';
import '../../widgets/custom_card.dart';
import 'scan_equipment_screen.dart';

class EquipmentList extends StatelessWidget {
  const EquipmentList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Equipment"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScanEquipmentScreen()),
              );
            },
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan Equipment',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          CustomCard(
            title: "Football",
            description: "Standard size football for matches.",
            icon: Icons.sports_soccer,
          ),
          CustomCard(
            title: "Cricket Bat",
            description: "Wooden bat for cricket games.",
            icon: Icons.sports_cricket,
          ),
          CustomCard(
            title: "Badminton Racket",
            description: "Lightweight racket for badminton.",
            icon: Icons.sports_tennis,
          ),
          CustomCard(
            title: "Basketball",
            description: "Official size basketball.",
            icon: Icons.sports_basketball,
          ),
          CustomCard(
            title: "Tennis Racket",
            description: "Professional tennis racket.",
            icon: Icons.sports_tennis,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Book equipment feature coming soon!")),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Book Equipment',
      ),
    );
  }
}
