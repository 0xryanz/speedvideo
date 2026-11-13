import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Owns the on-device download directory. Files live in the application
/// support directory so they survive app updates and are excluded from user
/// backups on platforms that provide such a directory.
class DownloadFileStore {
  const DownloadFileStore();

  Future<String> resolve(String fileName) async {
    final root = await getApplicationSupportDirectory();
    final directory = Directory('${root.path}/downloads');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return '${directory.path}/$fileName';
  }

  Future<bool> exists(String path) async {
    if (path.isEmpty) return false;
    return File(path).exists();
  }

  Future<int> size(String path) async {
    if (path.isEmpty) return 0;
    final file = File(path);
    if (!await file.exists()) return 0;
    return file.length();
  }

  Future<void> delete(String path) async {
    if (path.isEmpty) return;
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
