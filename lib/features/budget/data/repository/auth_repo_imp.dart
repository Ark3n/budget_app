import 'package:budget_app/features/budget/domain/entities/auth_user.dart';
import 'package:budget_app/features/budget/domain/repository/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Supabase-backed implementation of [AuthRepository].
class AuthRepoImp implements AuthRepository {
  final supabase.SupabaseClient _client;

  const AuthRepoImp(this._client);

  AuthUser _mapUser(supabase.User user) {
    final createdAt = DateTime.tryParse(user.createdAt) ?? DateTime.now();
    return AuthUser(
      id: user.id,
      email: user.email ?? '',
      createdAt: createdAt,
      name: user.userMetadata?['name'] as String?,
    );
  }

  @override
  Stream<AuthUser?> get authStateChange {
    return _client.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      if (user == null) return null;
      return _mapUser(user);
    });
  }

  @override
  AuthUser? get currentUser {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _mapUser(user);
  }

  @override
  Future<void> signIn(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<void> signUp(String email, String password) async {
    await _client.auth.signUp(email: email, password: password);
  }
}
