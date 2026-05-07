import 'package:budget_app/core/utils/budget_defaults.dart';
import 'package:budget_app/features/budget/domain/entities/account.dart';
import 'package:budget_app/features/budget/domain/repository/account_repository.dart';
import 'package:budget_app/features/budget/presentation/account/cubit/account_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// AccountCubit states:
/// - initial: default state before any loading
/// - loading: loading or mutating account data
/// - success: accounts loaded and total balance calculated
/// - failure: account operation failed
class AccountCubit extends Cubit<AccountState> {
  static String get defaultAccountId => BudgetDefaults.defaultAccountId;
  static const String defaultAccountName = 'Salary';

  final AccountRepository _accountRepository;
  final String _authUserId;

  AccountCubit(this._accountRepository, {required String authUserId})
    : _authUserId = authUserId,
      super(const AccountState());

  Future<void> initialize() async {
    emit(state.copyWith(status: AccountStatus.loading, error: null));
    try {
      await _ensureDefaultAccount();
      await loadAccounts();
    } catch (e) {
      emit(state.copyWith(status: AccountStatus.failure, error: e.toString()));
    }
  }

  Future<void> loadAccounts() async {
    emit(state.copyWith(status: AccountStatus.loading, error: null));
    try {
      final accounts = await _accountRepository.getAllAccounts();
      final totalBalance = accounts.fold<double>(
        0,
        (sum, account) => sum + account.balance,
      );
      emit(
        state.copyWith(
          status: AccountStatus.success,
          accounts: accounts,
          totalBalance: totalBalance,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: AccountStatus.failure, error: e.toString()));
    }
  }

  Future<void> renameAccount({
    required String accountId,
    required String newName,
  }) async {
    final trimmedName = newName.trim();
    if (trimmedName.isEmpty) return;

    emit(state.copyWith(status: AccountStatus.loading, error: null));
    try {
      await _accountRepository.renameAccount(accountId, trimmedName);
      await loadAccounts();
    } catch (e) {
      emit(state.copyWith(status: AccountStatus.failure, error: e.toString()));
    }
  }

  /// Sets the default account balance to [BudgetDefaults.initialAccountBalance].
  /// Transaction history is unchanged; totals may no longer match.
  Future<void> resetBalanceToInitial() async {
    emit(state.copyWith(status: AccountStatus.loading, error: null));
    try {
      await _accountRepository.updateAccount(
        defaultAccountId,
        BudgetDefaults.initialAccountBalance,
      );
      await loadAccounts();
    } catch (e) {
      emit(state.copyWith(status: AccountStatus.failure, error: e.toString()));
    }
  }

  Future<void> _ensureDefaultAccount() async {
    final account = await _accountRepository.getAccount(defaultAccountId);
    if (account != null) return;

    await _accountRepository.saveAccount(
      Account(
        id: defaultAccountId,
        userId: _authUserId,
        name: defaultAccountName,
        balance: BudgetDefaults.initialAccountBalance,
        icon: null,
        color: null,
        createdAt: DateTime.now(),
      ),
    );
  }
}
