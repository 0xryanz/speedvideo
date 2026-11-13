// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlaybackEpisode _$PlaybackEpisodeFromJson(Map<String, dynamic> json) =>
    _PlaybackEpisode(
      id: json['id'] as String,
      number: (json['number'] as num?)?.toInt() ?? 0,
      seasonNumber: (json['season_number'] as num?)?.toInt() ?? 0,
      name: json['name'] as String,
      runtimeMinutes: (json['runtime_minutes'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$PlaybackEpisodeToJson(_PlaybackEpisode instance) =>
    <String, dynamic>{
      'id': instance.id,
      'number': instance.number,
      'season_number': instance.seasonNumber,
      'name': instance.name,
      'runtime_minutes': instance.runtimeMinutes,
    };

_AudioTrack _$AudioTrackFromJson(Map<String, dynamic> json) => _AudioTrack(
  language: json['language'] as String,
  label: json['label'] as String,
  isDefault: json['is_default'] as bool? ?? false,
);

Map<String, dynamic> _$AudioTrackToJson(_AudioTrack instance) =>
    <String, dynamic>{
      'language': instance.language,
      'label': instance.label,
      'is_default': instance.isDefault,
    };

_SubtitleTrack _$SubtitleTrackFromJson(Map<String, dynamic> json) =>
    _SubtitleTrack(
      language: json['language'] as String,
      label: json['label'] as String,
      isDefault: json['is_default'] as bool? ?? false,
    );

Map<String, dynamic> _$SubtitleTrackToJson(_SubtitleTrack instance) =>
    <String, dynamic>{
      'language': instance.language,
      'label': instance.label,
      'is_default': instance.isDefault,
    };

_PlaybackInfo _$PlaybackInfoFromJson(Map<String, dynamic> json) =>
    _PlaybackInfo(
      manifestUrl: json['manifest_url'] as String,
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
      titleId: json['title_id'] as String,
      titleName: json['title_name'] as String? ?? '',
      episode: json['episode'] == null
          ? null
          : PlaybackEpisode.fromJson(json['episode'] as Map<String, dynamic>),
      posterPath: json['poster_path'] as String? ?? '',
      backdropPath: json['backdrop_path'] as String? ?? '',
      resumePositionSeconds:
          (json['resume_position_seconds'] as num?)?.toInt() ?? 0,
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
      audioTracks:
          (json['audio_tracks'] as List<dynamic>?)
              ?.map((e) => AudioTrack.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <AudioTrack>[],
      subtitleTracks:
          (json['subtitle_tracks'] as List<dynamic>?)
              ?.map((e) => SubtitleTrack.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <SubtitleTrack>[],
    );

Map<String, dynamic> _$PlaybackInfoToJson(
  _PlaybackInfo instance,
) => <String, dynamic>{
  'manifest_url': instance.manifestUrl,
  'expires_at': ?instance.expiresAt?.toIso8601String(),
  'title_id': instance.titleId,
  'title_name': instance.titleName,
  'episode': ?instance.episode?.toJson(),
  'poster_path': instance.posterPath,
  'backdrop_path': instance.backdropPath,
  'resume_position_seconds': instance.resumePositionSeconds,
  'duration_seconds': instance.durationSeconds,
  'audio_tracks': instance.audioTracks.map((e) => e.toJson()).toList(),
  'subtitle_tracks': instance.subtitleTracks.map((e) => e.toJson()).toList(),
};
