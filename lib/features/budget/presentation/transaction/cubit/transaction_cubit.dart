import 'package:budget_app/features/budget/domain/entities/transaction.dart';
import 'package:budget_app/core/exceptions/insufficient_balance_exception.dart';
import 'package:budget_app/features/budget/domain/repository/transaction_repository.dart';
import 'package:budget_app/features/budget/presentation/transaction/cubit/transaction_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionCubit extends Cubit<TransactionState> {
  final TransactionRepository _transactionRepository;
  TransactionCubit(this._transactionRepository)
    : super(const TransactionState());

  /// Resets a mutation error so list screens don’t treat [TransactionStatus.failure]
  /// as “failed to load” while cached [TransactionState.transactions] are still valid.
  Future<void> clearTransientFailure() async {
    if (state.status != TransactionStatus.failure) return;
    if (state.transactions.isNotEmpty) {
      emit(state.copyWith(status: TransactionStatus.success, error: null));
      return;
    }
    await getTransactions();
  }

  /// Maps low-level exceptions into user-friendly messages for the UI layer.
  static String _userFacingMessage(Object error) {
    if (error is InsufficientBalanceException) {
      return InsufficientBalanceException.userMessage;
    }
    final raw = error.toString();
    if (raw.startsWith('Exception: ')) {
      return raw.substring('Exception: '.length);
    }
    return "We couldn’t save your change. Please try again.";
  }

  /// Loads transactions from storage and keeps the newest entries first.
  Future<void> getTransactions() async {
    emit(
      state.copyWith(
        status: TransactionStatus.loading,
        error: null,
        transaction: null,
      ),
    );
    try {
      final transactions = await _transactionRepository.getTransactions();
      final sortedTransactions = [...transactions]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(
        state.copyWith(
          status: TransactionStatus.success,
          transactions: sortedTransactions,
          error: null,
          transaction: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: TransactionStatus.failure,
          error: _userFacingMessage(e),
        ),
      );
    }
  }

  /// Persists a transaction, then refreshes the list to keep state in sync.
  Future<void> createTransaction(Transaction transaction) async {
    emit(
      state.copyWith(
        status: TransactionStatus.loading,
        error: null,
        transaction: null,
      ),
    );
    try {
      await _transactionRepository.createTransaction(transaction);

      // Refresh list so UI reflects the newly-created transaction.
      await getTransactions();
    } catch (e) {
      emit(
        state.copyWith(
          status: TransactionStatus.failure,
          error: _userFacingMessage(e),
        ),
      );
    }
  }

  /// Clears every transaction and resets the default account balance.
  Future<void> deleteAllTransactions() async {
    emit(
      state.copyWith(
        status: TransactionStatus.loading,
        error: null,
        transaction: null,
      ),
    );
    try {
      await _transactionRepository.deleteAllTransactions();
      emit(
        state.copyWith(
          status: TransactionStatus.success,
          transactions: const [],
          error: null,
          transaction: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: TransactionStatus.failure,
          error: _userFacingMessage(e),
        ),
      );
    }
  }

  Future<void> backupToCloud() async {
    try {
      await _transactionRepository.backupToCloud();
    } catch (e) {
      emit(
        state.copyWith(
          status: TransactionStatus.failure,
          error: _userFacingMessage(e),
        ),
      );
    }
  }

  Future<void> restoreFromCloud() async {
    emit(
      state.copyWith(
        status: TransactionStatus.loading,
        error: null,
        transaction: null,
      ),
    );
    try {
      await _transactionRepository.restoreFromCloud(replaceLocal: true);
      await getTransactions();
    } catch (e) {
      emit(
        state.copyWith(
          status: TransactionStatus.failure,
          error: _userFacingMessage(e),
        ),
      );
    }
  }
}
