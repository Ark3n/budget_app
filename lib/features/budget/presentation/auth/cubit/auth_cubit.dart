import 'dart:async';

import 'package:budget_app/features/budget/domain/entities/auth_user.dart';
import 'package:budget_app/features/budget/domain/repository/auth_repository.dart';
import 'package:budget_app/features/budget/presentation/auth/cubit/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// AuthCubit states:
/// - initial: app bootstraps current session
/// - loading: sign in/up/out in progress
/// - authenticated: user has an active session
/// - unauthenticated: no active session
/// - failure: auth action failed and includes friendly error text
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<AuthUser?>? _authSub;

  AuthCubit(this._authRepository) : super(const AuthState()) {
    _authSub = _authRepository.authStateChange.listen(_onAuthChanged);
    final currentUser = _authRepository.currentUser;
    if (currentUser != null) {
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: currentUser,
          error: null,
        ),
      );
    } else {
      emit(
        state.copyWith(status: AuthStatus.unauthenticated, user: null, error: null),
      );
    }
  }

  void setRegisterMode(bool isRegisterMode) {
    emit(state.copyWith(isRegisterMode: isRegisterMode, error: null));
  }

  Future<void> signIn(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading, error: null));
    try {
      await _authRepository.signIn(email.trim(), password);
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          user: null,
          error: _mapAuthError(error),
        ),
      );
    }
  }

  Future<void> signUp(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading, error: null));
    try {
      await _authRepository.signUp(email.trim(), password);
      // Keep users on sign-in mode for email verification flows.
      emit(state.copyWith(isRegisterMode: false));
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          user: null,
          error: _mapAuthError(error),
        ),
      );
    }
  }

  Future<void> signOut() async {
    emit(state.copyWith(status: AuthStatus.loading, error: null));
    try {
      await _authRepository.signOut();
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          error: _mapAuthError(error),
        ),
      );
    }
  }

  String _mapAuthError(Object error) {
    if (error is supabase.AuthException) {
      return error.message;
    }
    final raw = error.toString();
    if (raw.startsWith('Exception: ')) {
      return raw.substring('Exception: '.length);
    }
    return 'Authentication failed. Please try again.';
  }

  void _onAuthChanged(AuthUser? user) {
    if (user == null) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
          error: null,
        ),
      );
      return;
    }
    emit(state.copyWith(status: AuthStatus.authenticated, user: user, error: null));
  }

  @override
  Future<void> close() async {
    await _authSub?.cancel();
    return super.close();
  }
}
