// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Genre _$GenreFromJson(Map<String, dynamic> json) =>
    _Genre(slug: json['slug'] as String, name: json['name'] as String);

Map<String, dynamic> _$GenreToJson(_Genre instance) => <String, dynamic>{
  'slug': instance.slug,
  'name': instance.name,
};

_TitleProgress _$TitleProgressFromJson(Map<String, dynamic> json) =>
    _TitleProgress(
      episodeId: json['episode_id'] as String?,
      positionSeconds: (json['position_seconds'] as num?)?.toInt() ?? 0,
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
      percent: (json['percent'] as num?)?.toInt() ?? 0,
      completed: json['completed'] as bool? ?? false,
    );

Map<String, dynamic> _$TitleProgressToJson(_TitleProgress instance) =>
    <String, dynamic>{
      'episode_id': ?instance.episodeId,
      'position_seconds': instance.positionSeconds,
      'duration_seconds': instance.durationSeconds,
      'percent': instance.percent,
      'completed': instance.completed,
    };

_TitleCard _$TitleCardFromJson(Map<String, dynamic> json) => _TitleCard(
  id: json['id'] as String,
  slug: json['slug'] as String,
  name: json['name'] as String,
  kind: json['kind'] as String? ?? 'movie',
  releaseYear: (json['release_year'] as num?)?.toInt() ?? 0,
  maturityRating: json['maturity_rating'] as String? ?? '',
  runtimeMinutes: (json['runtime_minutes'] as num?)?.toInt() ?? 0,
  posterPath: json['poster_path'] as String? ?? '',
  backdropPath: json['backdrop_path'] as String? ?? '',
  logoPath: json['logo_path'] as String?,
  matchPercent: (json['match_percent'] as num?)?.toInt() ?? 0,
  badges:
      (json['badges'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  genres:
      (json['genres'] as List<dynamic>?)
          ?.map((e) => Genre.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Genre>[],
  progress: json['progress'] == null
      ? null
      : TitleProgress.fromJson(json['progress'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TitleCardToJson(_TitleCard instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'name': instance.name,
      'kind': instance.kind,
      'release_year': instance.releaseYear,
      'maturity_rating': instance.maturityRating,
      'runtime_minutes': instance.runtimeMinutes,
      'poster_path': instance.posterPath,
      'backdrop_path': instance.backdropPath,
      'logo_path': ?instance.logoPath,
      'match_percent': instance.matchPercent,
      'badges': instance.badges,
      'genres': instance.genres.map((e) => e.toJson()).toList(),
      'progress': ?instance.progress?.toJson(),
    };

_Episode _$EpisodeFromJson(Map<String, dynamic> json) => _Episode(
  id: json['id'] as String,
  number: (json['number'] as num?)?.toInt() ?? 0,
  seasonNumber: (json['season_number'] as num?)?.toInt() ?? 0,
  name: json['name'] as String,
  synopsis: json['synopsis'] as String? ?? '',
  runtimeMinutes: (json['runtime_minutes'] as num?)?.toInt() ?? 0,
  stillPath: json['still_path'] as String? ?? '',
);

Map<String, dynamic> _$EpisodeToJson(_Episode instance) => <String, dynamic>{
  'id': instance.id,
  'number': instance.number,
  'season_number': instance.seasonNumber,
  'name': instance.name,
  'synopsis': instance.synopsis,
  'runtime_minutes': instance.runtimeMinutes,
  'still_path': instance.stillPath,
};

_Season _$SeasonFromJson(Map<String, dynamic> json) => _Season(
  id: json['id'] as String,
  number: (json['number'] as num?)?.toInt() ?? 0,
  name: json['name'] as String,
  episodes:
      (json['episodes'] as List<dynamic>?)
          ?.map((e) => Episode.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Episode>[],
);

Map<String, dynamic> _$SeasonToJson(_Season instance) => <String, dynamic>{
  'id': instance.id,
  'number': instance.number,
  'name': instance.name,
  'episodes': instance.episodes.map((e) => e.toJson()).toList(),
};

_TitleOffer _$TitleOfferFromJson(Map<String, dynamic> json) => _TitleOffer(
  titleId: json['title_id'] as String,
  sourceId: json['source_id'] as String? ?? '',
  sourceName: json['source_name'] as String? ?? '',
  episodeCount: (json['episode_count'] as num?)?.toInt() ?? 0,
  selected: json['selected'] as bool? ?? false,
);

Map<String, dynamic> _$TitleOfferToJson(_TitleOffer instance) =>
    <String, dynamic>{
      'title_id': instance.titleId,
      'source_id': instance.sourceId,
      'source_name': instance.sourceName,
      'episode_count': instance.episodeCount,
      'selected': instance.selected,
    };

_TitleDetail _$TitleDetailFromJson(Map<String, dynamic> json) => _TitleDetail(
  id: json['id'] as String,
  slug: json['slug'] as String,
  name: json['name'] as String,
  kind: json['kind'] as String? ?? 'movie',
  releaseYear: (json['release_year'] as num?)?.toInt() ?? 0,
  maturityRating: json['maturity_rating'] as String? ?? '',
  runtimeMinutes: (json['runtime_minutes'] as num?)?.toInt() ?? 0,
  posterPath: json['poster_path'] as String? ?? '',
  backdropPath: json['backdrop_path'] as String? ?? '',
  logoPath: json['logo_path'] as String?,
  matchPercent: (json['match_percent'] as num?)?.toInt() ?? 0,
  badges:
      (json['badges'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  genres:
      (json['genres'] as List<dynamic>?)
          ?.map((e) => Genre.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Genre>[],
  originalName: json['original_name'] as String? ?? '',
  synopsis: json['synopsis'] as String? ?? '',
  tagline: json['tagline'] as String? ?? '',
  director: json['director'] as String? ?? '',
  country: json['country'] as String? ?? '',
  cast:
      (json['cast'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  trailerUrl: json['trailer_url'] as String? ?? '',
  inWatchlist: json['in_watchlist'] as bool? ?? false,
  resume: json['resume'] == null
      ? null
      : TitleProgress.fromJson(json['resume'] as Map<String, dynamic>),
  progress: json['progress'] == null
      ? null
      : TitleProgress.fromJson(json['progress'] as Map<String, dynamic>),
  seasons:
      (json['seasons'] as List<dynamic>?)
          ?.map((e) => Season.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Season>[],
  offers:
      (json['offers'] as List<dynamic>?)
          ?.map((e) => TitleOffer.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <TitleOffer>[],
);

Map<String, dynamic> _$TitleDetailToJson(_TitleDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'name': instance.name,
      'kind': instance.kind,
      'release_year': instance.releaseYear,
      'maturity_rating': instance.maturityRating,
      'runtime_minutes': instance.runtimeMinutes,
      'poster_path': instance.posterPath,
      'backdrop_path': instance.backdropPath,
      'logo_path': ?instance.logoPath,
      'match_percent': instance.matchPercent,
      'badges': instance.badges,
      'genres': instance.genres.map((e) => e.toJson()).toList(),
      'original_name': instance.originalName,
      'synopsis': instance.synopsis,
      'tagline': instance.tagline,
      'director': instance.director,
      'country': instance.country,
      'cast': instance.cast,
      'trailer_url': instance.trailerUrl,
      'in_watchlist': instance.inWatchlist,
      'resume': ?instance.resume?.toJson(),
      'progress': ?instance.progress?.toJson(),
      'seasons': instance.seasons.map((e) => e.toJson()).toList(),
      'offers': instance.offers.map((e) => e.toJson()).toList(),
    };

_BrowsePage _$BrowsePageFromJson(Map<String, dynamic> json) => _BrowsePage(
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => TitleCard.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <TitleCard>[],
  page: (json['page'] as num?)?.toInt() ?? 1,
  pageSize: (json['page_size'] as num?)?.toInt() ?? 20,
  total: (json['total'] as num?)?.toInt() ?? 0,
  hasMore: json['has_more'] as bool? ?? false,
);

Map<String, dynamic> _$BrowsePageToJson(_BrowsePage instance) =>
    <String, dynamic>{
      'items': instance.items.map((e) => e.toJson()).toList(),
      'page': instance.page,
      'page_size': instance.pageSize,
      'total': instance.total,
      'has_more': instance.hasMore,
    };
