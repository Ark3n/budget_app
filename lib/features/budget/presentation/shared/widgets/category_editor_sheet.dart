import 'package:budget_app/features/budget/domain/entities/category.dart';
import 'package:budget_app/features/budget/presentation/shared/widgets/category_icons.dart';
import 'package:flutter/material.dart';

/// Result payload returned by the category editor bottom sheet.
class CategoryEditorResult {
  const CategoryEditorResult({
    required this.name,
    required this.iconKey,
    required this.colorKey,
  });

  final String name;
  final String iconKey;
  final String colorKey;
}

/// Opens a create/edit category sheet and returns user-selected values.
Future<CategoryEditorResult?> showCategoryEditorSheet(
  BuildContext context, {
  Category? existing,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final nameController = TextEditingController(text: existing?.name ?? '');
  var iconKey = existing?.icon ?? kCategoryPickerIcons.keys.first;
  if (!kCategoryPickerIcons.containsKey(iconKey)) {
    iconKey = kCategoryPickerIcons.keys.first;
  }
  var colorKey = existing?.color ?? kCategoryPickerColors.keys.first;
  if (!kCategoryPickerColors.containsKey(colorKey)) {
    colorKey = kCategoryPickerColors.keys.first;
  }

  return showModalBottomSheet<CategoryEditorResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    clipBehavior: Clip.antiAlias,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setLocalState) {
          final media = MediaQuery.of(context);
          final keyboardInset = media.viewInsets.bottom;
          final viewport =
              (media.size.height - keyboardInset - media.padding.top) * 0.9;
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
                      existing == null ? 'New category' : 'Edit category',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Category name',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Example: Coffee',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.outline.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Icon',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: kCategoryPickerIcons.entries.map((entry) {
                        final selected = iconKey == entry.key;
                        return FilterChip(
                          label: Icon(entry.value, size: 18),
                          selected: selected,
                          showCheckmark: false,
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          labelPadding: EdgeInsets.zero,
                          selectedColor: colorScheme.secondaryContainer,
                          side: BorderSide(
                            color: selected
                                ? Colors.transparent
                                : colorScheme.outline.withValues(alpha: 0.5),
                          ),
                          onSelected: (_) {
                            setLocalState(() => iconKey = entry.key);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Color',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: kCategoryPickerColors.entries.map((entry) {
                        final selected = colorKey == entry.key;
                        return FilterChip(
                          label: SizedBox(
                            width: 24,
                            height: 24,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: entry.value,
                                shape: BoxShape.circle,
                                border: selected
                                    ? Border.all(
                                        color: colorScheme.onSurface,
                                        width: 2,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          selected: selected,
                          showCheckmark: false,
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.all(4),
                          labelPadding: EdgeInsets.zero,
                          selectedColor: colorScheme.secondaryContainer,
                          side: BorderSide(
                            color: selected
                                ? Colors.transparent
                                : colorScheme.outline.withValues(alpha: 0.4),
                          ),
                          onSelected: (_) {
                            setLocalState(() => colorKey = entry.key);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        final name = nameController.text.trim();
                        if (name.isEmpty) return;
                        Navigator.pop(
                          sheetContext,
                          CategoryEditorResult(
                            name: name,
                            iconKey: iconKey,
                            colorKey: colorKey,
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        existing == null ? 'Create category' : 'Save changes',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
