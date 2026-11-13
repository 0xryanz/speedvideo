import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalog_models.freezed.dart';
part 'catalog_models.g.dart';

@freezed
abstract class Genre with _$Genre {
  const factory Genre({
    required String slug,
    required String name,
  }) = _Genre;

  factory Genre.fromJson(Map<String, dynamic> json) => _$GenreFromJson(json);
}

@freezed
abstract class TitleProgress with _$TitleProgress {
  const factory TitleProgress({
    String? episodeId,
    @Default(0) int positionSeconds,
    @Default(0) int durationSeconds,
    @Default(0) int percent,
    @Default(false) bool completed,
  }) = _TitleProgress;

  factory TitleProgress.fromJson(Map<String, dynamic> json) =>
      _$TitleProgressFromJson(json);
}

@freezed
abstract class TitleCard with _$TitleCard {
  const factory TitleCard({
    required String id,
    required String slug,
    required String name,
    @Default('movie') String kind,
    @Default(0) int releaseYear,
    @Default('') String maturityRating,
    @Default(0) int runtimeMinutes,
    @Default('') String posterPath,
    @Default('') String backdropPath,
    String? logoPath,
    @Default(0) int matchPercent,
    @Default(<String>[]) List<String> badges,
    @Default(<Genre>[]) List<Genre> genres,
    TitleProgress? progress,
  }) = _TitleCard;

  factory TitleCard.fromJson(Map<String, dynamic> json) =>
      _$TitleCardFromJson(json);
}

@freezed
abstract class Episode with _$Episode {
  const factory Episode({
    required String id,
    @Default(0) int number,
    @Default(0) int seasonNumber,
    required String name,
    @Default('') String synopsis,
    @Default(0) int runtimeMinutes,
    @Default('') String stillPath,
  }) = _Episode;

  factory Episode.fromJson(Map<String, dynamic> json) =>
      _$EpisodeFromJson(json);
}

@freezed
abstract class Season with _$Season {
  const factory Season({
    required String id,
    @Default(0) int number,
    required String name,
    @Default(<Episode>[]) List<Episode> episodes,
  }) = _Season;

  factory Season.fromJson(Map<String, dynamic> json) => _$SeasonFromJson(json);
}

@freezed
abstract class TitleOffer with _$TitleOffer {
  const factory TitleOffer({
    required String titleId,
    @Default('') String sourceId,
    @Default('') String sourceName,
    @Default(0) int episodeCount,
    @Default(false) bool selected,
  }) = _TitleOffer;

  factory TitleOffer.fromJson(Map<String, dynamic> json) =>
      _$TitleOfferFromJson(json);
}

@freezed
abstract class TitleDetail with _$TitleDetail {
  const factory TitleDetail({
    required String id,
    required String slug,
    required String name,
    @Default('movie') String kind,
    @Default(0) int releaseYear,
    @Default('') String maturityRating,
    @Default(0) int runtimeMinutes,
    @Default('') String posterPath,
    @Default('') String backdropPath,
    String? logoPath,
    @Default(0) int matchPercent,
    @Default(<String>[]) List<String> badges,
    @Default(<Genre>[]) List<Genre> genres,
    @Default('') String originalName,
    @Default('') String synopsis,
    @Default('') String tagline,
    @Default('') String director,
    @Default('') String country,
    @Default(<String>[]) List<String> cast,
    @Default('') String trailerUrl,
    @Default(false) bool inWatchlist,
    TitleProgress? resume,
    TitleProgress? progress,
    @Default(<Season>[]) List<Season> seasons,
    @Default(<TitleOffer>[]) List<TitleOffer> offers,
  }) = _TitleDetail;

  factory TitleDetail.fromJson(Map<String, dynamic> json) =>
      _$TitleDetailFromJson(json);
}

@freezed
abstract class BrowsePage with _$BrowsePage {
  const factory BrowsePage({
    @Default(<TitleCard>[]) List<TitleCard> items,
    @Default(1) int page,
    @Default(20) int pageSize,
    @Default(0) int total,
    @Default(false) bool hasMore,
  }) = _BrowsePage;

  factory BrowsePage.fromJson(Map<String, dynamic> json) =>
      _$BrowsePageFromJson(json);
}
