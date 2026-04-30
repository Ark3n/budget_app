import 'package:budget_app/features/budget/domain/entities/transaction.dart';
import 'package:budget_app/features/budget/presentation/transaction/cubit/transaction_cubit.dart';
import 'package:budget_app/features/budget/presentation/transaction/cubit/transaction_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_app/features/budget/presentation/account/cubit/account_cubit.dart';
import 'package:budget_app/features/budget/presentation/account/cubit/account_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budget planner')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              BlocBuilder<AccountCubit, AccountState>(
                builder: (context, state) {
                  if (state.status == AccountStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.status == AccountStatus.failure) {
                    return Center(
                      child: Text(state.error ?? 'Failed to load budget'),
                    );
                  }

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Budget',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${state.totalBalance.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'History',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: BlocBuilder<TransactionCubit, TransactionState>(
                  builder: (context, state) {
                    if (state.status == TransactionStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.status == TransactionStatus.failure) {
                      return Center(
                        child: Text(
                          state.error ?? 'Failed to load transactions',
                        ),
                      );
                    }
                    if (state.transactions.isEmpty) {
                      return const Center(child: Text('No transactions yet'));
                    }

                    return ListView.separated(
                      itemBuilder: (context, i) {
                        final transaction = state.transactions[i];
                        final isIncome =
                            transaction.type == TransactionType.income;
                        final amountPrefix = isIncome ? '+' : '-';
                        final amountColor = isIncome ? Colors.green : Colors.red;
                        final categoryName = transaction.category?.name ?? 'No category';
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          title: Text(categoryName),
                          subtitle: Text(
                            transaction.createdAt.toLocal().toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                            '$amountPrefix${transaction.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: amountColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, _) => const Divider(),
                      itemCount: state.transactions.length,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
