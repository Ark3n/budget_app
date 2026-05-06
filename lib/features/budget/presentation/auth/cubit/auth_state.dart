import 'package:budget_app/features/budget/domain/entities/auth_user.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, failure }

/// UI state for authentication flows and session status.
class AuthState {
  final AuthStatus status;
  final AuthUser? user;
  final bool isRegisterMode;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.isRegisterMode = false,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    bool? isRegisterMode,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      isRegisterMode: isRegisterMode ?? this.isRegisterMode,
      error: error,
    );
  }
}
