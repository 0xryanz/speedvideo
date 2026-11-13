import 'package:freezed_annotation/freezed_annotation.dart';

part 'playback_models.freezed.dart';
part 'playback_models.g.dart';

@freezed
abstract class PlaybackEpisode with _$PlaybackEpisode {
  const factory PlaybackEpisode({
    required String id,
    @Default(0) int number,
    @Default(0) int seasonNumber,
    required String name,
    @Default(0) int runtimeMinutes,
  }) = _PlaybackEpisode;

  factory PlaybackEpisode.fromJson(Map<String, dynamic> json) =>
      _$PlaybackEpisodeFromJson(json);
}

@freezed
abstract class AudioTrack with _$AudioTrack {
  const factory AudioTrack({
    required String language,
    required String label,
    @Default(false) bool isDefault,
  }) = _AudioTrack;

  factory AudioTrack.fromJson(Map<String, dynamic> json) =>
      _$AudioTrackFromJson(json);
}

@freezed
abstract class SubtitleTrack with _$SubtitleTrack {
  const factory SubtitleTrack({
    required String language,
    required String label,
    @Default(false) bool isDefault,
  }) = _SubtitleTrack;

  factory SubtitleTrack.fromJson(Map<String, dynamic> json) =>
      _$SubtitleTrackFromJson(json);
}

@freezed
abstract class PlaybackInfo with _$PlaybackInfo {
  const factory PlaybackInfo({
    required String manifestUrl,
    DateTime? expiresAt,
    required String titleId,
    @Default('') String titleName,
    PlaybackEpisode? episode,
    @Default('') String posterPath,
    @Default('') String backdropPath,
    @Default(0) int resumePositionSeconds,
    @Default(0) int durationSeconds,
    @Default(<AudioTrack>[]) List<AudioTrack> audioTracks,
    @Default(<SubtitleTrack>[]) List<SubtitleTrack> subtitleTracks,
  }) = _PlaybackInfo;

  factory PlaybackInfo.fromJson(Map<String, dynamic> json) =>
      _$PlaybackInfoFromJson(json);
}
