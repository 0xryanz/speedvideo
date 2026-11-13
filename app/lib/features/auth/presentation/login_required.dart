import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import 'session_controller.dart';

/// Gate for account-only actions.
///
/// Guests browse and play without an account. When they tap something that
/// needs one (my list, downloads), show a short explanation and offer the
/// sign-in screen instead of failing with a 401.
Future<bool> ensureSignedIn(
  BuildContext context,
  WidgetRef ref, {
  String? message,
}) async {
  if (ref.read(sessionControllerProvider).activeProfile != null) {
    return true;
  }
  final signIn = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(dialogContext.l10n.loginRequired),
      content: Text(message ?? dialogContext.l10n.guestLibraryHint),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(dialogContext.l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(dialogContext.l10n.signIn),
        ),
      ],
    ),
  );
  if (signIn == true && context.mounted) {
    unawaited(context.push('/login'));
  }
  return false;
}
