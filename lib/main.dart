import 'package:budget_app/features/budget/data/models/account_model.dart';
import 'package:budget_app/features/budget/data/repository/account_repo_imp.dart';
import 'package:budget_app/features/budget/data/models/category_model.dart';
import 'package:budget_app/features/budget/data/models/transaction_model.dart';
import 'package:budget_app/features/budget/data/datasource/local_datasource.dart';
import 'package:budget_app/features/budget/domain/repository/account_repository.dart';
import 'package:budget_app/features/budget/presentation/account/cubit/account_cubit.dart';
import 'package:budget_app/features/budget/presentation/account/cubit/account_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Hive Local DB init.
  Hive.initFlutter();
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(AccountModelAdapter());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final AccountCubit? accountCubit;
  final AccountRepository? accountRepository;

  const MyApp({super.key, this.accountCubit, this.accountRepository});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider<AccountCubit>(
      create: (_) =>
          accountCubit ??
          AccountCubit(
            accountRepository ?? AccountRepoImp(LocalDatasource()),
          )..initialize(),
      child: MaterialApp(
        title: 'Budget App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> _showRenameDialog({
    required BuildContext context,
    required String accountId,
    required String currentName,
  }) async {
    final controller = TextEditingController(text: currentName);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Rename account'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Account name'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<AccountCubit>().renameAccount(
                  accountId: accountId,
                  newName: controller.text,
                );
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home page')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<AccountCubit, AccountState>(
          builder: (context, state) {
            if (state.status == AccountStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == AccountStatus.failure) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.error ?? 'Failed to load accounts'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.read<AccountCubit>().loadAccounts(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Available to spend',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.totalBalance.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Accounts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.accounts.length,
                    itemBuilder: (context, index) {
                      final account = state.accounts[index];
                      return ListTile(
                        title: Text(account.name),
                        subtitle: Text(
                          'Balance: ${account.balance.toStringAsFixed(2)}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showRenameDialog(
                            context: context,
                            accountId: account.id,
                            currentName: account.name,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
