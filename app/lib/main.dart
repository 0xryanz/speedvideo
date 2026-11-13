import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/device/tv_mode.dart';
import 'core/providers/infrastructure.dart';
import 'core/storage/token_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  final tokenStore = TokenStore(fallback: preferences);
  await tokenStore.load();
  final isTv = await detectTelevision();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        tokenStoreProvider.overrideWithValue(tokenStore),
        tvModeProvider.overrideWithValue(isTv),
      ],
      child: const SpeedVideoApp(),
    ),
  );
}
