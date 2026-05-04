import 'package:budget_app/features/budget/domain/entities/transaction.dart';
import 'package:budget_app/features/budget/presentation/account/cubit/account_cubit.dart';
import 'package:budget_app/features/budget/presentation/account/cubit/account_state.dart';
import 'package:budget_app/features/budget/presentation/pages/widgets/category_icons.dart';
import 'package:budget_app/features/budget/presentation/transaction/cubit/transaction_cubit.dart';
import 'package:budget_app/features/budget/presentation/transaction/cubit/transaction_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Matches spacing, typography, and card styling from [CreateTransactionPage].
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  static const Color _brandGreen = Color(0xFF29A36A);

  static String _formatTransactionDate(DateTime utc) {
    final d = utc.toLocal();
    final h = d.hour;
    final h12 = h % 12 == 0 ? 12 : h % 12;
    final mm = d.minute.toString().padLeft(2, '0');
    final ampm = h < 12 ? 'AM' : 'PM';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} · $h12:$mm $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Text(
                'History',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BlocBuilder<AccountCubit, AccountState>(
                      builder: (context, state) {
                        if (state.status == AccountStatus.loading) {
                          return const SizedBox(
                            height: 120,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (state.status == AccountStatus.failure) {
                          return _MessageCard(
                            message: state.error ?? 'Failed to load budget',
                          );
                        }
                        return Card(
                          elevation: 2,
                          shadowColor: Colors.black26,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Balance',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '\$${state.totalBalance.toStringAsFixed(2)}',
                                    maxLines: 1,
                                    style: theme.textTheme.displaySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: _brandGreen,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<TransactionCubit, TransactionState>(
                      builder: (context, state) {
                        if (state.status == TransactionStatus.loading) {
                          return const SizedBox(
                            height: 200,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final failureBlocksList =
                            state.status == TransactionStatus.failure &&
                            state.transactions.isEmpty;
                        if (failureBlocksList) {
                          return _MessageCard(
                            message:
                                state.error ?? 'Failed to load transactions',
                          );
                        }
                        if (state.transactions.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Text(
                                'No transactions yet',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.transactions.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final transaction = state.transactions[i];
                            return _HistoryTransactionTile(
                              transaction: transaction,
                              formatDate: _formatTransactionDate,
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Text(
          message,
          style: theme.textTheme.bodyMedium,
        ),
      ),
    );
  }
}

class _HistoryTransactionTile extends StatelessWidget {
  const _HistoryTransactionTile({
    required this.transaction,
    required this.formatDate,
  });

  final Transaction transaction;
  final String Function(DateTime utc) formatDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isIncome = transaction.type == TransactionType.income;
    final amountPrefix = isIncome ? '+' : '-';
    final amountColor = isIncome ? colorScheme.primary : colorScheme.error;
    final categoryName = transaction.category?.name ?? 'No category';
    final catColor = categoryColorFor(transaction.category?.color);

    return Card(
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: catColor.withValues(alpha: 0.2),
              child: Icon(
                categoryIconFrom(transaction.category),
                color: catColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatDate(transaction.createdAt),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$amountPrefix\$${transaction.amount.toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: amountColor,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
