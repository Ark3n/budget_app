import 'package:budget_app/features/budget/data/datasource/local_datasource.dart';
import 'package:budget_app/features/budget/data/datasource/remote_datasource.dart';
import 'package:budget_app/features/budget/data/models/category_model.dart';
import 'package:budget_app/features/budget/domain/entities/category.dart';
import 'package:budget_app/features/budget/domain/repository/category_repository.dart';

class CategoryRepoImp implements CategoryRepository {
  final LocalDatasource _localDatasource;
  final RemoteDatasource? _remoteDatasource;

  const CategoryRepoImp(this._localDatasource, [this._remoteDatasource]);

  @override
  Future<Category?> getCategory(String id) async {
    final category = await _localDatasource.getCategory(id);
    return category?.toEntity();
  }

  @override
  Future<List<Category>> getCategories() async {
    var categories = await _localDatasource.getCategories();
    if (categories.isEmpty &&
        _remoteDatasource != null &&
        _remoteDatasource.currentUserId != null) {
      try {
        final remoteCategories = await _remoteDatasource.getCategories();
        for (final category in remoteCategories) {
          await _localDatasource.saveCategory(category);
        }
        categories = await _localDatasource.getCategories();
      } catch (_) {}
    }
    return categories.map((category) => category.toEntity()).toList();
  }

  @override
  Future<void> saveCategory(Category category) async {
    final model = CategoryModel.fromEntity(category);
    await _localDatasource.saveCategory(model);
    try {
      await _remoteDatasource?.upsertCategory(model);
    } catch (_) {}
  }

  @override
  Future<void> deleteCategory(String id) async {
    final existing = await _localDatasource.getCategory(id);
    if (existing == null) return;
    await _localDatasource.deleteCategory(existing);
    try {
      await _remoteDatasource?.deleteCategory(id);
    } catch (_) {}
  }

  @override
  Future<void> backupToCloud() async {
    final remote = _remoteDatasource;
    if (remote == null) {
      throw Exception('Cloud backup is not configured.');
    }
    if (remote.currentUserId == null) {
      throw Exception('Please sign in to use cloud backup.');
    }
    final models = await _localDatasource.getCategories();
    for (final model in models) {
      await remote.upsertCategory(model);
    }
  }

  @override
  Future<void> restoreFromCloud({bool replaceLocal = true}) async {
    final remote = _remoteDatasource;
    if (remote == null) {
      throw Exception('Cloud backup is not configured.');
    }
    if (remote.currentUserId == null) {
      throw Exception('Please sign in to restore from cloud backup.');
    }
    final remoteModels = await remote.getCategories();
    if (replaceLocal) {
      await _localDatasource.clearAllCategories();
    }
    for (final model in remoteModels) {
      await _localDatasource.saveCategory(model);
    }
  }
}
