import 'package:budget_app/features/budget/data/datasource/local_datasource.dart';
import 'package:budget_app/features/budget/data/models/account_model.dart';
import 'package:budget_app/features/budget/domain/entities/account.dart';
import 'package:budget_app/features/budget/domain/repository/account_repository.dart';

class AccountRepoImp implements AccountRepository {
  final LocalDatasource _local;
  const AccountRepoImp(this._local);

  @override
  Future<void> deleteAccount(String id) async {
    await _local.deleteAccount(id);
  }

  @override
  Future<Account?> getAccount(String id) async {
    final model = await _local.getAccount(id);
    if (model == null) return null;
    return model.toEntity();
  }

  @override
  Future<List<Account>> getAllAccounts() async {
    final models = await _local.getAccounts();
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> saveAccount(Account account) async {
    await _local.saveAccount(AccountModel.fromEntity(account));
  }

  @override
  Future<void> updateAccount(String id, double newBalance) async {
    final model = await _local.getAccount(id);
    if (model == null) return;
    final updated = model.copyWith(balance: newBalance);
    await _local.saveAccount(updated);
  }
}
