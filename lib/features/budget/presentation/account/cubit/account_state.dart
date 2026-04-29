import 'package:budget_app/features/budget/domain/entities/account.dart';

enum AccountStatus { initial, loading, success, failure }

class AccountState {
  final AccountStatus status;
  final List<Account> accounts;
  final double totalBalance;
  final String? error;

  const AccountState({
    this.status = AccountStatus.initial,
    this.accounts = const [],
    this.totalBalance = 0,
    this.error,
  });

  AccountState copyWith({
    AccountStatus? status,
    List<Account>? accounts,
    double? totalBalance,
    String? error,
  }) {
    return AccountState(
      status: status ?? this.status,
      accounts: accounts ?? this.accounts,
      totalBalance: totalBalance ?? this.totalBalance,
      error: error,
    );
  }
}
