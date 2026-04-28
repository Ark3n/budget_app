import 'package:budget_app/features/budget/domain/entities/category.dart';

enum TransactionType { income, expense }

class Transaction {
  final String id;
  final String userId;
  final String accountId;
  final double amount;
  final TransactionType type;
  final Category? category;
  String? description;
  final DateTime date; // 👈 дата операции
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.createdAt,
    required this.accountId,
  });
}
