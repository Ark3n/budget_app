import 'package:budget_app/features/budget/domain/entities/auth_user.dart';

abstract class AuthRepository {
  AuthUser? get currentUser;
  Stream<AuthUser?> get authStateChange;

  Future<void> signIn(String email, String password);
  Future<void> signUp(String email, String password);
  Future<void> signOut();
}
