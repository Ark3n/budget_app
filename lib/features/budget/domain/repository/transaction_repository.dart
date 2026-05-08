import 'package:budget_app/features/budget/domain/entities/transaction.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getTransactions();
  Future<void> createTransaction(Transaction transaction);

  /// Clears local transactions and resets the default account balance locally.
  Future<void> deleteAllTransactions();
  Future<void> backupToCloud();
  Future<void> restoreFromCloud({bool replaceLocal = true});
}
