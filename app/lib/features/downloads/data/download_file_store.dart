// Platform-specific file storage for offline downloads.
//
// The conditional import keeps `dart:io` out of the web build, where
// downloads are unavailable.
export 'download_file_store_stub.dart'
    if (dart.library.io) 'download_file_store_io.dart';
