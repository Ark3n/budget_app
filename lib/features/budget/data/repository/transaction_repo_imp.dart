import 'package:budget_app/features/budget/data/datasource/local_datasource.dart';
import 'package:budget_app/features/budget/data/models/category_model.dart';
import 'package:budget_app/features/budget/data/models/transaction_model.dart';
import 'package:budget_app/features/budget/domain/entities/transaction.dart';
import 'package:budget_app/features/budget/domain/repository/account_repository.dart';
import 'package:budget_app/features/budget/domain/repository/transaction_repository.dart';

class TransactionRepoImp implements TransactionRepository {
  final LocalDatasource _local;
  final AccountRepository _account;
  TransactionRepoImp(this._local, this._account);
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

  // helper func: revert transaction from balance
  double _revertTransaction({
    required double balance,
    required TransactionType type,
    required double amount,
  }) {
    switch (type) {
      case TransactionType.income:
        return balance - amount;
      case TransactionType.expense:
        return balance + amount;
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
    await _account.updateAccount(transaction.accountId, newBalance);
    await _local.saveTransaction(TransactionModel.fromEntity(transaction));
  }

  // delete transaction
  @override
  Future<void> deleteTransaction(Transaction transaction) async {
    final account = await _account.getAccount(transaction.accountId);
    if (account == null) throw Exception('Account not found');
    final newBalance = _revertTransaction(
      balance: account.balance,
      type: transaction.type,
      amount: transaction.amount,
    );
    await _account.updateAccount(transaction.accountId, newBalance);
    await _local.deleteTransaction(TransactionModel.fromEntity(transaction));
  }

  // Get transactions
  @override
  Future<List<Transaction>> getTransactions() async {
    try {
      final result = await _local.getTransactions();

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

  // Update transaction
  @override
  Future<void> updateTransaction(Transaction transaction) async {
    final previous = await _local.getTransaction(transaction.id);
    if (previous == null) throw Exception('Transaction not found');

    final previousEntity = previous.toEntity(null);

    if (previousEntity.accountId == transaction.accountId) {
      final account = await _account.getAccount(transaction.accountId);
      if (account == null) throw Exception('Account not found');

      final reversedBalance = _revertTransaction(
        balance: account.balance,
        type: previousEntity.type,
        amount: previousEntity.amount,
      );
      final newBalance = _applyTransaction(
        balance: reversedBalance,
        type: transaction.type,
        amount: transaction.amount,
      );
      await _account.updateAccount(transaction.accountId, newBalance);
    } else {
      final oldAccount = await _account.getAccount(previousEntity.accountId);
      final newAccount = await _account.getAccount(transaction.accountId);
      if (oldAccount == null || newAccount == null) {
        throw Exception('Account not found');
      }

      final oldAccountBalance = _revertTransaction(
        balance: oldAccount.balance,
        type: previousEntity.type,
        amount: previousEntity.amount,
      );
      final newAccountBalance = _applyTransaction(
        balance: newAccount.balance,
        type: transaction.type,
        amount: transaction.amount,
      );

      await _account.updateAccount(previousEntity.accountId, oldAccountBalance);
      await _account.updateAccount(transaction.accountId, newAccountBalance);
    }

    await _local.saveTransaction(TransactionModel.fromEntity(transaction));
  }
}
