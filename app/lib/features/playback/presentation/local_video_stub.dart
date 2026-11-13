import 'package:video_player/video_player.dart';

/// Offline playback is not available on the web.
VideoPlayerController createLocalVideoController(String path) {
  throw UnsupportedError('Offline playback requires a native platform.');
}
