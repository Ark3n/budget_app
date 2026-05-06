import 'package:budget_app/features/budget/presentation/auth/cubit/auth_cubit.dart';
import 'package:budget_app/features/budget/presentation/auth/cubit/auth_state.dart';
import 'package:budget_app/features/budget/presentation/shared/budget_ui_tokens.dart';
import 'package:budget_app/features/budget/presentation/shared/widgets/budget_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Auth screen with register/login mode toggle.
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthState state) async {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<AuthCubit>();
    if (state.isRegisterMode) {
      await cubit.signUp(_emailCtrl.text, _passwordCtrl.text);
      return;
    }
    await cubit.signIn(_emailCtrl.text, _passwordCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: BudgetCard(
                child: BlocConsumer<AuthCubit, AuthState>(
                  listenWhen: (prev, next) => prev.error != next.error,
                  listener: (context, state) {
                    if (state.error == null || state.error!.isEmpty) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.error!)),
                    );
                  },
                  builder: (context, state) {
                    final title = state.isRegisterMode
                        ? 'Create your account'
                        : 'Welcome back';
                    final subtitle = state.isRegisterMode
                        ? 'Register to sync your budget securely.'
                        : 'Sign in to continue managing your budget.';
                    final isLoading = state.status == AuthStatus.loading;

                    return Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            subtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              hintText: 'you@example.com',
                            ),
                            validator: (value) {
                              final text = (value ?? '').trim();
                              if (text.isEmpty) return 'Email is required';
                              if (!text.contains('@')) return 'Enter a valid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(state),
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              hintText: 'Minimum 6 characters',
                            ),
                            validator: (value) {
                              final text = value ?? '';
                              if (text.isEmpty) return 'Password is required';
                              if (text.length < 6) return 'Use at least 6 characters';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          FilledButton(
                            onPressed: isLoading ? null : () => _submit(state),
                            style: FilledButton.styleFrom(
                              backgroundColor: BudgetUiTokens.brandGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(state.isRegisterMode ? 'Create account' : 'Sign in'),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    context.read<AuthCubit>().setRegisterMode(
                                      !state.isRegisterMode,
                                    );
                                  },
                            child: Text(
                              state.isRegisterMode
                                  ? 'Already have an account? Sign in'
                                  : 'Need an account? Register',
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
