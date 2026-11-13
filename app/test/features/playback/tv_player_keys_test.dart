import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speedvideo/features/playback/presentation/tv_player_keys.dart';

void main() {
  test('D-pad center and media keys toggle playback', () {
    for (final key in [
      LogicalKeyboardKey.select,
      LogicalKeyboardKey.enter,
      LogicalKeyboardKey.numpadEnter,
      LogicalKeyboardKey.space,
      LogicalKeyboardKey.gameButtonA,
      LogicalKeyboardKey.mediaPlayPause,
      LogicalKeyboardKey.mediaPlay,
    ]) {
      expect(tvPlayerCommand(key), TvPlayerCommand.togglePlay, reason: '$key');
    }
  });

  test('left and right seek 10 seconds', () {
    expect(
      tvPlayerCommand(LogicalKeyboardKey.arrowLeft),
      TvPlayerCommand.seekBackward,
    );
    expect(
      tvPlayerCommand(LogicalKeyboardKey.arrowRight),
      TvPlayerCommand.seekForward,
    );
    expect(
      tvPlayerCommand(LogicalKeyboardKey.mediaRewind),
      TvPlayerCommand.seekBackward,
    );
    expect(
      tvPlayerCommand(LogicalKeyboardKey.mediaFastForward),
      TvPlayerCommand.seekForward,
    );
  });

  test('up/down reveal the controls and back exits', () {
    expect(
      tvPlayerCommand(LogicalKeyboardKey.arrowUp),
      TvPlayerCommand.showControls,
    );
    expect(
      tvPlayerCommand(LogicalKeyboardKey.arrowDown),
      TvPlayerCommand.showControls,
    );
    expect(
      tvPlayerCommand(LogicalKeyboardKey.goBack),
      TvPlayerCommand.exit,
    );
    expect(
      tvPlayerCommand(LogicalKeyboardKey.escape),
      TvPlayerCommand.exit,
    );
  });

  test('unmapped keys fall through', () {
    expect(tvPlayerCommand(LogicalKeyboardKey.keyA), isNull);
  });
}
