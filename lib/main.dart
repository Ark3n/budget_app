import 'package:budget_app/features/budget/data/datasource/local_datasource.dart';
import 'package:budget_app/features/budget/data/models/account_model.dart';
import 'package:budget_app/features/budget/data/models/category_model.dart';
import 'package:budget_app/features/budget/data/models/transaction_model.dart';
import 'package:budget_app/features/budget/data/models/transaction_type_adapter.dart';
import 'package:budget_app/features/budget/data/repository/account_repo_imp.dart';
import 'package:budget_app/features/budget/data/repository/category_repo_imp.dart';
import 'package:budget_app/features/budget/data/repository/transaction_repo_imp.dart';
import 'package:budget_app/features/budget/presentation/account/cubit/account_cubit.dart';
import 'package:budget_app/features/budget/presentation/category/cubit/category_cubit.dart';
import 'package:budget_app/features/budget/presentation/pages/main_tab_page.dart';
import 'package:budget_app/features/budget/presentation/transaction/cubit/transaction_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Hive Local DB init.
  await Hive.initFlutter();
  Hive.registerAdapter(TransactionTypeAdapter());
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(AccountModelAdapter());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final localDatasource = LocalDatasource();
    final accountRepository = AccountRepoImp(localDatasource);
    final categoryRepository = CategoryRepoImp(localDatasource);
    final transactionRepository = TransactionRepoImp(
      localDatasource,
      accountRepository,
    );
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AccountCubit(accountRepository)..initialize(),
        ),
        BlocProvider(
          create: (_) =>
              TransactionCubit(transactionRepository)..getTransactions(),
        ),
        BlocProvider(
          create: (_) => CategoryCubit(categoryRepository)..initialize(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const MainTabPage(),
      ),
    );
  }
}
