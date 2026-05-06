import 'package:budget_app/core/utils/budget_defaults.dart';
import 'package:budget_app/features/budget/domain/entities/category.dart';
import 'package:budget_app/features/budget/presentation/account/cubit/account_cubit.dart';
import 'package:budget_app/features/budget/presentation/account/cubit/account_state.dart';
import 'package:budget_app/features/budget/presentation/auth/cubit/auth_cubit.dart';
import 'package:budget_app/features/budget/presentation/category/cubit/category_cubit.dart';
import 'package:budget_app/features/budget/presentation/category/cubit/category_state.dart';
import 'package:budget_app/features/budget/presentation/shared/budget_ui_tokens.dart';
import 'package:budget_app/features/budget/presentation/shared/widgets/budget_card.dart';
import 'package:budget_app/features/budget/presentation/shared/widgets/category_editor_sheet.dart';
import 'package:budget_app/features/budget/presentation/shared/widgets/category_icons.dart';
import 'package:budget_app/features/budget/presentation/transaction/cubit/transaction_cubit.dart';
import 'package:budget_app/features/budget/presentation/transaction/cubit/transaction_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Settings and data management; visual language matches [HistoryPage].
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  /// Keeps salary first, then sorts the rest alphabetically.
  static List<Category> _sortedCategories(List<Category> categories) {
    final list = List<Category>.from(categories);
    list.sort((a, b) {
      final aSalary =
          a.name.toLowerCase() ==
          CategoryCubit.salaryCategoryName.toLowerCase();
      final bSalary =
          b.name.toLowerCase() ==
          CategoryCubit.salaryCategoryName.toLowerCase();
      if (aSalary != bSalary) return aSalary ? -1 : 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return list;
  }

  /// Shows a generic confirmation dialog for risky settings actions.
  static Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    bool danger = false,
  }) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: danger
                  ? colorScheme.error
                  : BudgetUiTokens.brandGreen,
              foregroundColor: danger ? colorScheme.onError : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Opens create/edit category sheet and persists the submitted values.
  static Future<void> _showCategoryEditor(
    BuildContext context, {
    Category? existing,
  }) async {
    final result = await showCategoryEditorSheet(context, existing: existing);
    if (result == null || !context.mounted) return;

    final cubit = context.read<CategoryCubit>();
    if (existing == null) {
      final created = await cubit.createCategory(
        result.name,
        icon: result.iconKey,
        color: result.colorKey,
      );
      if (!context.mounted) return;
      if (created == null) {
        final err = cubit.state.error ?? 'Could not create category.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(err)));
      }
      return;
    }

    await cubit.updateCategory(
      Category(
        id: existing.id,
        name: result.name,
        icon: result.iconKey,
        color: result.colorKey,
      ),
    );
    if (!context.mounted) return;
    if (cubit.state.status == CategoryStatus.failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cubit.state.error ?? 'Could not update category.'),
        ),
      );
    }
  }

  /// Confirms and deletes a category from settings.
  Future<void> _onDeleteCategory(BuildContext context, Category c) async {
    final ok = await _confirm(
      context,
      title: 'Delete category',
      message:
          'Remove “${c.name}”?\n\n'
          'Transactions that used it will show without a category.',
      confirmLabel: 'Delete',
      danger: true,
    );
    if (!ok || !context.mounted) return;
    await context.read<CategoryCubit>().deleteCategory(c.id);
  }

  /// Displays category management in a draggable bottom sheet.
  Future<void> _showCategoriesSheet(BuildContext context) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Categories',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: BlocBuilder<CategoryCubit, CategoryState>(
                        builder: (context, state) {
                          if (state.status == CategoryStatus.loading &&
                              state.categories.isEmpty) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (state.status == CategoryStatus.failure &&
                              state.categories.isEmpty) {
                            return Center(
                              child: Text(
                                state.error ?? 'Could not load categories',
                              ),
                            );
                          }
                          final items = _sortedCategories(state.categories);
                          return ListView.separated(
                            controller: scrollController,
                            itemCount: items.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, i) {
                              final c = items[i];
                              return BudgetCard(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor: categoryColorFor(
                                        c.color,
                                      ).withValues(alpha: 0.2),
                                      child: Icon(
                                        categoryIconFrom(c),
                                        color: categoryColorFor(c.color),
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            c.name,
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${c.icon ?? "—"} · ${c.color ?? "—"}',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined),
                                      onPressed: () => _showCategoryEditor(
                                        context,
                                        existing: c,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: colorScheme.error,
                                      ),
                                      onPressed: () =>
                                          _onDeleteCategory(context, c),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => _showCategoryEditor(context),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('Add category'),
                      style: FilledButton.styleFrom(
                        backgroundColor: BudgetUiTokens.brandGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Confirms destructive history clear and reloads account balance.
  Future<void> _onClearHistory(BuildContext context) async {
    final ok = await _confirm(
      context,
      title: 'Clear all history',
      message:
          'This deletes every transaction and resets your main account '
          'balance to \$${BudgetDefaults.initialAccountBalance.toStringAsFixed(2)}. '
          'Categories are kept.',
      confirmLabel: 'Clear all',
      danger: true,
    );
    if (!ok || !context.mounted) return;
    await context.read<TransactionCubit>().deleteAllTransactions();
    if (!context.mounted) return;
    final txState = context.read<TransactionCubit>().state;
    if (txState.status == TransactionStatus.failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(txState.error ?? 'Could not clear history.')),
      );
      return;
    }
    await context.read<AccountCubit>().loadAccounts();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All transactions were removed.')),
    );
  }

  /// Resets main account balance to default without touching transactions.
  Future<void> _onResetBalance(BuildContext context) async {
    final ok = await _confirm(
      context,
      title: 'Reset balance',
      message:
          'Set your main account balance to '
          '\$${BudgetDefaults.initialAccountBalance.toStringAsFixed(2)}? '
          'Existing transactions are not changed, so totals may not match.',
      confirmLabel: 'Reset',
      danger: true,
    );
    if (!ok || !context.mounted) return;
    await context.read<AccountCubit>().resetBalanceToInitial();
    if (!context.mounted) return;
    final accState = context.read<AccountCubit>().state;
    if (accState.status == AccountStatus.failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(accState.error ?? 'Could not reset balance.')),
      );
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Balance was reset.')));
  }

  /// Signs out the current authenticated user.
  Future<void> _onSignOut(BuildContext context) async {
    await context.read<AuthCubit>().signOut();
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
                'Settings',
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
                    Text(
                      'Manage',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    BudgetCard(
                      padding: EdgeInsets.zero,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        title: const Text('Categories'),
                        subtitle: Text(
                          'Create, edit, and delete categories.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onTap: () => _showCategoriesSheet(context),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Data',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    BudgetCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            title: const Text('Clear all history'),
                            subtitle: Text(
                              'Delete every transaction and reset balance to '
                              '\$${BudgetDefaults.initialAccountBalance.toStringAsFixed(2)}.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            trailing: Icon(
                              Icons.chevron_right,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            onTap: () => _onClearHistory(context),
                          ),
                          Divider(
                            height: 1,
                            indent: 20,
                            endIndent: 20,
                            color: colorScheme.outline.withValues(alpha: 0.3),
                          ),
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            title: Text(
                              'Reset balance',
                              style: TextStyle(color: colorScheme.error),
                            ),
                            subtitle: Text(
                              'Set balance only; does not change transactions.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            trailing: Icon(
                              Icons.chevron_right,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            onTap: () => _onResetBalance(context),
                          ),
                          Divider(
                            height: 1,
                            indent: 20,
                            endIndent: 20,
                            color: colorScheme.outline.withValues(alpha: 0.3),
                          ),
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            title: Text(
                              'Sign out',
                              style: TextStyle(color: colorScheme.error),
                            ),
                            subtitle: Text(
                              'Sign out from this device.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            trailing: Icon(
                              Icons.chevron_right,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            onTap: () => _onSignOut(context),
                          ),
                        ],
                      ),
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
