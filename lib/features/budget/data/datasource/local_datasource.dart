// Category datasource
import 'dart:async';

import 'package:budget_app/features/budget/data/models/account_model.dart';
import 'package:budget_app/features/budget/data/models/category_model.dart';
import 'package:budget_app/features/budget/data/models/transaction_model.dart';
import 'package:hive_ce/hive.dart';

/// C -> create category
/// R -> get categories
/// U -> update category
/// D -> delete one category, delete all categories

class LocalDatasource {
  static const String _category = 'category';
  static const String _transaction = 'transaction';
  static const String _account = 'account';

  Future<Box<CategoryModel>> get _categoryBox async =>
      Hive.openBox<CategoryModel>(_category);

  Future<Box<TransactionModel>> get _transactionBox async =>
      Hive.openBox<TransactionModel>(_transaction);
  Future<Box<AccountModel>> get _accountBox =>
      Hive.openBox<AccountModel>(_account);

  // MARK: - ACCOUNT
  /// save account
  Future<void> saveAccount(AccountModel model) async {
    final box = await _accountBox;
    await box.put(model.id, model);
  }

  /// get account by id
  Future<AccountModel?> getAccount(String id) async {
    final box = await _accountBox;
    return box.get(id);
  }

  /// get all accounts
  Future<List<AccountModel>> getAccounts() async {
    final box = await _accountBox;
    return box.values.toList();
  }

  /// delete account
  Future<void> deleteAccount(String id) async {
    final box = await _accountBox;
    await box.delete(id);
  }

  // MARK: - CATEGORY
  /// save category
  Future<void> saveCategory(CategoryModel model) async {
    final box = await _categoryBox;
    await box.put(model.id, model);
  }

  /// get category by category id
  Future<CategoryModel?> getCategory(String? id) async {
    final box = await _categoryBox;
    final categoryModel = box.get(id);
    return categoryModel;
  }

  /// get all categories
  Future<List<CategoryModel>> getCategories() async {
    final box = await _categoryBox;
    return box.values.toList();
  }

  /// delete category
  Future<void> deleteCategory(CategoryModel category) async {
    final box = await _categoryBox;
    final transactionBox = await _transactionBox;
    await box.delete(category.id);

    // set to null categoryId in transactions
    final transactions = transactionBox.values
        .where((elem) => elem.categoryId == category.id)
        .toList();
    for (final t in transactions) {
      await transactionBox.put(t.id, t.copyWith(categoryId: null));
    }
  }

  // MARK: - TRANSACTION
  /// get all transaction
  Future<List<TransactionModel>> getTransactions() async {
    final box = await _transactionBox;
    final transactions = box.values.toList();
    return transactions;
  }

  /// Save transaction
  Future<void> saveTransaction(TransactionModel model) async {
    final box = await _transactionBox;
    await box.put(model.id, model);
  }

  /// get transaction by id
  Future<TransactionModel?> getTransaction(String id) async {
    final box = await _transactionBox;
    return box.get(id);
  }

  /// delete transaction
  Future<void> deleteTransaction(TransactionModel model) async {
    final box = await _transactionBox;
    await box.delete(model.id);
  }

  /// Removes every transaction (e.g. settings “clear history”).
  Future<void> clearAllTransactions() async {
    final box = await _transactionBox;
    await box.clear();
  }
}
