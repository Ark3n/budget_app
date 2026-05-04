import 'package:budget_app/features/budget/domain/entities/category.dart';
import 'package:flutter/material.dart';

/// Stored icon keys (Hive / [Category.icon]) → Material icons.
const Map<String, IconData> kCategoryPickerIcons = {
  'fastfood': Icons.fastfood,
  'directions_bus': Icons.directions_bus,
  'shopping_cart': Icons.shopping_cart,
  'receipt': Icons.receipt,
  'savings': Icons.savings,
  'restaurant': Icons.restaurant,
  'directions_car': Icons.directions_car,
  'shopping_bag': Icons.shopping_bag,
  'receipt_long': Icons.receipt_long,
  'payments': Icons.payments,
  'local_cafe': Icons.local_cafe,
  'fitness_center': Icons.fitness_center,
  'home': Icons.home,
};

/// When [Category.icon] is missing or unknown, map by normalized name.
const Map<String, IconData> kCategoryIconByName = {
  'food': Icons.fastfood,
  'transport': Icons.directions_bus,
  'shopping': Icons.shopping_cart,
  'bills': Icons.receipt,
  'salary': Icons.savings,
  'gym': Icons.fitness_center,
  'home': Icons.home,
  'car': Icons.directions_car,
};

const Map<String, Color> kCategoryPickerColors = {
  'blue': Colors.blue,
  'green': Colors.green,
  'orange': Colors.orange,
  'purple': Colors.purple,
  'red': Colors.red,
  'teal': Colors.teal,
};

/// Resolves a Material icon for chips, lists, and history.
IconData categoryIconFor({
  String? iconKey,
  String? categoryName,
}) {
  if (iconKey != null) {
    final fromKey = kCategoryPickerIcons[iconKey];
    if (fromKey != null) return fromKey;
  }
  if (categoryName != null && categoryName.isNotEmpty) {
    final fromName = kCategoryIconByName[categoryName.toLowerCase().trim()];
    if (fromName != null) return fromName;
  }
  return Icons.category;
}

IconData categoryIconFrom(Category? category) {
  if (category == null) return Icons.category;
  return categoryIconFor(iconKey: category.icon, categoryName: category.name);
}

Color categoryColorFor(String? colorKey) {
  if (colorKey == null) return Colors.grey;
  return kCategoryPickerColors[colorKey] ?? Colors.grey;
}
