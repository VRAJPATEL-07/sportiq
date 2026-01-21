import 'package:flutter/material.dart';
import '../student/student_dashboard.dart';

class LoginScreen extends StatelessWidget {
  final VoidCallback onToggleTheme;

  const LoginScreen({super.key, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SportiQ"),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: onToggleTheme,
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.sports_soccer,
                size: 100,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              const Text(
                "Welcome to SportiQ",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                "Smart Sports Equipment Management System",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StudentDashboard()),
                    );
                  },
                  icon: const Icon(Icons.login),
                  label: const Text("Sign in with Google"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Dummy admin login
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StudentDashboard()),
                  );
                },
                child: const Text("Continue as Guest"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
