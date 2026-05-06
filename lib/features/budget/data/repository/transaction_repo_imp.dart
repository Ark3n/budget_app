import 'package:budget_app/features/budget/data/datasource/local_datasource.dart';
import 'package:budget_app/features/budget/data/datasource/remote_datasource.dart';
import 'package:budget_app/features/budget/data/models/category_model.dart';
import 'package:budget_app/features/budget/data/models/transaction_model.dart';
import 'package:budget_app/core/utils/budget_defaults.dart';
import 'package:budget_app/core/exceptions/insufficient_balance_exception.dart';
import 'package:budget_app/features/budget/domain/entities/transaction.dart';
import 'package:budget_app/features/budget/domain/repository/account_repository.dart';
import 'package:budget_app/features/budget/domain/repository/transaction_repository.dart';

class TransactionRepoImp implements TransactionRepository {
  final LocalDatasource _local;
  final AccountRepository _account;
  final RemoteDatasource? _remote;
  TransactionRepoImp(this._local, this._account, [this._remote]);

  void _requireNonNegativeBalance(double balance) {
    if (balance < 0) {
      throw const InsufficientBalanceException();
    }
  }

  // helper func: apply transaction to balance
  double _applyTransaction({
    required double balance,
    required TransactionType type,
    required double amount,
  }) {
    switch (type) {
      case TransactionType.income:
        return balance + amount;
      case TransactionType.expense:
        return balance - amount;
    }
  }

  // create transaction
  @override
  Future<void> createTransaction(Transaction transaction) async {
    final account = await _account.getAccount(transaction.accountId);
    if (account == null) throw Exception('Account not found');
    final newBalance = _applyTransaction(
      balance: account.balance,
      type: transaction.type,
      amount: transaction.amount,
    );
    _requireNonNegativeBalance(newBalance);
    await _account.updateAccount(transaction.accountId, newBalance);
    final model = TransactionModel.fromEntity(transaction);
    await _local.saveTransaction(model);
    try {
      await _remote?.upsertTransaction(model);
    } catch (_) {}
  }

  // Get transactions
  @override
  Future<List<Transaction>> getTransactions() async {
    try {
      var result = await _local.getTransactions();
      if (result.isEmpty && _remote != null && _remote.currentUserId != null) {
        try {
          final remoteTransactions = await _remote.getTransactions();
          for (final item in remoteTransactions) {
            await _local.saveTransaction(item);
          }
          result = await _local.getTransactions();
        } catch (_) {}
      }

      final transactions = await Future.wait(
        result.map((e) async {
          CategoryModel? category;

          if (e.categoryId != null) {
            category = await _local.getCategory(e.categoryId!);
          }

          return e.toEntity(category?.toEntity());
        }),
      );

      return transactions;
    } catch (e) {
      throw Exception('Failed to get transactions: $e');
    }
  }

  @override
  Future<void> deleteAllTransactions() async {
    await _local.clearAllTransactions();
    try {
      await _remote?.clearTransactions();
    } catch (_) {}
    await _account.updateAccount(
      BudgetDefaults.defaultAccountId,
      BudgetDefaults.initialAccountBalance,
    );
  }
}
