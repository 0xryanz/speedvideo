import 'dart:io';

import 'package:video_player/video_player.dart';

/// Plays a completed download straight from the device.
VideoPlayerController createLocalVideoController(String path) {
  return VideoPlayerController.file(File(path));
}
