// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HomeRow _$HomeRowFromJson(Map<String, dynamic> json) => _HomeRow(
  id: json['id'] as String,
  title: json['title'] as String,
  kind: json['kind'] as String? ?? 'standard',
  ranked: json['ranked'] as bool? ?? false,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => TitleCard.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <TitleCard>[],
);

Map<String, dynamic> _$HomeRowToJson(_HomeRow instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'kind': instance.kind,
  'ranked': instance.ranked,
  'items': instance.items.map((e) => e.toJson()).toList(),
};

_HomeFeed _$HomeFeedFromJson(Map<String, dynamic> json) => _HomeFeed(
  billboard: json['billboard'] == null
      ? null
      : TitleCard.fromJson(json['billboard'] as Map<String, dynamic>),
  rows:
      (json['rows'] as List<dynamic>?)
          ?.map((e) => HomeRow.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <HomeRow>[],
);

Map<String, dynamic> _$HomeFeedToJson(_HomeFeed instance) => <String, dynamic>{
  'billboard': ?instance.billboard?.toJson(),
  'rows': instance.rows.map((e) => e.toJson()).toList(),
};
