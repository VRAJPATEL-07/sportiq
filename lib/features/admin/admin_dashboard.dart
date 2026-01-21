import 'package:flutter/material.dart';
import 'add_edit_equipment_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Admin Panel",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Manage equipment, students, and system settings.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            const Text(
              "Management Options",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildManagementTile(
                    context,
                    icon: Icons.inventory,
                    title: "Add Equipment",
                    subtitle: "Add new sports equipment to the system",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddEditEquipmentScreen()),
                      );
                    },
                  ),
                  _buildManagementTile(
                    context,
                    icon: Icons.edit,
                    title: "Manage Equipment",
                    subtitle: "Edit or remove existing equipment",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Manage Equipment feature coming soon!")),
                      );
                    },
                  ),
                  _buildManagementTile(
                    context,
                    icon: Icons.people,
                    title: "Manage Students",
                    subtitle: "View and manage student accounts",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Manage Students feature coming soon!")),
                      );
                    },
                  ),
                  _buildManagementTile(
                    context,
                    icon: Icons.bar_chart,
                    title: "Reports",
                    subtitle: "View usage reports and analytics",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Reports feature coming soon!")),
                      );
                    },
                  ),
                  _buildManagementTile(
                    context,
                    icon: Icons.settings,
                    title: "System Settings",
                    subtitle: "Configure app settings and preferences",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Settings feature coming soon!")),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Quick add feature coming soon!")),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Quick Add',
      ),
    );
  }

  Widget _buildManagementTile(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, size: 40, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
