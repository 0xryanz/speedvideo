/// Web fallback: downloads need a native file system.
class DownloadFileStore {
  const DownloadFileStore();

  Future<String> resolve(String fileName) async {
    throw UnsupportedError('Downloads require a native platform.');
  }

  Future<bool> exists(String path) async => false;

  Future<int> size(String path) async => 0;

  Future<void> delete(String path) async {}
}
