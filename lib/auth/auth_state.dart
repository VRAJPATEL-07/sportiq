class AuthState {
  final String? userId;
  final String? email;
  final String? displayName;
  final String role; // 'student' or 'admin' or 'guest'
  final bool loggedIn;
  /// True only during the logout transition — guards should NOT redirect
  /// to unauthorized when this is true.
  final bool loggingOut;

  const AuthState({
    this.userId,
    this.email,
    this.displayName,
    required this.role,
    required this.loggedIn,
    this.loggingOut = false,
  });

  static const signedOut = AuthState(
    userId: null,
    email: null,
    displayName: null,
    role: 'guest',
    loggedIn: false,
  );

  /// Same as signedOut, but signals that we are actively logging out.
  static const loggingOutState = AuthState(
    userId: null,
    email: null,
    displayName: null,
    role: 'guest',
    loggedIn: false,
    loggingOut: true,
  );
}
