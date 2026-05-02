// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_service_base.dart';
import '../../providers/equipment_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/notification_bell_button.dart';
import 'borrowing_notifications_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late final Stream<List<Map<String, dynamic>>> _recentBorrows;

  @override
  void initState() {
    super.initState();
    _recentBorrows = EquipmentProvider.instance.borrowRecordsStream(limit: 12);

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
    // If we're logging out, don't render — navigation is already happening
    if (auth.current.loggingOut || (!auth.current.loggedIn && auth.current.role == 'guest')) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
              leading: const Icon(Icons.notifications_active),
              title: const Text('Borrowing Notifications'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BorrowingNotificationsScreen(),
                  ),
                );
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
                Navigator.pop(context); // close drawer
                // Navigate to login FIRST, clearing the entire stack,
                // THEN sign out. This prevents the Consumer rebuild from
                // triggering the role guard while we're still on /admin.
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                await auth.logout();
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
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  Consumer<EquipmentProvider>(
                    builder: (context, eq, _) {
                      final items = eq.items;
                      final totalSkus = items.length;
                      final totalUnits = items.fold<int>(0, (s, e) => s + ((e['quantity'] as int?) ?? 0));
                      var availUnits = 0;
                      for (final e in items) {
                        final q = (e['quantity'] as int?) ?? 0;
                        final a = e['available'];
                        final av = a is int ? (a > q ? q : a) : q;
                        availUnits += av;
                      }
                      final onLoan = totalUnits - availUnits;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.sync, color: Theme.of(context).colorScheme.primary),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Live inventory',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 10,
                                runSpacing: 8,
                                children: [
                                  _buildLiveStatChip('SKUs', '$totalSkus', Colors.blue),
                                  _buildLiveStatChip('Total units', '$totalUnits', Colors.indigo),
                                  _buildLiveStatChip('Available', '$availUnits', Colors.green),
                                  _buildLiveStatChip('On loan', '$onLoan', Colors.deepOrange),
                                ],
                              ),
                              if (eq.error != null) ...[
                                const SizedBox(height: 8),
                                Text(eq.error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const Text(
                    'Recent borrows',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _recentBorrows,
                    builder: (context, snap) {
                      if (snap.hasError) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Could not load activity: ${snap.error}',
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        );
                      }
                      if (!snap.hasData || snap.data!.isEmpty) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Text(
                              'No borrow activity yet. When a student confirms a borrow, it appears here immediately.',
                              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                            ),
                          ),
                        );
                      }
                      final rows = snap.data!;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: rows.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final r = rows[i];
                            final name = r['equipmentName']?.toString() ?? 'Item';
                            final qty = (r['quantity'] as num?)?.toInt() ?? 0;
                            final who = r['borrowedByName']?.toString() ??
                                r['borrowedByEmail']?.toString() ??
                                r['borrowedBy']?.toString() ??
                                '—';
                            final created = r['createdAt'];
                            var when = '—';
                            if (created is Timestamp) {
                              final d = created.toDate();
                              when =
                                  '${d.day}/${d.month} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
                            }
                            return ListTile(
                              dense: true,
                              leading: const Icon(Icons.outbox, color: Colors.deepOrange),
                              title: Text(
                                '$name × $qty',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                '$who • $when',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const Text(
                    "Management Options",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
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
                    icon: Icons.notifications_active,
                    title: "Borrowing Notifications",
                    subtitle: "Monitor active borrowings and notify users",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BorrowingNotificationsScreen(),
                        ),
                      );
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

  Widget _buildLiveStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
        ],
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
