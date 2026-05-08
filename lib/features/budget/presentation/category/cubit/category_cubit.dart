import 'package:budget_app/features/budget/domain/entities/category.dart';
import 'package:budget_app/features/budget/domain/repository/category_repository.dart';
import 'package:budget_app/features/budget/presentation/category/cubit/category_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryCubit extends Cubit<CategoryState> {
  static const Map<String, Map<String, String>> _defaultExpenseCategories = {
    'Food': {'icon': 'fastfood', 'color': 'orange'},
    'Transport': {'icon': 'directions_bus', 'color': 'blue'},
    'Shopping': {'icon': 'shopping_cart', 'color': 'purple'},
    'Bills': {'icon': 'receipt', 'color': 'red'},
  };
  static const String salaryCategoryName = 'Salary';

  final CategoryRepository _categoryRepository;

  CategoryCubit(this._categoryRepository) : super(const CategoryState());

  Future<void> initialize() async {
    emit(state.copyWith(status: CategoryStatus.loading, error: null));
    try {
      final existing = await _categoryRepository.getCategories();
      if (existing.isEmpty) {
        await _seedDefaults();
      } else {
        final hasSalary = existing.any(
          (category) =>
              category.name.toLowerCase() == salaryCategoryName.toLowerCase(),
        );
        if (!hasSalary) {
          await _categoryRepository.saveCategory(
            Category(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              name: salaryCategoryName,
              icon: 'savings',
              color: 'green',
            ),
          );
        }
      }
      await loadCategories();
    } catch (e) {
      emit(state.copyWith(status: CategoryStatus.failure, error: e.toString()));
    }
  }

  Future<void> loadCategories() async {
    emit(state.copyWith(status: CategoryStatus.loading, error: null));
    try {
      final categories = await _categoryRepository.getCategories();
      emit(
        state.copyWith(
          status: CategoryStatus.success,
          categories: categories,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: CategoryStatus.failure, error: e.toString()));
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await _categoryRepository.saveCategory(category);
      await loadCategories();
    } catch (e) {
      emit(state.copyWith(status: CategoryStatus.failure, error: e.toString()));
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _categoryRepository.deleteCategory(id);
      await loadCategories();
    } catch (e) {
      emit(state.copyWith(status: CategoryStatus.failure, error: e.toString()));
    }
  }

  /// Returns the new category, or `null` if saving failed.
  Future<Category?> createCategory(
    String name, {
    String? icon,
    String? color,
  }) async {
    final category = Category(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      icon: icon,
      color: color,
    );
    try {
      await _categoryRepository.saveCategory(category);
      await loadCategories();
      return category;
    } catch (e) {
      emit(state.copyWith(status: CategoryStatus.failure, error: e.toString()));
      return null;
    }
  }

  Future<Category> ensureSalaryCategory() async {
    final existing = state.categories.firstWhere(
      (category) =>
          category.name.toLowerCase() == salaryCategoryName.toLowerCase(),
      orElse: () => Category(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: salaryCategoryName,
        icon: 'savings',
        color: 'green',
      ),
    );
    final hasExisting = state.categories.any(
      (category) => category.id == existing.id,
    );
    if (hasExisting) return existing;
    await _categoryRepository.saveCategory(existing);
    await loadCategories();
    return existing;
  }

  Future<void> _seedDefaults() async {
    for (final entry in _defaultExpenseCategories.entries) {
      await _categoryRepository.saveCategory(
        Category(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: entry.key,
          icon: entry.value['icon'],
          color: entry.value['color'],
        ),
      );
    }
    await _categoryRepository.saveCategory(
      Category(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: salaryCategoryName,
        icon: 'savings',
        color: 'green',
      ),
    );
  }

  Future<void> backupToCloud() async {
    await _categoryRepository.backupToCloud();
  }

  Future<void> restoreFromCloud() async {
    await _categoryRepository.restoreFromCloud(replaceLocal: true);
    await loadCategories();
    await ensureSalaryCategory();
  }
}
