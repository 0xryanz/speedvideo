import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/utils/responsive.dart';
import 'widgets/auth_scaffold.dart';

class WelcomePage extends ConsumerStatefulWidget {
  const WelcomePage({super.key});

  @override
  ConsumerState<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends ConsumerState<WelcomePage> {
  final _email = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _start() {
    final value = _email.text.trim();
    if (value.isNotEmpty && !value.contains('@')) {
      setState(() => _error = context.l10n.invalidEmail);
      return;
    }
    setState(() => _error = null);
    final query = value.isEmpty ? '' : '?email=${Uri.encodeComponent(value)}';
    context.go('/signup$query');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 72),
          Text(context.l10n.welcomeTitle, style: textTheme.displayMedium),
          const SizedBox(height: 12),
          Text(
            context.l10n.welcomeSubtitle,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            onSubmitted: (_) => _start(),
            decoration: InputDecoration(
              labelText: context.l10n.email,
              errorText: _error,
              prefixIcon: const Icon(Icons.mail_outline_rounded, size: 20),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: _start,
            autofocus: Responsive.isTv(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(context.l10n.getStarted),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.l10n.haveAccount,
                style: textTheme.bodySmall,
              ),
              TextButton(
                onPressed: () => context.go('/login'),
                child: Text(context.l10n.signIn),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            context.l10n.appTagline,
            textAlign: TextAlign.center,
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
