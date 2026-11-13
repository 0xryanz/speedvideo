import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _deviceChannel = MethodChannel('dev.speedvideo/device');

/// Set `--dart-define=TV_MODE=true` to force the 10-foot layout on a phone or
/// emulator that is not running Android TV.
const _forcedTvMode = bool.fromEnvironment('TV_MODE');

/// Asks the Android shell whether the current device is a television.
///
/// Android TV is identified through `UiModeManager` rather than screen size:
/// a large tablet should keep the touch layout, while a 720p set-top box still
/// needs the D-pad layout.
Future<bool> detectTelevision() async {
  if (_forcedTvMode) return true;
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
  try {
    return await _deviceChannel.invokeMethod<bool>('isTelevision') ?? false;
  } on MissingPluginException {
    return false;
  } on PlatformException {
    return false;
  }
}

/// Whether the app should render the 10-foot (TV) interface.
final tvModeProvider = Provider<bool>((ref) => _forcedTvMode);

/// Makes the TV flag available to layout helpers without a ProviderScope read.
class TvScope extends InheritedWidget {
  const TvScope({required this.isTv, required super.child, super.key});

  final bool isTv;

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TvScope>()?.isTv ?? false;

  @override
  bool updateShouldNotify(TvScope oldWidget) => oldWidget.isTv != isTv;
}
