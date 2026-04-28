import 'package:budget_app/features/budget/domain/entities/account.dart';

abstract class AccountRepository {
  Future<Account?> getAccount(String id);
  Future<List<Account>> getAllAccounts();
  Future<void> saveAccount(Account account);
  Future<void> deleteAccount(String id);
  Future<void> updateAccount(String id, double newBalance);
}
