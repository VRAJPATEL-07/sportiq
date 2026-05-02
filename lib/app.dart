import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/themes/app_theme.dart';
import 'features/auth/splash_screen.dart';
import 'auth/auth_service_base.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/student/booking_history_screen.dart';
import 'features/student/student_dashboard.dart';
import 'features/admin/admin_dashboard.dart';
import 'features/admin/add_edit_equipment_screen.dart';
import 'features/admin/manage_users_screen.dart';
import 'features/admin/admin_reports_screen.dart';
import 'features/equipment/equipment_list.dart';
import 'features/equipment/scan_equipment_screen.dart';
import 'features/equipment/borrow_confirmation_screen.dart';
import 'features/student/my_borrowed_items_screen.dart';
import 'features/student/profile_settings_screen.dart';
import 'features/legal/privacy_policy_screen.dart';
import 'features/legal/terms_of_service_screen.dart';
import 'features/equipment/borrow_equipment_form.dart';
import 'features/equipment/equipment_detail_screen.dart';
import 'features/student/penalty_details_screen.dart';
import 'features/notifications/notification_test_screen.dart';
import 'features/notifications/notification_screen.dart';
import 'routes/unauthorized_screen.dart';
import 'core/navigation.dart';
import 'screens/advanced/advanced_tools_screen.dart';
import 'screens/api_posts_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/qr_scan_screen.dart';

class SportiQApp extends StatefulWidget {
  const SportiQApp({super.key});

  @override
  State<SportiQApp> createState() => _SportiQAppState();
}

