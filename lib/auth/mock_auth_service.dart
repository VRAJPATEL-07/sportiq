import 'dart:async';

import 'auth_service_base.dart';
import 'auth_state.dart';

/// Simple in-memory mock AuthService used when Firebase initialization fails.
class MockAuthService extends IAuthService {
  MockAuthService._private();

  static final MockAuthService instance = MockAuthService._private();

  final StreamController<AuthState> _controller = StreamController<AuthState>.broadcast();
  AuthState _state = AuthState.signedOut;

  @override
  Stream<AuthState> get stream => _controller.stream;
  @override
  AuthState get current => _state;

  @override
  Future<AuthState> login({required String email, required String password}) async {
    // Accept any credentials in mock mode, but detect admin email for role assignment.
    String role = 'student';
    if (email.toLowerCase() == 'admin@sportiq.com') {
      role = 'admin';
    }
    _state = AuthState(
      userId: email,
      email: email,
      displayName: email.split('@')[0],
      role: role,
      loggedIn: true,
    );
    _controller.add(_state);
    notifyListeners();
    return _state;
  }

  @override
  Future<AuthState> loginWithGoogle() async {
    // Mock Google sign-in - auto-assign student role
    _state = AuthState(
      userId: 'Google User',
      email: 'google@sportiq.com',
      displayName: 'Google User',
      role: 'student',
      loggedIn: true,
    );
    _controller.add(_state);
    notifyListeners();
    return _state;
  }

  @override
  Future<AuthState> register({required String name, required String email, required String password, String role = 'student'}) async {
    // Detect admin email and override role if needed.
    if (email.toLowerCase() == 'admin@sportiq.com') {
      role = 'admin';
    }
    _state = AuthState(
      userId: email,
      email: email,
      displayName: name,
      role: role,
      loggedIn: true,
    );
    _controller.add(_state);
    notifyListeners();
    return _state;
  }

  @override
  Future<void> guestLogin() async {
    _state = AuthState(
      userId: 'Guest User',
      email: 'guest@sportiq.com',
      displayName: 'Guest User',
      role: 'student',
      loggedIn: true,
    );
    _controller.add(_state);
    notifyListeners();
  }

  @override
  Future<void> logout() async {
    _state = AuthState.signedOut;
    _controller.add(_state);
    notifyListeners();
  }

  @override
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
