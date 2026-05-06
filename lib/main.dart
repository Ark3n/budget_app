import 'package:budget_app/features/budget/data/datasource/local_datasource.dart';
import 'package:budget_app/features/budget/data/datasource/remote_datasource.dart';
import 'package:budget_app/features/budget/data/models/transaction_type_adapter.dart';
import 'package:budget_app/features/budget/data/repository/account_repo_imp.dart';
import 'package:budget_app/features/budget/data/repository/auth_repo_imp.dart';
import 'package:budget_app/features/budget/data/repository/category_repo_imp.dart';
import 'package:budget_app/features/budget/data/repository/transaction_repo_imp.dart';
import 'package:budget_app/features/budget/presentation/account/cubit/account_cubit.dart';
import 'package:budget_app/features/budget/presentation/auth/cubit/auth_cubit.dart';
import 'package:budget_app/features/budget/presentation/auth/cubit/auth_state.dart';
import 'package:budget_app/features/budget/presentation/pages/auth_page.dart';
import 'package:budget_app/features/budget/presentation/category/cubit/category_cubit.dart';
import 'package:budget_app/features/budget/presentation/pages/main_tab_page.dart';
import 'package:budget_app/features/budget/presentation/transaction/cubit/transaction_cubit.dart';
import 'package:budget_app/hive_registrar.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Load env and init Supabase
  await dotenv.load(fileName: '.env');
  await supabase.Supabase.initialize(
    url: dotenv.env['URL'] ?? '',
    anonKey: dotenv.env['ANON_KEY'] ?? '',
  );

  /// Hive Local DB init.
  await Hive.initFlutter();
  Hive.registerAdapter(TransactionTypeAdapter());
  Hive.registerAdapters();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final localDatasource = LocalDatasource();
    final remoteDatasource = RemoteDatasource(supabase.Supabase.instance.client);
    final accountRepository = AccountRepoImp(localDatasource, remoteDatasource);
    final categoryRepository = CategoryRepoImp(localDatasource, remoteDatasource);
    final authRepository = AuthRepoImp(supabase.Supabase.instance.client);
    final transactionRepository = TransactionRepoImp(
      localDatasource,
      accountRepository,
      remoteDatasource,
    );
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit(authRepository)),
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
        home: const _AppAuthGate(),
      ),
    );
  }
}

class _AppAuthGate extends StatelessWidget {
  const _AppAuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          return const MainTabPage();
        }
        return const AuthPage();
      },
    );
  }
}
