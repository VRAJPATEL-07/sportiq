class AuthState {
  final String? userId;
  final String role; // 'student' or 'admin' or 'guest'
  final bool loggedIn;

  const AuthState({this.userId, required this.role, required this.loggedIn});

  static const signedOut = AuthState(userId: null, role: 'guest', loggedIn: false);
}
