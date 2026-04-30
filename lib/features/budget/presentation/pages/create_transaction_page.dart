import 'package:budget_app/features/budget/domain/entities/category.dart';
import 'package:budget_app/features/budget/domain/entities/transaction.dart';
import 'package:budget_app/features/budget/presentation/account/cubit/account_cubit.dart';
import 'package:budget_app/features/budget/presentation/pages/widgets/amount_keyboard.dart';
import 'package:budget_app/features/budget/presentation/transaction/cubit/transaction_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateTransactionPage extends StatefulWidget {
  const CreateTransactionPage({super.key});

  @override
  State<CreateTransactionPage> createState() => _CreateTransactionPageState();
}

class _CreateTransactionPageState extends State<CreateTransactionPage> {
  TransactionType selectedTransactionType = TransactionType.expense;
  String amount = '0';
  final List<Category> _expenseCategories = [
    Category(id: 'food', name: 'Food'),
    Category(id: 'transport', name: 'Transport'),
    Category(id: 'shopping', name: 'Shopping'),
    Category(id: 'bills', name: 'Bills'),
  ];
  double get _parsedAmount => double.tryParse(amount) ?? 0;
  bool get _canSubmit => _parsedAmount > 0;
  String get _amountLabel {
    final sign = selectedTransactionType == TransactionType.income ? '+' : '-';
    return '$sign$amount';
  }

  Future<void> _createAndRefresh({
    required double value,
    required TransactionType type,
    required Category category,
  }) async {
    await context.read<TransactionCubit>().createTransaction(
      Transaction(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        userId: 'me',
        amount: value,
        type: type,
        category: category,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        accountId: AccountCubit.defaultAccountId,
      ),
    );
    await context.read<AccountCubit>().loadAccounts();
  }

  Future<Category?> _showExpenseCategoryModal() async {
    Category? selectedCategory = _expenseCategories.first;
    final controller = TextEditingController();

    final result = await showModalBottomSheet<Category>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Select category',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _expenseCategories.map((category) {
                      final isSelected = selectedCategory?.id == category.id;
                      return ChoiceChip(
                        label: Text(category.name),
                        selected: isSelected,
                        onSelected: (_) {
                          setModalState(() {
                            selectedCategory = category;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Create category',
                      hintText: 'Example: Coffee',
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      final name = controller.text.trim();
                      if (name.isEmpty) return;
                      final created = Category(
                        id: DateTime.now().microsecondsSinceEpoch.toString(),
                        name: name,
                      );
                      setState(() {
                        _expenseCategories.add(created);
                      });
                      Navigator.pop(sheetContext, created);
                    },
                    child: const Text('Create and select'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: selectedCategory == null
                        ? null
                        : () => Navigator.pop(sheetContext, selectedCategory),
                    child: const Text('Continue'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    controller.dispose();
    return result;
  }

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
    final totalBalance = context.watch<AccountCubit>().state.totalBalance;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Totoal balance
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('баланс: '),
                  Text('$totalBalance', style: const TextStyle(fontSize: 20)),
                ],
              ),

              const SizedBox(height: 40),

              // Tab bar Income/Expense
              DefaultTabController(
                length: 2,
                initialIndex: 1,
                child: TabBar(
                  tabs: const [
                    Text('Income', style: TextStyle(fontSize: 20)),
                    Text(
                      'Expense',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  onTap: (index) {
                    setState(() {
                      selectedTransactionType = index == 0
                          ? TransactionType.income
                          : TransactionType.expense;
                    });
                  },
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                height: 96,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _amountLabel,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w600,
                        color: selectedTransactionType == TransactionType.income
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Amount keyboard
              Expanded(child: Center(child: AmountKeyboard(onTap: _onKeyTap))),

              const SizedBox(height: 12),

              // Submit transaction
              GestureDetector(
                onTap: !_canSubmit
                    ? null
                    : () async {
                        final value = _parsedAmount;

                        if (selectedTransactionType == TransactionType.income) {
                          await _createAndRefresh(
                            value: value,
                            type: selectedTransactionType,
                            category: Category(
                              id: DateTime.now().microsecondsSinceEpoch.toString(),
                              name: 'salary',
                            ),
                          );
                          if (context.mounted) {
                            setState(() {
                              amount = '0';
                            });
                          }
                          if (!context.mounted) return;
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        } else {
                          final selectedCategory =
                              await _showExpenseCategoryModal();
                          if (selectedCategory == null) return;

                          await _createAndRefresh(
                            value: value,
                            type: selectedTransactionType,
                            category: selectedCategory,
                          );
                          if (context.mounted) {
                            setState(() {
                              amount = '0';
                            });
                          }
                          if (!context.mounted) return;
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        }
                      },
                child: CircleAvatar(
                  radius: 42,
                  backgroundColor: !_canSubmit
                      ? Colors.grey.shade300
                      : Colors.green,
                  child: const Icon(Icons.check, size: 42, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
