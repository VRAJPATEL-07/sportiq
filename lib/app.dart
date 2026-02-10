import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/themes/app_theme.dart';
import 'features/auth/splash_screen.dart';
import 'auth/auth_service_base.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/student/student_dashboard.dart';
import 'features/admin/admin_dashboard.dart';
import 'features/admin/add_edit_equipment_screen.dart';
import 'features/admin/manage_users_screen.dart';
import 'features/equipment/equipment_list.dart';
import 'features/equipment/scan_equipment_screen.dart';
import 'features/equipment/borrow_confirmation_screen.dart';
import 'features/student/my_borrowed_items_screen.dart';
import 'features/student/profile_settings_screen.dart';
import 'features/equipment/borrow_equipment_form.dart';
import 'features/student/penalty_details_screen.dart';
import 'routes/unauthorized_screen.dart';

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
        print('DEBUG: Routing check - current auth state: userId=${auth.current.userId} email=${auth.current.email} displayName=${auth.current.displayName} role=${auth.current.role} loggedIn=${auth.current.loggedIn}');
        final requiresAdmin = <String>{'/admin', '/add_equipment', '/manage_users'};
        final requiresStudent = <String>{'/student', '/my_borrowed'};
        final requiresLogin = <String>{'/equipment', '/scan', '/borrow_confirmation', '/borrow_form', '/penalty_details', '/profile'};

        if (requiresAdmin.contains(settings.name)) {
          // Use FirebaseAuth directly for logged-in check to avoid transient AuthState timing issues
          if (FirebaseAuth.instance.currentUser == null) {
            return MaterialPageRoute(builder: (_) => LoginScreen(onToggleTheme: _toggleTheme));
          }
          if (auth.current.role != 'admin') {
            print('DEBUG: Student tried to access admin route ${settings.name}');
            return MaterialPageRoute(builder: (_) => const UnauthorizedScreen());
          }
        } else if (requiresStudent.contains(settings.name)) {
          if (FirebaseAuth.instance.currentUser == null) {
            return MaterialPageRoute(builder: (_) => LoginScreen(onToggleTheme: _toggleTheme));
          }
          if (auth.current.role != 'student') {
            print('DEBUG: Admin tried to access student route ${settings.name}');
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
            return MaterialPageRoute(builder: (_) => StudentDashboard(onToggleTheme: _toggleTheme));
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
          case '/add_equipment':
            final args = settings.arguments as Map<String, dynamic>?;
            if (args != null && args['id'] != null) {
              return MaterialPageRoute(builder: (_) => AddEditEquipmentScreen(equipmentId: args['id'] as String, initialData: args['data'] as Map<String, dynamic>?));
            }
            return MaterialPageRoute(builder: (_) => AddEditEquipmentScreen());
          case '/manage_users':
            return MaterialPageRoute(builder: (_) => ManageUsersScreen());
          case '/my_borrowed':
            return MaterialPageRoute(builder: (_) => MyBorrowedItemsScreen());
          case '/penalty_details':
            return MaterialPageRoute(builder: (_) => PenaltyDetailsScreen());
          case '/profile':
            return MaterialPageRoute(builder: (_) => ProfileSettingsScreen(onToggleTheme: _toggleTheme));
          case '/unauthorized':
            return MaterialPageRoute(builder: (_) => UnauthorizedScreen());
          default:
            return MaterialPageRoute(builder: (_) => SplashScreen(onToggleTheme: _toggleTheme));
        }
      }

      return MaterialApp(
        title: 'SportiQ',
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
