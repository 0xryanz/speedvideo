import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/l10n/l10n.dart';
import 'auth_errors.dart';
import 'session_controller.dart';
import 'widgets/auth_scaffold.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _busy = false;
  bool _prefilled = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefilled) return;
    _prefilled = true;
    final email = GoRouterState.of(context).uri.queryParameters['email'];
    if (email != null && email.isNotEmpty) _email.text = email;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(sessionControllerProvider.notifier)
          .register(
            email: _email.text.trim(),
            password: _password.text,
            displayName: _name.text.trim(),
          );
    } on Object catch (error) {
      if (mounted) setState(() => _error = authErrorMessage(context, error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AuthScaffold(
      showBack: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 84),
            Text(context.l10n.createAccount, style: textTheme.displaySmall),
            const SizedBox(height: 8),
            Text(
              context.l10n.signUpSubtitle,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 28),
            TextFormField(
              controller: _name,
              enabled: !_busy,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              decoration: InputDecoration(
                labelText: context.l10n.displayName,
                prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
              ),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return context.l10n.nameRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _email,
              enabled: !_busy,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: context.l10n.email,
                prefixIcon: const Icon(Icons.mail_outline_rounded, size: 20),
              ),
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty || !email.contains('@')) {
                  return context.l10n.invalidEmail;
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _password,
              enabled: !_busy,
              obscureText: _obscure,
              autofillHints: const [AutofillHints.newPassword],
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: context.l10n.password,
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                  ),
                ),
              ),
              validator: (value) {
                if ((value ?? '').length < 8) return context.l10n.passwordMin;
                return null;
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.red.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  _error!,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _busy ? null : _submit,
              child: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textPrimary,
                      ),
                    )
                  : Text(context.l10n.createAccount),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(context.l10n.haveAccount, style: textTheme.bodySmall),
                TextButton(
                  onPressed: _busy ? null : () => context.go('/login'),
                  child: Text(context.l10n.signIn),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
