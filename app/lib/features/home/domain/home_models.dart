import 'package:freezed_annotation/freezed_annotation.dart';

import '../../catalog/domain/catalog_models.dart';

part 'home_models.freezed.dart';
part 'home_models.g.dart';

@freezed
abstract class HomeRow with _$HomeRow {
  const factory HomeRow({
    required String id,
    required String title,
    @Default('standard') String kind,
    @Default(false) bool ranked,
    @Default(<TitleCard>[]) List<TitleCard> items,
  }) = _HomeRow;

  factory HomeRow.fromJson(Map<String, dynamic> json) =>
      _$HomeRowFromJson(json);
}

@freezed
abstract class HomeFeed with _$HomeFeed {
  const factory HomeFeed({
    TitleCard? billboard,
    @Default(<HomeRow>[]) List<HomeRow> rows,
  }) = _HomeFeed;

  factory HomeFeed.fromJson(Map<String, dynamic> json) =>
      _$HomeFeedFromJson(json);
}