class _SportiQAppState extends State<SportiQApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  // Route generation is handled inside build where AuthService is available.

  @override
  Widget build(BuildContext context) {
    return Consumer<IAuthService>(builder: (context, auth, _) {
      Route<dynamic> onGenerate(RouteSettings settings) {
        // Role guard helper
        // Debug: log current auth state when routing
        debugPrint('DEBUG: Routing check - current auth state: userId=${auth.current.userId} email=${auth.current.email} displayName=${auth.current.displayName} role=${auth.current.role} loggedIn=${auth.current.loggedIn}');

        // If we are in the middle of logging out, allow /login route and
        // redirect everything else to /login. This prevents stale guards
        // from showing the unauthorized page.
        if (auth.current.loggingOut) {
          if (settings.name == '/login') {
            return MaterialPageRoute(builder: (_) => LoginScreen(onToggleTheme: _toggleTheme));
          }
          return MaterialPageRoute(builder: (_) => LoginScreen(onToggleTheme: _toggleTheme));
        }

        final requiresAdmin = <String>{'/admin', '/add_equipment', '/manage_users', '/reports'};
        final requiresStudent = <String>{'/student', '/my_borrowed', '/booking_history'};
        final requiresLogin = <String>{'/equipment', '/scan', '/equipment_detail', '/borrow_confirmation', '/borrow_form', '/penalty_details', '/profile', '/notifications', '/booking_history'};

        if (requiresAdmin.contains(settings.name)) {
          // Use FirebaseAuth directly for logged-in check
          if (FirebaseAuth.instance.currentUser == null) {
            return MaterialPageRoute(builder: (_) => LoginScreen(onToggleTheme: _toggleTheme));
          }
          // Give the auth service a moment to update after login
          if (auth.current.role != 'admin') {
            debugPrint('DEBUG: Non-admin tried to access admin route ${settings.name}. Current role: ${auth.current.role}');
            return MaterialPageRoute(builder: (_) => const UnauthorizedScreen());
          }
        } else if (requiresStudent.contains(settings.name)) {
          if (FirebaseAuth.instance.currentUser == null) {
            return MaterialPageRoute(builder: (_) => LoginScreen(onToggleTheme: _toggleTheme));
          }
          // Allow student access, also allow admin to access student routes for testing
          if (auth.current.role != 'student' && auth.current.role != 'admin') {
            debugPrint('DEBUG: Non-student/admin tried to access student route ${settings.name}. Current role: ${auth.current.role}');
            return MaterialPageRoute(builder: (_) => const UnauthorizedScreen());
          }
        } else if (requiresLogin.contains(settings.name)) {
          if (FirebaseAuth.instance.currentUser == null) {
            return MaterialPageRoute(builder: (_) => LoginScreen(onToggleTheme: _toggleTheme));
          }
        }

        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => SplashScreen(onToggleTheme: _toggleTheme));
          case '/login':
            return MaterialPageRoute(builder: (_) => LoginScreen(onToggleTheme: _toggleTheme));
          case '/register':
            return MaterialPageRoute(builder: (_) => RegisterScreen(onToggleTheme: _toggleTheme));
          case '/student':
            return MaterialPageRoute(
              builder: (_) => StudentDashboard(onToggleTheme: _toggleTheme),
              settings: settings,
            );
          case '/admin':
            return MaterialPageRoute(builder: (_) => AdminDashboard());
          case '/equipment':
            return MaterialPageRoute(builder: (_) => EquipmentList());
          case '/scan':
            return MaterialPageRoute(builder: (_) => ScanEquipmentScreen());
          case '/borrow_confirmation':
            return MaterialPageRoute(builder: (_) => BorrowConfirmationScreen());
          case '/borrow_form':
            final argsForm = settings.arguments as Map<String, dynamic>?;
            if (argsForm != null && argsForm['equipment'] != null) {
              return MaterialPageRoute(builder: (_) => BorrowEquipmentForm(equipment: argsForm['equipment'] as dynamic));
            }
            return MaterialPageRoute(builder: (_) => BorrowConfirmationScreen());
          case '/equipment_detail':
            final argsDetail = settings.arguments as Map<String, dynamic>?;
            if (argsDetail != null && argsDetail['equipment'] != null) {
              return MaterialPageRoute(builder: (_) => EquipmentDetailScreen(equipment: argsDetail['equipment'] as Map<String, dynamic>));
            }
            // fallback: go to equipment list if no payload
            return MaterialPageRoute(builder: (_) => EquipmentList());
          case '/add_equipment':
            final args = settings.arguments as Map<String, dynamic>?;
            if (args != null && args['id'] != null) {
              return MaterialPageRoute(builder: (_) => AddEditEquipmentScreen(equipmentId: args['id'] as String, initialData: args['data'] as Map<String, dynamic>?));
            }
            return MaterialPageRoute(builder: (_) => AddEditEquipmentScreen());
          case '/manage_users':
            return MaterialPageRoute(builder: (_) => ManageUsersScreen());
          case '/reports':
            return MaterialPageRoute(builder: (_) => const AdminReportsScreen());
          case '/my_borrowed':
            return MaterialPageRoute(builder: (_) => MyBorrowedItemsScreen());
          case '/booking_history':
            return MaterialPageRoute(builder: (_) => const BookingHistoryScreen());
          case '/penalty_details':
            return MaterialPageRoute(builder: (_) => PenaltyDetailsScreen());
          case '/profile':
            return MaterialPageRoute(
              builder: (_) => ProfileSettingsScreen(onToggleTheme: _toggleTheme),
              settings: settings,
            );
          case '/notifications':
            return MaterialPageRoute(
              builder: (_) => const NotificationScreen(),
              settings: settings,
            );
          case '/privacy':
            return MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen());
          case '/terms':
            return MaterialPageRoute(builder: (_) => const TermsOfServiceScreen());
          case '/notification_test':
            // LAB 8: Test screen for notifications and animations
            return MaterialPageRoute(builder: (_) => const NotificationTestScreen());
          case '/advanced_tools':
            return MaterialPageRoute(builder: (_) => const AdvancedToolsScreen());
          case '/api_posts':
            return MaterialPageRoute(builder: (_) => const ApiPostsScreen());
          case '/gallery':
            return MaterialPageRoute(builder: (_) => const GalleryScreen());
          case '/camera':
            return MaterialPageRoute(builder: (_) => const CameraCaptureScreen());
          case '/qr_scan':
            return MaterialPageRoute(builder: (_) => const QRScanScreen());
          case '/unauthorized':
            return MaterialPageRoute(builder: (_) => UnauthorizedScreen());
          default:
            return MaterialPageRoute(builder: (_) => SplashScreen(onToggleTheme: _toggleTheme));
        }
      }

      return MaterialApp(
        title: 'SportiQ',
        navigatorKey: appNavigatorKey,
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: _themeMode,
        initialRoute: '/',
        onGenerateRoute: onGenerate,
      );
    });
  }
}
