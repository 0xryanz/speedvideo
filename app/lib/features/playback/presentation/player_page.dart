import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../app/theme.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers/infrastructure.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/async_view.dart';
import '../../auth/presentation/session_controller.dart';
import '../../catalog/domain/catalog_models.dart';
import '../../downloads/domain/download_models.dart';
import '../../downloads/presentation/downloads_controller.dart';
import '../domain/playback_models.dart';
import 'local_video.dart';
import 'tv_player_keys.dart';

class PlayerPage extends ConsumerStatefulWidget {
  const PlayerPage({
    required this.titleId,
    super.key,
    this.episodeId,
    this.offline = false,
  });

  final String titleId;
  final String? episodeId;

  /// Play only from an on-device download.
  final bool offline;

  @override
  ConsumerState<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerSession {
  const _PlayerSession({required this.info, this.next, this.localPath});

  final PlaybackInfo info;
  final Episode? next;
  final String? localPath;
}

/// Thrown when offline playback is requested for a title that is not stored.
class _OfflineUnavailable implements Exception {
  const _OfflineUnavailable();
}

class _PlayerPageState extends ConsumerState<PlayerPage> {
  late Future<_PlayerSession> _future;

  @override
  void initState() {
    super.initState();
    _future = _load(episodeId: widget.episodeId);
  }

  Future<_PlayerSession> _load({String? episodeId}) async {
    // A completed download always wins so playback keeps working offline.
    final local = ref
        .read(downloadsControllerProvider.notifier)
        .completedFor(widget.titleId, episodeId);
    if (local != null) {
      return _PlayerSession(info: _localInfo(local), localPath: local.filePath);
    }
    if (widget.offline) throw const _OfflineUnavailable();

    final info = await ref
        .read(playbackApiProvider)
        .create(titleId: widget.titleId, episodeId: episodeId);
    Episode? next;
    try {
      final detail = await ref.read(catalogApiProvider).detail(widget.titleId);
      final episodes = [
        for (final season in detail.seasons) ...season.episodes,
      ];
      final currentId = info.episode?.id;
      final index = episodes.indexWhere((episode) => episode.id == currentId);
      if (index >= 0 && index + 1 < episodes.length) {
        next = episodes[index + 1];
      }
    } on Object {
      // Next-episode discovery is best-effort.
    }
    return _PlayerSession(info: info, next: next);
  }

  PlaybackInfo _localInfo(DownloadItem item) {
    final episode = item.episode;
    return PlaybackInfo(
      manifestUrl: item.filePath,
      titleId: item.titleId,
      titleName: item.titleName,
      posterPath: item.posterPath,
      durationSeconds: item.durationSeconds,
      episode: episode == null
          ? null
          : PlaybackEpisode(
              id: episode.id,
              number: episode.number,
              seasonNumber: episode.seasonNumber,
              name: episode.name,
              runtimeMinutes: episode.runtimeMinutes,
            ),
    );
  }

