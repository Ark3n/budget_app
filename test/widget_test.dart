import 'package:budget_app/features/budget/domain/entities/account.dart';
import 'package:budget_app/features/budget/domain/repository/account_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:budget_app/main.dart';

class _FakeAccountRepository implements AccountRepository {
  final List<Account> _accounts = [
    Account(
      id: 'default_salary_account',
      userId: 'local_user',
      name: 'Salary',
      balance: 2500,
      icon: null,
      color: null,
      createdAt: DateTime(2026, 1, 1),
    ),
  ];

  @override
  Future<void> deleteAccount(String id) async {
    _accounts.removeWhere((account) => account.id == id);
  }

  @override
  Future<Account?> getAccount(String id) async {
    try {
      return _accounts.firstWhere((account) => account.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Account>> getAllAccounts() async {
    return _accounts;
  }

  @override
  Future<void> renameAccount(String id, String newName) async {
    final account = await getAccount(id);
    if (account == null) return;
    final index = _accounts.indexWhere((element) => element.id == id);
    _accounts[index] = Account(
      id: account.id,
      userId: account.userId,
      name: newName,
      balance: account.balance,
      icon: account.icon,
      color: account.color,
      createdAt: account.createdAt,
    );
  }

  @override
  Future<void> saveAccount(Account account) async {
    _accounts.add(account);
  }

  @override
  Future<void> updateAccount(String id, double newBalance) async {
    final account = await getAccount(id);
    if (account == null) return;
    final index = _accounts.indexWhere((element) => element.id == id);
    _accounts[index] = Account(
      id: account.id,
      userId: account.userId,
      name: account.name,
      balance: newBalance,
      icon: account.icon,
      color: account.color,
      createdAt: account.createdAt,
    );
  }
}

void main() {
  testWidgets('App renders account summary', (WidgetTester tester) async {
    await tester.pumpWidget(
      MyApp(accountRepository: _FakeAccountRepository()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Home page'), findsOneWidget);
    expect(find.text('Available to spend'), findsOneWidget);
    expect(find.text('2500.00'), findsOneWidget);
  });
}
