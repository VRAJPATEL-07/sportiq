// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_service_base.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/notification_bell_button.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    
    // Start notification timer when admin dashboard is loaded
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        context.read<NotificationProvider>().startNotificationTimer();
      }
    });
  }

  @override
  void dispose() {
    // Stop notification timer when leaving the dashboard
    context.read<NotificationProvider>().stopNotificationTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<IAuthService>(context);
    final colorOnPrimary = Theme.of(context).colorScheme.onPrimary;
    // Guard: ensure only admins can view this screen
    if (auth.current.role != 'admin') {
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/unauthorized'));
      return const SizedBox.shrink();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        centerTitle: true,
        elevation: 0,
        actions: [
          const NotificationBellButton(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  backgroundColor: Colors.transparent,
                ),
                onPressed: () => Navigator.pushNamed(context, '/profile'),
                icon: Icon(Icons.admin_panel_settings, size: 18, color: colorOnPrimary),
                label: Text('Admin', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colorOnPrimary)),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.admin_panel_settings, size: 40, color: Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.current.displayName ?? 'Admin',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          auth.current.email ?? 'admin@sportiq.com',
                          style: const TextStyle(color: Colors.white70),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            auth.current.role,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Add Equipment'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/add_equipment');
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Manage Users'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/manage_users');
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Reports'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/reports');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings & Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
            // Advanced tools removed from production admin menu
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                await auth.logout();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              },
            ),
          ],
        ),
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
                      Navigator.pushNamed(context, '/add_equipment');
                    },
                  ),
                  _buildManagementTile(
                    context,
                    icon: Icons.edit,
                    title: "Manage Equipment",
                    subtitle: "Edit or remove existing equipment",
                    onTap: () {
                      Navigator.pushNamed(context, '/equipment');
                    },
                  ),
                  _buildManagementTile(
                    context,
                    icon: Icons.people,
                    title: "Manage Users",
                    subtitle: "Create and manage student/admin accounts",
                    onTap: () {
                      Navigator.pushNamed(context, '/manage_users');
                    },
                  ),
                  _buildManagementTile(
                    context,
                    icon: Icons.bar_chart,
                    title: "Reports",
                    subtitle: "View usage reports and analytics",
                    onTap: () {
                      Navigator.pushNamed(context, '/reports');
                    },
                  ),
                  _buildManagementTile(
                    context,
                    icon: Icons.settings,
                    title: "System Settings",
                    subtitle: "Configure app settings and preferences",
                    onTap: () {
                      Navigator.pushNamed(context, '/profile');
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
          Navigator.pushNamed(context, '/add_equipment');
        },
        tooltip: 'Add Equipment',
        child: const Icon(Icons.add),
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
