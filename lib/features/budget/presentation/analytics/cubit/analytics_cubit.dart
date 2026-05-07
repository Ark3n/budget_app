import 'package:budget_app/features/budget/domain/entities/transaction.dart';
import 'package:budget_app/features/budget/presentation/analytics/cubit/analytics_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AnalyticsCubit extends Cubit<AnalyticsState> {
  List<Transaction> _allTransactions = const [];

  AnalyticsCubit() : super(const AnalyticsState());

  void syncTransactions(List<Transaction> transactions) {
    _allTransactions = transactions;
    _recompute();
  }

  void setRange(AnalyticsRange range) {
    if (range == state.selectedRange) return;
    emit(state.copyWith(selectedRange: range));
    _recompute();
  }

  void _recompute() {
    final filtered = _filterByRange(
      _allTransactions,
      range: state.selectedRange,
      now: DateTime.now(),
    );
    if (filtered.isEmpty) {
      emit(
        state.copyWith(
          status: AnalyticsStatus.empty,
          balancePoints: const [],
          categorySlices: const [],
          totalExpenses: 0,
        ),
      );
      return;
    }

    final chronological = [...filtered]
      ..sort((a, b) => a.date.compareTo(b.date));
    final balancePoints = <BalancePoint>[];
    var runningBalance = 0.0;

    for (final transaction in chronological) {
      final signedAmount = transaction.type == TransactionType.income
          ? transaction.amount
          : -transaction.amount;
      runningBalance += signedAmount;
      balancePoints.add(
        BalancePoint(date: transaction.date, balance: runningBalance),
      );
    }

    final expensesByCategory = <String, _CategoryAggregate>{};
    for (final transaction in chronological) {
      if (transaction.type != TransactionType.expense) continue;
      final name = transaction.category?.name ?? 'Uncategorized';
      final current = expensesByCategory[name];
      if (current == null) {
        expensesByCategory[name] = _CategoryAggregate(
          amount: transaction.amount,
          colorKey: transaction.category?.color,
          iconKey: transaction.category?.icon,
        );
      } else {
        expensesByCategory[name] = _CategoryAggregate(
          amount: current.amount + transaction.amount,
          colorKey: current.colorKey,
          iconKey: current.iconKey,
        );
      }
    }

    final sortedSlices =
        expensesByCategory.entries
            .map(
              (entry) => CategorySlice(
                label: entry.key,
                amount: entry.value.amount,
                colorKey: entry.value.colorKey,
                iconKey: entry.value.iconKey,
              ),
            )
            .toList()
          ..sort((a, b) => b.amount.compareTo(a.amount));

    final totalExpenses = sortedSlices.fold<double>(
      0,
      (sum, slice) => sum + slice.amount,
    );

    emit(
      state.copyWith(
        status: balancePoints.isEmpty
            ? AnalyticsStatus.empty
            : AnalyticsStatus.success,
        balancePoints: balancePoints,
        categorySlices: sortedSlices,
        totalExpenses: totalExpenses,
      ),
    );
  }

  List<Transaction> _filterByRange(
    List<Transaction> transactions, {
    required AnalyticsRange range,
    required DateTime now,
  }) {
    final localNow = now.toLocal();
    return transactions.where((tx) {
      final date = tx.date.toLocal();
      switch (range) {
        case AnalyticsRange.today:
          return date.year == localNow.year &&
              date.month == localNow.month &&
              date.day == localNow.day;
        case AnalyticsRange.week:
          final startOfWeek = DateTime(
            localNow.year,
            localNow.month,
            localNow.day,
          ).subtract(Duration(days: localNow.weekday - 1));
          final startOfNextWeek = startOfWeek.add(const Duration(days: 7));
          return !date.isBefore(startOfWeek) && date.isBefore(startOfNextWeek);
        case AnalyticsRange.month:
          return date.year == localNow.year && date.month == localNow.month;
        case AnalyticsRange.year:
          return date.year == localNow.year;
      }
    }).toList();
  }
}

class _CategoryAggregate {
  final double amount;
  final String? colorKey;
  final String? iconKey;

  const _CategoryAggregate({
    required this.amount,
    required this.colorKey,
    required this.iconKey,
  });
}
