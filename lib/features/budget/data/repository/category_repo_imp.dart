import 'package:budget_app/features/budget/data/datasource/local_datasource.dart';
import 'package:budget_app/features/budget/data/models/category_model.dart';
import 'package:budget_app/features/budget/domain/entities/category.dart';
import 'package:budget_app/features/budget/domain/repository/category_repository.dart';

class CategoryRepoImp implements CategoryRepository {
  final LocalDatasource _localDatasource;

  const CategoryRepoImp(this._localDatasource);

  @override
  Future<Category?> getCategory(String id) async {
    final category = await _localDatasource.getCategory(id);
    return category?.toEntity();
  }

  @override
  Future<List<Category>> getCategories() async {
    final categories = await _localDatasource.getCategories();
    return categories.map((category) => category.toEntity()).toList();
  }

  @override
  Future<void> saveCategory(Category category) async {
    await _localDatasource.saveCategory(CategoryModel.fromEntity(category));
  }

  @override
  Future<void> deleteCategory(String id) async {
    final existing = await _localDatasource.getCategory(id);
    if (existing == null) return;
    await _localDatasource.deleteCategory(existing);
  }
}
