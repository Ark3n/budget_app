import 'package:budget_app/features/budget/domain/entities/transaction.dart';
import 'package:budget_app/features/budget/domain/exceptions/insufficient_balance_exception.dart';
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

  // get transactions
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

  // create transaction
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

  // update transaction
  Future<void> updateTransaction(Transaction transaction) async {
    emit(
      state.copyWith(
        status: TransactionStatus.loading,
        error: null,
        transaction: null,
      ),
    );
    try {
      await _transactionRepository.updateTransaction(transaction);
      // Refresh list so UI reflects the updated transaction.
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

  // delete transaction
  Future<void> deleteTransaction(Transaction transaction) async {
    emit(
      state.copyWith(
        status: TransactionStatus.loading,
        error: null,
        transaction: null,
      ),
    );
    try {
      await _transactionRepository.deleteTransaction(transaction);
      // Refresh list so UI reflects the deleted transaction.
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
