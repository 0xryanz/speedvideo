import 'package:flutter/widgets.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/network/api_exception.dart';

/// Maps API error codes to localised, user-safe messages.
String authErrorMessage(BuildContext context, Object error) {
  if (error is ApiException) {
    return switch (error.code) {
      'invalid_credentials' => context.l10n.invalidCredentials,
      'conflict' => context.l10n.emailTaken,
      'network_unavailable' || 'timeout' => context.l10n.apiUnavailable,
      'validation_failed' => error.message,
      _ => context.l10n.somethingWentWrong,
    };
  }
  return context.l10n.somethingWentWrong;
}
