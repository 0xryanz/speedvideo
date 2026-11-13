import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/download_models.dart';

/// Persists download metadata locally so downloads survive restarts.
class DownloadStore {
  DownloadStore(this._preferences);

  static const _key = 'speedvideo.downloads';

  final SharedPreferences _preferences;

  List<DownloadItem> load() {
    final raw = _preferences.getString(_key);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(DownloadItem.fromJson)
          .where((item) => item.titleId.isNotEmpty && item.filePath.isNotEmpty)
          .toList(growable: false);
    } on FormatException {
      return const [];
    }
  }

  Future<void> save(List<DownloadItem> items) {
    return _preferences.setString(
      _key,
      jsonEncode(items.map((item) => item.toJson()).toList(growable: false)),
    );
  }
}
