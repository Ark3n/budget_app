import 'package:budget_app/features/budget/domain/entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getCategories();
  Future<Category?> getCategory(String id);
  Future<void> saveCategory(Category category);
  Future<void> deleteCategory(String id);
  Future<void> backupToCloud();
  Future<void> restoreFromCloud({bool replaceLocal = true});
}
