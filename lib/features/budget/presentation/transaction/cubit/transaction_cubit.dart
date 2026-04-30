import 'package:budget_app/features/budget/domain/entities/transaction.dart';
import 'package:budget_app/features/budget/domain/repository/transaction_repository.dart';
import 'package:budget_app/features/budget/presentation/transaction/cubit/transaction_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionCubit extends Cubit<TransactionState> {
  final TransactionRepository _transactionRepository;
  TransactionCubit(this._transactionRepository)
    : super(const TransactionState());

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
        state.copyWith(status: TransactionStatus.failure, error: e.toString()),
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
        state.copyWith(status: TransactionStatus.failure, error: e.toString()),
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
        state.copyWith(status: TransactionStatus.failure, error: e.toString()),
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
        state.copyWith(status: TransactionStatus.failure, error: e.toString()),
      );
    }
  }
}
