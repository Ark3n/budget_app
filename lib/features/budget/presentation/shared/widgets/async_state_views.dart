import 'package:budget_app/features/budget/presentation/shared/widgets/budget_card.dart';
import 'package:flutter/material.dart';

/// Compact loading placeholder used inside cards/sections.
class BudgetLoadingView extends StatelessWidget {
  const BudgetLoadingView({super.key, this.height = 120});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

/// Standard message container for non-blocking empty/error states.
class BudgetMessageCard extends StatelessWidget {
  const BudgetMessageCard({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return BudgetCard(
      child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}
