// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_service_base.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/notification_bell_button.dart';

class StudentDashboard extends StatefulWidget {
  final VoidCallback? onToggleTheme;

  const StudentDashboard({super.key, this.onToggleTheme});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _activeBorrowings = 3;
  int _totalBorrowings = 12;
  int _penalties = 1;
  double _rating = 4.8;
  @override
  void initState() {
    super.initState();
    
    // Start notification timer when student dashboard is loaded
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        context.read<NotificationProvider>().startNotificationTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome to SportiQ Dashboard!'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Dashboard"),
        centerTitle: true,
        elevation: 0,
        actions: [
          const NotificationBellButton(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '📚 Student',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 40, color: Colors.blue),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              auth.current.displayName ?? 'Student',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              auth.current.email ?? 'student@sportiq.com',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      auth.current.role,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Equipment'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/equipment');
              },
            ),
            ListTile(
              leading: const Icon(Icons.library_books),
              title: const Text('My Borrowed Items'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/my_borrowed');
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Booking History'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/booking_history');
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
            // Advanced tools removed from user menu
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: const Text('Confirm Logout'),
                    content: const Text('Are you sure you want to logout from SportiQ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(dialogContext);
                          await auth.logout();
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('You have been logged out successfully'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            ),
                          );
                          Future.delayed(const Duration(milliseconds: 800), () {
                            if (mounted) {
                              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome
              Text(
                'Hello, ${auth.current.displayName ?? 'Student'}!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.black87,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                auth.current.email ?? 'Manage your sports equipment bookings and more.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
              ),
              const SizedBox(height: 20),

              // Key Metrics
              Text(
                'Key Metrics',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Active Borrowings',
                      value: '$_activeBorrowings',
                      icon: Icons.inventory_2,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Total Borrowed',
                      value: '$_totalBorrowings',
                      icon: Icons.library_books,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Penalties',
                      value: '$_penalties',
                      icon: Icons.warning,
                      color: _penalties > 0 ? Colors.red : Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Rating',
                      value: '$_rating/5',
                      icon: Icons.star,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.05,
                children: [
                  _buildActionCard(
                    context,
                    icon: Icons.inventory,
                    title: 'View Equipment',
                    color: Colors.green,
                    subtitle: 'Browse available gear',
                    onTap: () {
                      Navigator.pushNamed(context, '/equipment');
                    },
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.library_books,
                    title: 'My Borrowed Items',
                    color: Colors.orange,
                    subtitle: 'Manage your active loans',
                    onTap: () {
                      Navigator.pushNamed(context, '/my_borrowed');
                    },
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.history,
                    title: 'Booking History',
                    color: Colors.indigo,
                    subtitle: 'View past bookings',
                    onTap: () {
                      Navigator.pushNamed(context, '/booking_history');
                    },
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.person,
                    title: 'Profile Settings',
                    color: Colors.purple,
                    subtitle: 'Update your account',
                    onTap: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/equipment'),
        icon: const Icon(Icons.search),
        label: const Text('Browse Equipment'),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withValues(alpha: 0.08), color.withValues(alpha: 0.02)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
      BuildContext context, {
      required IconData icon,
      required String title,
      required VoidCallback onTap,
      Color? color,
      String? subtitle,
    }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.97, end: 1.0),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOut,
      builder: (context, scale, child) {
        final cardColor = color ?? Theme.of(context).primaryColor;
        return Transform.scale(
          scale: scale,
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cardColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, size: 44, color: cardColor),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
