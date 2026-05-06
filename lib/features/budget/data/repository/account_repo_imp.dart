import 'package:budget_app/features/budget/data/datasource/local_datasource.dart';
import 'package:budget_app/features/budget/data/datasource/remote_datasource.dart';
import 'package:budget_app/features/budget/data/models/account_model.dart';
import 'package:budget_app/features/budget/domain/entities/account.dart';
import 'package:budget_app/features/budget/domain/repository/account_repository.dart';

class AccountRepoImp implements AccountRepository {
  final LocalDatasource _local;
  final RemoteDatasource? _remote;
  const AccountRepoImp(this._local, [this._remote]);

  @override
  Future<void> deleteAccount(String id) async {
    await _local.deleteAccount(id);
    try {
      await _remote?.deleteAccount(id);
    } catch (_) {}
  }

  @override
  Future<Account?> getAccount(String id) async {
    final model = await _local.getAccount(id);
    if (model == null) return null;
    return model.toEntity();
  }

  @override
  Future<List<Account>> getAllAccounts() async {
    var models = await _local.getAccounts();
    if (models.isEmpty && _remote != null && _remote.currentUserId != null) {
      try {
        final remoteModels = await _remote.getAccounts();
        for (final model in remoteModels) {
          await _local.saveAccount(model);
        }
        models = await _local.getAccounts();
      } catch (_) {}
    }
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> saveAccount(Account account) async {
    final model = AccountModel.fromEntity(account);
    await _local.saveAccount(model);
    try {
      await _remote?.upsertAccount(model);
    } catch (_) {}
  }

  @override
  Future<void> updateAccount(String id, double newBalance) async {
    final model = await _local.getAccount(id);
    if (model == null) return;
    final updated = model.copyWith(balance: newBalance);
    await _local.saveAccount(updated);
    try {
      await _remote?.upsertAccount(updated);
    } catch (_) {}
  }

  @override
  Future<void> renameAccount(String id, String newName) async {
    final model = await _local.getAccount(id);
    if (model == null) return;
    final updated = model.copyWith(name: newName);
    await _local.saveAccount(updated);
    try {
      await _remote?.upsertAccount(updated);
    } catch (_) {}
  }
}
