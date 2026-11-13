import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/infrastructure.dart';

/// App locale; `null` follows the device language.
class LocaleController extends Notifier<Locale?> {
  static const _key = 'speedvideo.locale';

  @override
  Locale? build() {
    final code = ref.read(sharedPreferencesProvider).getString(_key);
    return code == null ? null : Locale(code);
  }

  Future<void> setLocale(String? languageCode) async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (languageCode == null) {
      await prefs.remove(_key);
      state = null;
      return;
    }
    await prefs.setString(_key, languageCode);
    state = Locale(languageCode);
  }
}

final localeControllerProvider = NotifierProvider<LocaleController, Locale?>(
  LocaleController.new,
);
