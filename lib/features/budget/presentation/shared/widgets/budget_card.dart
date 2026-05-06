import 'package:budget_app/features/budget/presentation/shared/budget_ui_tokens.dart';
import 'package:flutter/material.dart';

/// Shared card shell that centralizes elevation, radius, and padding.
class BudgetCard extends StatelessWidget {
  const BudgetCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 20, 20, 24),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: BudgetUiTokens.cardElevation,
      shadowColor: BudgetUiTokens.cardShadow,
      shape: const RoundedRectangleBorder(
        borderRadius: BudgetUiTokens.cardRadius,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
