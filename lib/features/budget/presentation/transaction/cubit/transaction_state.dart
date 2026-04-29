import 'package:budget_app/features/budget/domain/entities/transaction.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'transaction_state.freezed.dart';

enum TransactionStatus { initial, loading, success, failure }

@freezed
abstract class TransactionState with _$TransactionState {
  const TransactionState._();
  const factory TransactionState({
    @Default(TransactionStatus.initial) TransactionStatus status,
    @Default([]) List<Transaction> transactions,
    Transaction? transaction,
    String? error,
  }) = _TransactionState;
}
