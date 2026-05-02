// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_service_base.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import '../../core/themes/app_colors.dart';
import '../../widgets/glass_container.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const LoginScreen({super.key, required this.onToggleTheme});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    
    super.dispose();
  }

  bool _validateEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  bool _validatePassword(String password) {
    return password.length >= 6;
  }

  Future<void> _handleLogin() async {
    debugPrint('DEBUG_PROOF: Login button clicked');
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    bool isValid = true;

    // Validate email
    if (_emailController.text.isEmpty) {
      setState(() => _emailError = 'Email is required');
      isValid = false;
    } else if (!_validateEmail(_emailController.text)) {
      setState(() => _emailError = 'Please enter a valid email');
      isValid = false;
    }

    // Validate password
    if (_passwordController.text.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      isValid = false;
    } else if (!_validatePassword(_passwordController.text)) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      isValid = false;
    }

    if (!isValid) {
      debugPrint('DEBUG_PROOF: Login validation failed');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors above'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Call centralized auth service to validate role
    setState(() => _isLoading = true);
    try {
      debugPrint('DEBUG_PROOF: Login request started for ${_emailController.text.trim()}');
      final authService = Provider.of<IAuthService>(context, listen: false);
      final authState = await authService.login(email: _emailController.text.trim(), password: _passwordController.text);
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful! Redirecting...'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        debugPrint('DEBUG: Login successful. Auth state role: ${authState.role}');
        if (authState.role == 'admin') {
          debugPrint('DEBUG: Redirecting to admin dashboard via named route');
          Navigator.pushReplacementNamed(context, '/admin');
        } else if (authState.role == 'student') {
          debugPrint('DEBUG: Redirecting to student dashboard via named route');
          Navigator.pushReplacementNamed(context, '/student');
        } else {
          debugPrint('DEBUG: Unknown role, redirecting to unauthorized');
          Navigator.pushReplacementNamed(context, '/unauthorized');
        }
      });
    } on FirebaseAuthException catch (e) {
      debugPrint('DEBUG_PROOF: FirebaseAuthException during login: ${e.code}');
      setState(() => _isLoading = false);
      String message = 'Authentication error';
      switch (e.code) {
        case 'invalid-email':
          message = 'The email address is badly formatted.';
          break;
        case 'user-not-found':
          message = 'No user found for that email.';
          break;
        case 'wrong-password':
          message = 'Wrong password provided for that user.';
          break;
        case 'user-disabled':
          message = 'This user account has been disabled.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Try again later.';
          break;
        case 'network-request-failed':
          message = 'Network error. Check your internet connection.';
          break;
        default:
          message = e.message ?? message;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: $message'), backgroundColor: Colors.red));
    } catch (e) {
      debugPrint('DEBUG_PROOF: General login exception: $e');
      setState(() => _isLoading = false);
      if (!mounted) return;
      final raw = e.toString();
      String userMessage = raw;
      final marker = 'Login failed:';
      if (raw.contains(marker)) {
        userMessage = raw.split(marker).last.trim();
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: $userMessage'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "SPORTIQ",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6, color: AppColors.primary),
            onPressed: widget.onToggleTheme,
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Glowing Pulse Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.1),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    size: 80,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  "SECURE ACCESS",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Enter your credentials to synchronize with the arena",
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Login Form in Glass Container
                GlassContainer(
                  opacity: 0.08,
                  child: Column(
                    children: [
                      // Email TextField
                      TextFormField(
                        controller: _emailController,
                        style: const TextStyle(color: AppColors.onSurface),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Enter your email',
                          hintStyle: TextStyle(color: AppColors.onSurfaceVariant.withOpacity(0.5)),
                          labelText: 'Email Address',
                          labelStyle: const TextStyle(color: AppColors.primary),
                          prefixIcon: const Icon(Icons.alternate_email_rounded, color: AppColors.primary),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Email is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Password TextField
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: AppColors.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          hintStyle: TextStyle(color: AppColors.onSurfaceVariant.withOpacity(0.5)),
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: AppColors.primary),
                          prefixIcon: const Icon(Icons.lock_person_rounded, color: AppColors.primary),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                              color: AppColors.onSurfaceVariant,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Password is required';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Remember Me Checkbox
                CheckboxListTile(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() => _rememberMe = value ?? false);
                  },
                  title: const Text('Remember me'),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () async {
                      final email = await showDialog<String>(
                        context: context,
                        builder: (c) {
                                          final ctrl = TextEditingController(text: _emailController.text);
                                          return AlertDialog(
                                            title: const Text('Reset Password'),
                                            content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Enter your email')),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
                                              ElevatedButton(onPressed: () => Navigator.pop(c, ctrl.text.trim()), child: const Text('Send')),
                                            ],
                                          );
                                        },
                                      );
                                      if (email != null && email.isNotEmpty) {
                                        try {
                                          final authService = Provider.of<IAuthService>(context, listen: false);
                                          await authService.sendPasswordResetEmail(email: email);
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset email sent')));
                                        } catch (e) {
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reset failed: $e'), backgroundColor: Colors.red));
                                        }
                                      }
                                    },
                                child: const Text('Forgot Password?'),
                              ),
                            ),
                const SizedBox(height: 20),
                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      elevation: 10,
                      shadowColor: AppColors.primary.withOpacity(0.3),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          )
                        : const Text(
                            'INITIATE SYNC',
                            style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                // Divider with text
                Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'Or',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),
                // SIGN IN WITH GOOGLE BUTTON
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              setState(() => _isLoading = true);
                              try {
                                final authService = Provider.of<IAuthService>(context, listen: false);
                                final authState = await authService.loginWithGoogle();
                                if (!mounted) return;
                                setState(() => _isLoading = false);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('🎉 Google Sign-In successful!'),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 2),
                                  ),
                                );

                                Future.delayed(const Duration(milliseconds: 400), () {
                                  if (!mounted) return;
                                  debugPrint('DEBUG: Google Sign-In complete. Auth state role: ${authState.role}');
                                  if (authState.role == 'admin') {
                                    debugPrint('DEBUG: Redirecting to admin dashboard');
                                    Navigator.pushReplacementNamed(context, '/admin');
                                  } else {
                                    debugPrint('DEBUG: Redirecting to student dashboard');
                                    Navigator.pushReplacementNamed(context, '/student');
                                  }
                                });
                              } catch (e) {
                                setState(() => _isLoading = false);
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Google Sign-In failed: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Professional Google "G" Logo
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: const CustomGoogleLogo(),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _isLoading ? 'Signing in with Google...' : 'Sign in with Google',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                  ),
                  child: const Text(
                    '⚡ Fast, secure & auto-assigns Student role',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "New to the arena?",
                      style: TextStyle(color: AppColors.onSurfaceVariant),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
                      child: const Text(
                        "CREATE ACCOUNT",
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Information Section
                Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'Information',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),
                // Login Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🔐 Login Policy:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• Only registered users can login',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '• Admins manage user registration',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '• Email + Password required',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text(
                        '👨‍💼 Demo Admin Account:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Email: admin@sportiq.com',
                        style: TextStyle(fontSize: 11, fontFamily: 'monospace'),
                      ),
                      const Text(
                        'Password: admin@123',
                        style: TextStyle(fontSize: 11, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Professional Google "G" Logo Widget
class CustomGoogleLogo extends StatelessWidget {
  const CustomGoogleLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GoogleLogoPainter(),
      size: const Size(20, 20),
    );
  }
}

/// Painter for Professional Google Logo
class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final width = size.width;
    final height = size.height;

    // Background circle (Light gray)
    paint.color = const Color(0xFFF7F6F3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, width, height),
        Radius.circular(width * 0.15),
      ),
      paint,
    );

    // Blue arc
    paint.color = const Color(0xFF4285F4);
    paint.style = PaintingStyle.fill;
    canvas.drawArc(
      Rect.fromLTWH(width * 0.3, 0, width * 0.7, height * 0.8),
      -1.2,
      2.3,
      true,
      paint,
    );

    // Red arc
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromLTWH(0, height * 0.2, width * 0.7, height * 0.7),
      0.8,
      2.3,
      true,
      paint,
    );

    // Yellow arc
    paint.color = const Color(0xFFFBBC04);
    canvas.drawArc(
      Rect.fromLTWH(width * 0.2, height * 0.3, width * 0.6, height * 0.6),
      -2.5,
      2.3,
      true,
      paint,
    );

    // Green arc
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromLTWH(width * 0.4, height * 0.15, width * 0.5, height * 0.75),
      1.5,
      2.3,
      true,
      paint,
    );
  }

  @override
  bool shouldRepaint(GoogleLogoPainter oldDelegate) => false;
}
