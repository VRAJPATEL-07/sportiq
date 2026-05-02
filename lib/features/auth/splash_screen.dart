import 'package:flutter/material.dart';
import '../../core/themes/app_colors.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const SplashScreen({super.key, required this.onToggleTheme});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _scale = Tween<double>(begin: 0.8, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _navigateToLogin();
  }

  Future<void> _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Gradient Glow
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.05),
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        size: 100,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      "SportiQ",
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "THE KINETIC PULSE",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 8,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}