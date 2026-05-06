import 'package:budget_app/features/budget/domain/entities/category.dart';
import 'package:budget_app/features/budget/domain/entities/transaction.dart';
import 'package:budget_app/core/utils/id_generator.dart';
import 'package:budget_app/features/budget/presentation/account/cubit/account_cubit.dart';
import 'package:budget_app/features/budget/presentation/category/cubit/category_cubit.dart';
import 'package:budget_app/features/budget/presentation/shared/budget_ui_tokens.dart';
import 'package:budget_app/features/budget/presentation/shared/widgets/amount_keyboard.dart';
import 'package:budget_app/features/budget/presentation/shared/widgets/budget_card.dart';
import 'package:budget_app/features/budget/presentation/shared/widgets/select_category_bottom_sheet.dart';
import 'package:budget_app/features/budget/presentation/transaction/cubit/transaction_cubit.dart';
import 'package:budget_app/features/budget/presentation/transaction/cubit/transaction_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Transaction entry screen with amount keypad and type selection.
class CreateTransactionPage extends StatefulWidget {
  const CreateTransactionPage({super.key});

  @override
  State<CreateTransactionPage> createState() => _CreateTransactionPageState();
}

class _CreateTransactionPageState extends State<CreateTransactionPage> {
  static const IdGenerator _idGenerator = TimestampIdGenerator();

  TransactionType selectedTransactionType = TransactionType.expense;
  String amount = '0';
  double get _parsedAmount => double.tryParse(amount) ?? 0;
  bool get _canSubmit => _parsedAmount > 0;

  /// Material-style amount, e.g. `-$278.40` or `+$100`.
  String get _amountDisplay {
    final sign = selectedTransactionType == TransactionType.income ? '+' : '-';
    return '$sign\$$amount';
  }

  /// Creates the transaction and refreshes account totals after a success.
  Future<void> _createAndRefresh({
    required double value,
    required TransactionType type,
    required Category category,
  }) async {
    final transactionCubit = context.read<TransactionCubit>();
    await transactionCubit.createTransaction(
      Transaction(
        id: _idGenerator.nextId(),
        userId: 'me',
        amount: value,
        type: type,
        category: category,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        accountId: AccountCubit.defaultAccountId,
      ),
    );
    if (!mounted) return;
    if (transactionCubit.state.status == TransactionStatus.failure) {
      final message =
          transactionCubit.state.error ??
          "We couldn’t save this transaction. Please try again.";
      final colorScheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: colorScheme.inverseSurface,
          content: Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onInverseSurface,
            ),
          ),
        ),
      );
      await transactionCubit.clearTransientFailure();
      return;
    }
    await context.read<AccountCubit>().loadAccounts();
  }

  /// Submits either income (salary) or expense with selected category.
  Future<void> _submit(List<Category> expenseCategories) async {
    if (!_canSubmit) return;
    final value = _parsedAmount;

    if (selectedTransactionType == TransactionType.income) {
      final salaryCategory = await context
          .read<CategoryCubit>()
          .ensureSalaryCategory();
      if (!mounted) return;
      await _createAndRefresh(
        value: value,
        type: selectedTransactionType,
        category: salaryCategory,
      );
      if (!mounted) return;
      setState(() => amount = '0');
      if (Navigator.canPop(context)) Navigator.pop(context);
      return;
    }

    final selectedCategory = await showSelectCategorySheet(
      context,
      expenseCategories,
    );
    if (selectedCategory == null) return;
    if (!mounted) return;

    await _createAndRefresh(
      value: value,
      type: selectedTransactionType,
      category: selectedCategory,
    );
    if (!mounted) return;
    setState(() => amount = '0');
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  /// Handles numeric keypad interactions, including decimal and backspace.
  void _onKeyTap(String value) {
    setState(() {
      if (value == '.') {
        if (!amount.contains('.')) {
          amount += '.';
        }
        return;
      }

      if (value == 'back') {
        if (amount.length > 1) {
          amount = amount.substring(0, amount.length - 1);
        } else {
          amount = '0';
        }
        return;
      }

      if (amount == '0') {
        amount = value;
      } else {
        amount += value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryCubit>().state.categories;
    final expenseCategories = categories
        .where(
          (category) =>
              category.name.toLowerCase() !=
              CategoryCubit.salaryCategoryName.toLowerCase(),
        )
        .toList();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final amountColor = selectedTransactionType == TransactionType.income
        ? BudgetUiTokens.brandGreen
        : colorScheme.error;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Create Transaction',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BudgetCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current amount',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _amountDisplay,
                              maxLines: 1,
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: amountColor,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SegmentedButton<TransactionType>(
                      segments: const [
                        ButtonSegment<TransactionType>(
                          value: TransactionType.income,
                          label: Text('Income'),
                        ),
                        ButtonSegment<TransactionType>(
                          value: TransactionType.expense,
                          label: Text('Expense'),
                        ),
                      ],
                      selected: {selectedTransactionType},
                      onSelectionChanged: (Set<TransactionType> next) {
                        setState(() {
                          selectedTransactionType = next.first;
                        });
                      },
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor:
                            selectedTransactionType == TransactionType.expense
                            ? colorScheme.error
                            : colorScheme.primaryContainer,
                        selectedForegroundColor:
                            selectedTransactionType == TransactionType.expense
                            ? colorScheme.onError
                            : colorScheme.onPrimaryContainer,
                        side: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        visualDensity: VisualDensity.comfortable,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AmountKeyboard(onTap: _onKeyTap),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: FilledButton(
                onPressed: _canSubmit ? () => _submit(expenseCategories) : null,
                style: FilledButton.styleFrom(
                  backgroundColor: BudgetUiTokens.brandGreen,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: colorScheme.surfaceContainerHighest,
                  disabledForegroundColor: colorScheme.onSurfaceVariant,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
