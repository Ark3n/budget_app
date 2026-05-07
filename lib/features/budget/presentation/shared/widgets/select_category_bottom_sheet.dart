import 'package:budget_app/features/budget/domain/entities/category.dart';
import 'package:budget_app/features/budget/presentation/category/cubit/category_cubit.dart';
import 'package:budget_app/features/budget/presentation/shared/budget_ui_tokens.dart';
import 'package:budget_app/features/budget/presentation/shared/widgets/category_editor_sheet.dart';
import 'package:budget_app/features/budget/presentation/shared/widgets/category_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Material Design bottom sheet: choose an existing category or create one.
///
/// Matches Figma frame `Select category / Material` in the Budget App file.
Future<Category?> showSelectCategorySheet(
  BuildContext context,
  List<Category> categories,
) {
  if (categories.isEmpty) return Future<Category?>.value(null);
  final categoryCubit = context.read<CategoryCubit>();

  return showModalBottomSheet<Category>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    clipBehavior: Clip.antiAlias,
    builder: (sheetContext) => BlocProvider.value(
      value: categoryCubit,
      child: _SelectCategorySheetContent(categories: categories),
    ),
  );
}

/// Internal content widget for category picking and quick creation flow.
class _SelectCategorySheetContent extends StatefulWidget {
  const _SelectCategorySheetContent({required this.categories});

  final List<Category> categories;

  @override
  State<_SelectCategorySheetContent> createState() =>
      _SelectCategorySheetContentState();
}

/// Holds local chip selection state before returning chosen category.
class _SelectCategorySheetContentState
    extends State<_SelectCategorySheetContent> {
  late Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.categories.first;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final media = MediaQuery.of(context);
    final keyboardInset = media.viewInsets.bottom;
    // Bounded height so [SingleChildScrollView] scrolls instead of overflowing.
    final viewport =
        (media.size.height - keyboardInset - media.padding.top) * 0.92;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: SizedBox(
        height: viewport.clamp(240.0, media.size.height * 0.95),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select category',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.categories.map((category) {
                  final selected = _selectedCategory?.id == category.id;
                  return FilterChip(
                    label: Text(category.name),
                    selected: selected,
                    showCheckmark: false,
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    avatar: CircleAvatar(
                      maxRadius: 12,
                      backgroundColor:
                          (kCategoryPickerColors[category.color] ??
                                  colorScheme.surfaceContainerHighest)
                              .withValues(alpha: 0.35),
                      child: Icon(
                        categoryIconFrom(category),
                        size: 16,
                        color: categoryColorFor(category.color),
                      ),
                    ),
                    selectedColor: colorScheme.secondaryContainer,
                    checkmarkColor: colorScheme.onSecondaryContainer,
                    side: BorderSide(
                      color: selected
                          ? Colors.transparent
                          : colorScheme.outline.withValues(alpha: 0.5),
                    ),
                    onSelected: (_) {
                      setState(() => _selectedCategory = category);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Divider(height: 1, color: colorScheme.outlineVariant),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () async {
                  final input = await showCategoryEditorSheet(context);
                  if (input == null || !context.mounted) return;
                  final cubit = context.read<CategoryCubit>();
                  final created = await cubit.createCategory(
                    input.name,
                    icon: input.iconKey,
                    color: input.colorKey,
                  );
                  if (!context.mounted || created == null) return;
                  Navigator.pop(context, created);
                },
                style: FilledButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  'Create and select',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _selectedCategory == null
                    ? null
                    : () => Navigator.pop(context, _selectedCategory),
                style: FilledButton.styleFrom(
                  backgroundColor: BudgetUiTokens.brandGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
