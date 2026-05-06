import 'package:budget_app/features/budget/data/models/account_model.dart';
import 'package:budget_app/features/budget/data/models/category_model.dart';
import 'package:budget_app/features/budget/data/models/transaction_model.dart';
import 'package:budget_app/features/budget/domain/entities/transaction.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Lightweight Supabase access layer used for local-first cloud backup.
class RemoteDatasource {
  static const String _accountsTable = 'accounts';
  static const String _categoriesTable = 'categories';
  static const String _transactionsTable = 'transactions';

  final supabase.SupabaseClient _client;

  const RemoteDatasource(this._client);

  String? get currentUserId => _client.auth.currentUser?.id;

  Future<void> upsertAccount(AccountModel model) async {
    final userId = currentUserId;
    if (userId == null) return;
    await _client.from(_accountsTable).upsert({
      'id': model.id,
      'user_id': userId,
      'name': model.name,
      'balance': model.balance,
      'icon': model.icon,
      'color': model.color,
      'created_at': model.createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteAccount(String id) async {
    final userId = currentUserId;
    if (userId == null) return;
    await _client.from(_accountsTable).delete().eq('id', id).eq('user_id', userId);
  }

  Future<List<AccountModel>> getAccounts() async {
    final userId = currentUserId;
    if (userId == null) return const [];
    final rows = await _client
        .from(_accountsTable)
        .select()
        .eq('user_id', userId)
        .order('created_at');
    return (rows as List<dynamic>)
        .map((row) => AccountModel.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<void> upsertCategory(CategoryModel model) async {
    final userId = currentUserId;
    if (userId == null) return;
    await _client.from(_categoriesTable).upsert({
      'id': model.id,
      'user_id': userId,
      'name': model.name,
      'icon': model.icon,
      'color': model.color,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteCategory(String id) async {
    final userId = currentUserId;
    if (userId == null) return;
    await _client
        .from(_categoriesTable)
        .delete()
        .eq('id', id)
        .eq('user_id', userId);
  }

  Future<List<CategoryModel>> getCategories() async {
    final userId = currentUserId;
    if (userId == null) return const [];
    final rows = await _client
        .from(_categoriesTable)
        .select()
        .eq('user_id', userId)
        .order('name');
    return (rows as List<dynamic>)
        .map((row) => CategoryModel.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<void> upsertTransaction(TransactionModel model) async {
    final userId = currentUserId;
    if (userId == null) return;
    await _client.from(_transactionsTable).upsert({
      'id': model.id,
      'user_id': userId,
      'amount': model.amount,
      'type': model.type.name,
      'category_id': model.categoryId,
      'description': model.description,
      'date': model.date.toIso8601String(),
      'created_at': model.createdAt.toIso8601String(),
      'account_id': model.accountId,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> clearTransactions() async {
    final userId = currentUserId;
    if (userId == null) return;
    await _client.from(_transactionsTable).delete().eq('user_id', userId);
  }

  Future<List<TransactionModel>> getTransactions() async {
    final userId = currentUserId;
    if (userId == null) return const [];
    final rows = await _client
        .from(_transactionsTable)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (rows as List<dynamic>).map((row) {
      final json = Map<String, dynamic>.from(row);
      final rawType = (json['type'] as String?) ?? TransactionType.expense.name;
      final parsedType = TransactionType.values.firstWhere(
        (t) => t.name == rawType,
        orElse: () => TransactionType.expense,
      );
      return TransactionModel(
        id: (json['id'] as String?) ?? '',
        userId: (json['user_id'] as String?) ?? userId,
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        type: parsedType,
        categoryId: json['category_id'] as String?,
        description: json['description'] as String?,
        date:
            DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
        createdAt:
            DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.now(),
        accountId: (json['account_id'] as String?) ?? '',
      );
    }).toList();
  }
}