  void _playNext(Episode episode) {
    setState(() {
      _future = _load(episodeId: episode.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_PlayerSession>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.black,
            body: AppLoading(),
          );
        }
        if (snapshot.hasError) {
          final error = snapshot.error;
          return Scaffold(
            backgroundColor: AppColors.black,
            body: SafeArea(
              child: Stack(
                children: [
                  AppErrorView(
                    message: error is _OfflineUnavailable
                        ? context.l10n.notDownloaded
                        : error is ApiException
                        ? error.message
                        : context.l10n.playerError,
                    onRetry: () => setState(
                      () => _future = _load(episodeId: widget.episodeId),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: IconButton(
                      onPressed: () => context.canPop()
                          ? context.pop()
                          : context.go('/home'),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        final session = snapshot.data!;
        return _VideoPlayerView(
          key: ValueKey(session.localPath ?? session.info.manifestUrl),
          session: session,
          titleId: widget.titleId,
          onNext: session.next == null ? null : () => _playNext(session.next!),
        );
      },
    );
  }
}

class _VideoPlayerView extends ConsumerStatefulWidget {
  const _VideoPlayerView({
    required this.session,
    required this.titleId,
    super.key,
    this.onNext,
  });

  final _PlayerSession session;
  final String titleId;
  final VoidCallback? onNext;

  @override
  ConsumerState<_VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends ConsumerState<_VideoPlayerView>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  Timer? _hideTimer;
  Timer? _heartbeat;
  Timer? _seekHintTimer;
  bool _controlsVisible = true;
  bool _initialized = false;
  bool _dragging = false;
  bool _autoAdvanced = false;
  bool _autoplayNext = true;
  double? _dragValue;
  int _seekHint = 0;
  double _lastDoubleTapX = 0;
  final _focusNode = FocusNode(debugLabel: 'tv-player');

  PlaybackInfo get _info => widget.session.info;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _autoplayNext =
        ref.read(sessionControllerProvider).activeProfile?.autoplayNext ?? true;
    _enterFullscreen();
    _initialize();
  }

  /// Playback must stop when the app is backgrounded: a hidden AVPlayer keeps
  /// its audio session alive on macOS and iOS.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _saveProgress();
      final controller = _controller;
      if (controller != null && controller.value.isPlaying) {
        unawaited(controller.pause());
      }
    }
  }

  Future<void> _enterFullscreen() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _restoreSystemUi() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> _initialize() async {
    try {
      final localPath = widget.session.localPath;
      final controller = localPath == null
          ? VideoPlayerController.networkUrl(Uri.parse(_info.manifestUrl))
          : createLocalVideoController(localPath);
      _controller = controller;
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      if (_info.resumePositionSeconds > 5) {
        await controller.seekTo(
          Duration(seconds: _info.resumePositionSeconds),
        );
      }
      await controller.play();
      controller.addListener(_onControllerUpdate);
      setState(() => _initialized = true);
      _scheduleHide();
      _heartbeat = Timer.periodic(
        const Duration(seconds: 15),
        (_) => _saveProgress(),
      );
    } on Object {
      await _controller?.dispose();
      if (mounted) {
        setState(() {
          _initialized = true;
          _controller = null;
        });
      }
    }
  }

  void _onControllerUpdate() {
    if (!mounted) return;
    final value = _controller?.value;
    if (value == null || !value.isInitialized) return;
    if (value.isCompleted &&
        !_autoAdvanced &&
        _autoplayNext &&
        widget.onNext != null) {
      _autoAdvanced = true;
      widget.onNext!();
      return;
    }
    if (value.isPlaying) {
      // Rebuild controls so the timeline advances.
      setState(() {});
    }
  }

  void _saveProgress() {
    // Guests have no profile to attach progress to; playback itself still works.
    if (ref.read(sessionControllerProvider).activeProfileId == null) return;
    final controller = _controller;
    if (controller == null || !_initialized) return;
    final value = controller.value;
    if (!value.isInitialized) return;
    final position = value.position.inSeconds;
    final duration = value.duration.inSeconds;
    if (position <= 0 || duration <= 0) return;
    unawaited(
      ref
          .read(libraryApiProvider)
          .saveProgress(
            titleId: widget.titleId,
            episodeId: _info.episode?.id,
            positionSeconds: position,
            durationSeconds: duration,
          )
          .catchError((Object _) {}),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _hideTimer?.cancel();
    _heartbeat?.cancel();
    _seekHintTimer?.cancel();
    _focusNode.dispose();

    // Never touch `ref` here: the element is already defunct, so `ref.read`
    // throws and would abort disposal, leaving the player running.
    final controller = _controller;
    _controller = null;
    if (controller != null) {
      controller.removeListener(_onControllerUpdate);
      try {
        // Pause before tearing down: disposing an actively playing AVPlayer
        // can leave the audio output running on macOS.
        unawaited(controller.pause().catchError((Object _) {}));
      } on Object {
        // The platform view may already be gone; disposal must still run.
      }
      unawaited(controller.dispose());
    }

    unawaited(_restoreSystemUi());
    super.dispose();
  }

  /// Leaves the player: persist progress, stop the stream, then pop. Pressing
  /// back while audio keeps playing was caused by disposal throwing before the
  /// controller was released.
  Future<void> _exit() async {
    _saveProgress();
    final controller = _controller;
    if (controller != null) {
      try {
        await controller.pause();
      } on Object {
        // The stream may already be gone; navigation still has to happen.
      }
    }
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(milliseconds: 3600), () {
      if (mounted && (_controller?.value.isPlaying ?? false)) {
        setState(() => _controlsVisible = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _controlsVisible = !_controlsVisible);
    if (_controlsVisible) _scheduleHide();
  }

  Future<void> _togglePlay() async {
    final controller = _controller;
    if (controller == null) return;
    if (controller.value.isPlaying) {
      await controller.pause();
      _saveProgress();
      setState(() => _controlsVisible = true);
      _hideTimer?.cancel();
    } else {
      await controller.play();
      _scheduleHide();
    }
    setState(() {});
  }

  void _seekBy(int seconds) {
    final controller = _controller;
    if (controller == null) return;
    final target = controller.value.position + Duration(seconds: seconds);
    final clamped = target < Duration.zero
        ? Duration.zero
        : (target > controller.value.duration
              ? controller.value.duration
              : target);
    unawaited(controller.seekTo(clamped));
    setState(() {
      _seekHint = seconds;
      _controlsVisible = true;
    });
    _seekHintTimer?.cancel();
    _seekHintTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _seekHint = 0);
    });
    _scheduleHide();
  }

  /// Android TV remotes arrive as key events. Keep a single focused node on
  /// the player so D-pad input never gets trapped in the control bar.
  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.handled;
    final command = tvPlayerCommand(event.logicalKey);
    if (command == null) return KeyEventResult.ignored;
    switch (command) {
      case TvPlayerCommand.togglePlay:
        unawaited(_togglePlay());
      case TvPlayerCommand.seekBackward:
        _seekBy(-10);
      case TvPlayerCommand.seekForward:
        _seekBy(10);
      case TvPlayerCommand.showControls:
        if (!_controlsVisible) setState(() => _controlsVisible = true);
        _scheduleHide();
      case TvPlayerCommand.exit:
        unawaited(_exit());
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final value = controller?.value;
    final ready = _initialized && value != null && value.isInitialized;
    final duration = ready ? value.duration : Duration.zero;
    final position = ready ? value.position : Duration.zero;
    final progress = _dragging && _dragValue != null
        ? _dragValue!
        : (duration.inMilliseconds == 0
              ? 0.0
              : position.inMilliseconds
                    .clamp(0, duration.inMilliseconds)
                    .toDouble());

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _saveProgress();
      },
      child: Focus(
        autofocus: true,
        focusNode: _focusNode,
        onKeyEvent: _onKeyEvent,
        child: Scaffold(
          backgroundColor: AppColors.black,
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggleControls,
            onDoubleTapDown: (details) {
              _lastDoubleTapX = details.localPosition.dx;
            },
            onDoubleTap: () {
              final width = MediaQuery.sizeOf(context).width;
              _seekBy(_lastDoubleTapX < width / 2 ? -10 : 10);
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (ready)
                  Center(
                    child: AspectRatio(
                      aspectRatio: value.aspectRatio,
                      child: VideoPlayer(controller!),
                    ),
                  )
                else if (_initialized)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        context.l10n.playerError,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  )
                else
                  const Center(child: CircularProgressIndicator()),
                AnimatedOpacity(
                  opacity: _controlsVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: ExcludeFocus(
                    excluding: Responsive.isTv(context),
                    child: IgnorePointer(
                      ignoring: !_controlsVisible,
                      child: Stack(
                        children: [
                          const Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xAA000000),
                                    Color(0x00000000),
                                    Color(0x00000000),
                                    Color(0xCC000000),
                                  ],
                                  stops: [0, 0.28, 0.62, 1],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: SafeArea(
                              bottom: false,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: _exit,
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _info.titleName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleSmall,
                                          ),
                                          if (_info.episode != null)
                                            Text(
                                              'S${_info.episode!.seasonNumber}:E${_info.episode!.number} · ${_info.episode!.name}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.labelSmall,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (_seekHint != 0)
                            Align(
                              alignment: _seekHint < 0
                                  ? const Alignment(-0.62, 0)
                                  : const Alignment(0.62, 0),
                              child: _SeekHint(seconds: _seekHint),
                            ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: SafeArea(
                              top: false,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  0,
                                  12,
                                  6,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (Responsive.isTv(context))
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 6,
                                        ),
                                        child: Text(
                                          context.l10n.tvRemoteHint,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          onPressed: () => _seekBy(-10),
                                          icon: const Icon(
                                            Icons.replay_10_rounded,
                                            size: 34,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        IconButton(
                                          onPressed: _togglePlay,
                                          icon: Icon(
                                            (value?.isPlaying ?? false)
                                                ? Icons.pause_rounded
                                                : Icons.play_arrow_rounded,
                                            size: 52,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        IconButton(
                                          onPressed: () => _seekBy(10),
                                          icon: const Icon(
                                            Icons.forward_10_rounded,
                                            size: 34,
                                          ),
                                        ),
                                        if (widget.onNext != null) ...[
                                          const SizedBox(width: 14),
                                          IconButton(
                                            onPressed: widget.onNext,
                                            icon: const Icon(
                                              Icons.skip_next_rounded,
                                              size: 34,
                                            ),
                                            tooltip: context.l10n.nextEpisode,
                                          ),
                                        ],
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          formatDuration(
                                            _dragging && _dragValue != null
                                                ? (_dragValue! ~/ 1000)
                                                : position.inSeconds,
                                          ),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        Expanded(
                                          child: Slider(
                                            value: duration.inMilliseconds <= 0
                                                ? 0
                                                : progress
                                                      .clamp(
                                                        0,
                                                        duration.inMilliseconds,
                                                      )
                                                      .toDouble(),
                                            max: duration.inMilliseconds <= 0
                                                ? 1
                                                : duration.inMilliseconds
                                                      .toDouble(),
                                            onChangeStart:
                                                duration.inMilliseconds <= 0
                                                ? null
                                                : (value) {
                                                    setState(() {
                                                      _dragging = true;
                                                      _dragValue = value;
                                                    });
                                                    _hideTimer?.cancel();
                                                  },
                                            onChanged:
                                                duration.inMilliseconds <= 0
                                                ? null
                                                : (value) => setState(
                                                    () => _dragValue = value,
                                                  ),
                                            onChangeEnd:
                                                duration.inMilliseconds <= 0
                                                ? null
                                                : (value) async {
                                                    await controller!.seekTo(
                                                      Duration(
                                                        milliseconds: value
                                                            .round(),
                                                      ),
                                                    );
                                                    if (mounted) {
                                                      setState(() {
                                                        _dragging = false;
                                                        _dragValue = null;
                                                      });
                                                      _scheduleHide();
                                                    }
                                                  },
                                          ),
                                        ),
                                        Text(
                                          formatDuration(duration.inSeconds),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SeekHint extends StatelessWidget {
  const _SeekHint({required this.seconds});

  final int seconds;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            seconds < 0
                ? Icons.fast_rewind_rounded
                : Icons.fast_forward_rounded,
            size: 30,
          ),
          const SizedBox(height: 2),
          Text('${seconds.abs()}s', style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
