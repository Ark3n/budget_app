import 'package:budget_app/features/budget/domain/entities/category.dart';

enum CategoryStatus { initial, loading, success, failure }

class CategoryState {
  final CategoryStatus status;
  final List<Category> categories;
  final String? error;

  const CategoryState({
    this.status = CategoryStatus.initial,
    this.categories = const [],
    this.error,
  });

  CategoryState copyWith({
    CategoryStatus? status,
    List<Category>? categories,
    String? error,
  }) {
    return CategoryState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      error: error,
    );
  }
}
