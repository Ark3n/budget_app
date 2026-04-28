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

  // create transaction
  @override
  Future<void> createTransaction(Transaction transaction) async {
    final account = await _account.getAccount(transaction.accountId);
    if (account == null) throw Exception('Account not found');

    double newBalance = account.balance;

    switch (transaction.type) {
      case TransactionType.income:
        newBalance += transaction.amount;
      case TransactionType.expense:
        newBalance -= transaction.amount;
    }
    await _account.updateAccount(transaction.accountId, newBalance);
    await _local.saveTransaction(TransactionModel.fromEntity(transaction));
  }

  // delete transaction
  @override
  Future<void> deleteTransaction(Transaction transaction) async {
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

          return e.toEntity(category!.toEntity());
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
    await _local.saveTransaction(TransactionModel.fromEntity(transaction));
  }
}
