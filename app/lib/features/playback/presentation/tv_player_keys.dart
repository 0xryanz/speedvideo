import 'package:flutter/services.dart';

/// Remote/keyboard actions understood by the player.
enum TvPlayerCommand {
  togglePlay,
  seekBackward,
  seekForward,
  showControls,
  exit,
}

/// Maps Android TV remote keys (which Flutter reports as keyboard events) to
/// player commands. Kept pure so the D-pad contract is unit-testable without a
/// platform video controller.
TvPlayerCommand? tvPlayerCommand(LogicalKeyboardKey key) {
  if (key == LogicalKeyboardKey.select ||
      key == LogicalKeyboardKey.enter ||
      key == LogicalKeyboardKey.numpadEnter ||
      key == LogicalKeyboardKey.space ||
      key == LogicalKeyboardKey.gameButtonA ||
      key == LogicalKeyboardKey.mediaPlayPause ||
      key == LogicalKeyboardKey.mediaPlay) {
    return TvPlayerCommand.togglePlay;
  }
  if (key == LogicalKeyboardKey.arrowLeft ||
      key == LogicalKeyboardKey.mediaRewind) {
    return TvPlayerCommand.seekBackward;
  }
  if (key == LogicalKeyboardKey.arrowRight ||
      key == LogicalKeyboardKey.mediaFastForward) {
    return TvPlayerCommand.seekForward;
  }
  if (key == LogicalKeyboardKey.arrowUp ||
      key == LogicalKeyboardKey.arrowDown ||
      key == LogicalKeyboardKey.mediaStop) {
    return TvPlayerCommand.showControls;
  }
  if (key == LogicalKeyboardKey.escape || key == LogicalKeyboardKey.goBack) {
    return TvPlayerCommand.exit;
  }
  return null;
}
