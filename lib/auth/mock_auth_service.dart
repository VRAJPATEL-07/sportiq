import 'dart:async';

import 'auth_service_base.dart';
import 'auth_state.dart';

/// Simple in-memory mock AuthService used when Firebase initialization fails.
class MockAuthService extends IAuthService {
  MockAuthService._private();

  static final MockAuthService instance = MockAuthService._private();

  final StreamController<AuthState> _controller = StreamController<AuthState>.broadcast();
  AuthState _state = AuthState.signedOut;

  Stream<AuthState> get stream => _controller.stream;
  AuthState get current => _state;

  Future<AuthState> login({required String email, required String password}) async {
    // Accept any credentials in mock mode, but detect admin email for role assignment.
    String role = 'student';
    if (email.toLowerCase() == 'admin@sportiq.com') {
      role = 'admin';
    }
    _state = AuthState(userId: email, role: role, loggedIn: true);
    _controller.add(_state);
    notifyListeners();
    return _state;
  }

  Future<AuthState> loginWithGoogle() async {
    // Mock Google sign-in - auto-assign student role
    _state = AuthState(userId: 'Google User', role: 'student', loggedIn: true);
    _controller.add(_state);
    notifyListeners();
    return _state;
  }

  Future<AuthState> register({required String name, required String email, required String password, String role = 'student'}) async {
    // Detect admin email and override role if needed.
    if (email.toLowerCase() == 'admin@sportiq.com') {
      role = 'admin';
    }
    _state = AuthState(userId: email, role: role, loggedIn: true);
    _controller.add(_state);
    notifyListeners();
    return _state;
  }

  Future<void> guestLogin() async {
    _state = AuthState(userId: 'Guest User', role: 'student', loggedIn: true);
    _controller.add(_state);
    notifyListeners();
  }

  Future<void> logout() async {
    _state = AuthState.signedOut;
    _controller.add(_state);
    notifyListeners();
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    // No-op in mock
    return;
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}
