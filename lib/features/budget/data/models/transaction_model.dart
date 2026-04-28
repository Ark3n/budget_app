import 'package:budget_app/features/budget/domain/entities/category.dart';
import 'package:budget_app/features/budget/domain/entities/transaction.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce/hive.dart';
part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart';

@freezed
@HiveType(typeId: 0)
abstract class TransactionModel with _$TransactionModel {
  const TransactionModel._();
  const factory TransactionModel({
    @HiveField(0) required String id,
    @HiveField(1) @JsonKey(name: 'user_id') required String userId,
    @HiveField(2) required double amount,
    @HiveField(3) required TransactionType type,
    @HiveField(4) @JsonKey(name: 'category_id') String? categoryId,
    @HiveField(5) String? description,
    @HiveField(6) required DateTime date, // 👈 дата операции
    @HiveField(7) @JsonKey(name: 'created_at') required DateTime createdAt,
    @HiveField(8) @JsonKey(name: 'account_id') required String accountId,
  }) = _TransactionModel;

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  Transaction toEntity(Category? category) {
    return Transaction(
      id: id,
      userId: userId,
      accountId: accountId,
      amount: amount,
      type: type,
      category: category,
      date: date,
      createdAt: createdAt,
    );
  }

  factory TransactionModel.fromEntity(Transaction transaction) {
    return TransactionModel(
      id: transaction.id,
      userId: transaction.userId,
      accountId: transaction.accountId,
      amount: transaction.amount,
      type: transaction.type,
      categoryId: transaction.category?.id,
      description: transaction.description,
      date: transaction.date,
      createdAt: transaction.createdAt,
    );
  }
}
