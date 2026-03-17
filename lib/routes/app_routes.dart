/// LAB 6: Named Routes Configuration
/// 
/// This file defines all named routes in the application.
/// Routes are organized by access level:
///   - Public routes (login, register, splash)
///   - Student routes (home, profile, equipment)
///   - Admin routes (admin dashboard, manage users)
///   - Guarded routes (require authentication)
library;

/// Route Names - LAB 6: Navigation
class AppRoutes {
  // Root and authentication routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String unauthorized = '/unauthorized';

  // Student routes - LAB 4: Navigation
  static const String studentDashboard = '/student';
  static const String profile = '/profile';
  static const String myBorrowed = '/my_borrowed';
  static const String bookingHistory = '/booking_history';
  static const String penaltyDetails = '/penalty_details';

  // Equipment routes
  static const String equipment = '/equipment';
  static const String scan = '/scan';
  static const String borrowConfirmation = '/borrow_confirmation';
  static const String borrowForm = '/borrow_form';
  static const String equipmentDetail = '/equipment_detail';

  // Admin routes
  static const String adminDashboard = '/admin';
  static const String addEquipment = '/add_equipment';
  static const String manageUsers = '/manage_users';

  // API & Data routes
  static const String apiPosts = '/api_posts';

  /// Routes that require authentication (login check)
  static const Set<String> requiresLogin = {
    equipment,
    scan,
    borrowConfirmation,
    borrowForm,
    equipmentDetail,
    penaltyDetails,
    profile,
    studentDashboard,
    myBorrowed,
    bookingHistory,
    adminDashboard,
    addEquipment,
    manageUsers,
    apiPosts,
  };

  /// Routes that require admin role
  static const Set<String> requiresAdmin = {
    adminDashboard,
    addEquipment,
    manageUsers,
  };

  /// Routes that require student role
  static const Set<String> requiresStudent = {
    studentDashboard,
    myBorrowed,
    bookingHistory,
  };

  /// Public routes (no authentication required)
  static const Set<String> publicRoutes = {
    splash,
    login,
    register,
    unauthorized,
  };
}
