class AuthState {
  final String? userId;
  final String? email;
  final String? displayName;
  final String role; // 'student' or 'admin' or 'guest'
  final bool loggedIn;

  const AuthState({
    this.userId,
    this.email,
    this.displayName,
    required this.role,
    required this.loggedIn,
  });

  static const signedOut = AuthState(
    userId: null,
    email: null,
    displayName: null,
    role: 'guest',
    loggedIn: false,
  );
}
