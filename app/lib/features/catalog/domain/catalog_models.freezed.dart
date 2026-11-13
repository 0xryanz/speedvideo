// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catalog_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Genre {

 String get slug; String get name;
/// Create a copy of Genre
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GenreCopyWith<Genre> get copyWith => _$GenreCopyWithImpl<Genre>(this as Genre, _$identity);

  /// Serializes this Genre to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Genre&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slug,name);

@override
String toString() {
  return 'Genre(slug: $slug, name: $name)';
}


}

/// @nodoc
abstract mixin class $GenreCopyWith<$Res>  {
  factory $GenreCopyWith(Genre value, $Res Function(Genre) _then) = _$GenreCopyWithImpl;
@useResult
$Res call({
 String slug, String name
});




}
/// @nodoc
class _$GenreCopyWithImpl<$Res>
    implements $GenreCopyWith<$Res> {
  _$GenreCopyWithImpl(this._self, this._then);

  final Genre _self;
  final $Res Function(Genre) _then;

/// Create a copy of Genre
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? slug = null,Object? name = null,}) {
  return _then(_self.copyWith(
slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Genre].
extension GenrePatterns on Genre {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Genre value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Genre() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Genre value)  $default,){
final _that = this;
switch (_that) {
case _Genre():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Genre value)?  $default,){
final _that = this;
switch (_that) {
case _Genre() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String slug,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Genre() when $default != null:
return $default(_that.slug,_that.name);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String slug,  String name)  $default,) {final _that = this;
switch (_that) {
case _Genre():
return $default(_that.slug,_that.name);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String slug,  String name)?  $default,) {final _that = this;
switch (_that) {
case _Genre() when $default != null:
return $default(_that.slug,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Genre implements Genre {
  const _Genre({required this.slug, required this.name});
  factory _Genre.fromJson(Map<String, dynamic> json) => _$GenreFromJson(json);

@override final  String slug;
@override final  String name;

/// Create a copy of Genre
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GenreCopyWith<_Genre> get copyWith => __$GenreCopyWithImpl<_Genre>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GenreToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Genre&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slug,name);

@override
String toString() {
  return 'Genre(slug: $slug, name: $name)';
}


}

/// @nodoc
abstract mixin class _$GenreCopyWith<$Res> implements $GenreCopyWith<$Res> {
  factory _$GenreCopyWith(_Genre value, $Res Function(_Genre) _then) = __$GenreCopyWithImpl;
@override @useResult
$Res call({
 String slug, String name
});




}
/// @nodoc
class __$GenreCopyWithImpl<$Res>
    implements _$GenreCopyWith<$Res> {
  __$GenreCopyWithImpl(this._self, this._then);

  final _Genre _self;
  final $Res Function(_Genre) _then;

/// Create a copy of Genre
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? slug = null,Object? name = null,}) {
  return _then(_Genre(
slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$TitleProgress {

 String? get episodeId; int get positionSeconds; int get durationSeconds; int get percent; bool get completed;
/// Create a copy of TitleProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TitleProgressCopyWith<TitleProgress> get copyWith => _$TitleProgressCopyWithImpl<TitleProgress>(this as TitleProgress, _$identity);

  /// Serializes this TitleProgress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TitleProgress&&(identical(other.episodeId, episodeId) || other.episodeId == episodeId)&&(identical(other.positionSeconds, positionSeconds) || other.positionSeconds == positionSeconds)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.percent, percent) || other.percent == percent)&&(identical(other.completed, completed) || other.completed == completed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,episodeId,positionSeconds,durationSeconds,percent,completed);

@override
String toString() {
  return 'TitleProgress(episodeId: $episodeId, positionSeconds: $positionSeconds, durationSeconds: $durationSeconds, percent: $percent, completed: $completed)';
}


}

/// @nodoc
abstract mixin class $TitleProgressCopyWith<$Res>  {
  factory $TitleProgressCopyWith(TitleProgress value, $Res Function(TitleProgress) _then) = _$TitleProgressCopyWithImpl;
@useResult
$Res call({
 String? episodeId, int positionSeconds, int durationSeconds, int percent, bool completed
});




}
/// @nodoc
class _$TitleProgressCopyWithImpl<$Res>
    implements $TitleProgressCopyWith<$Res> {
  _$TitleProgressCopyWithImpl(this._self, this._then);

  final TitleProgress _self;
  final $Res Function(TitleProgress) _then;

/// Create a copy of TitleProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? episodeId = freezed,Object? positionSeconds = null,Object? durationSeconds = null,Object? percent = null,Object? completed = null,}) {
  return _then(_self.copyWith(
episodeId: freezed == episodeId ? _self.episodeId : episodeId // ignore: cast_nullable_to_non_nullable
as String?,positionSeconds: null == positionSeconds ? _self.positionSeconds : positionSeconds // ignore: cast_nullable_to_non_nullable
as int,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,percent: null == percent ? _self.percent : percent // ignore: cast_nullable_to_non_nullable
as int,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TitleProgress].
extension TitleProgressPatterns on TitleProgress {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TitleProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TitleProgress() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TitleProgress value)  $default,){
final _that = this;
switch (_that) {
case _TitleProgress():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TitleProgress value)?  $default,){
final _that = this;
switch (_that) {
case _TitleProgress() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? episodeId,  int positionSeconds,  int durationSeconds,  int percent,  bool completed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TitleProgress() when $default != null:
return $default(_that.episodeId,_that.positionSeconds,_that.durationSeconds,_that.percent,_that.completed);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? episodeId,  int positionSeconds,  int durationSeconds,  int percent,  bool completed)  $default,) {final _that = this;
switch (_that) {
case _TitleProgress():
return $default(_that.episodeId,_that.positionSeconds,_that.durationSeconds,_that.percent,_that.completed);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? episodeId,  int positionSeconds,  int durationSeconds,  int percent,  bool completed)?  $default,) {final _that = this;
switch (_that) {
case _TitleProgress() when $default != null:
return $default(_that.episodeId,_that.positionSeconds,_that.durationSeconds,_that.percent,_that.completed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TitleProgress implements TitleProgress {
  const _TitleProgress({this.episodeId, this.positionSeconds = 0, this.durationSeconds = 0, this.percent = 0, this.completed = false});
  factory _TitleProgress.fromJson(Map<String, dynamic> json) => _$TitleProgressFromJson(json);

@override final  String? episodeId;
@override@JsonKey() final  int positionSeconds;
@override@JsonKey() final  int durationSeconds;
@override@JsonKey() final  int percent;
@override@JsonKey() final  bool completed;

/// Create a copy of TitleProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TitleProgressCopyWith<_TitleProgress> get copyWith => __$TitleProgressCopyWithImpl<_TitleProgress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TitleProgressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TitleProgress&&(identical(other.episodeId, episodeId) || other.episodeId == episodeId)&&(identical(other.positionSeconds, positionSeconds) || other.positionSeconds == positionSeconds)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.percent, percent) || other.percent == percent)&&(identical(other.completed, completed) || other.completed == completed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,episodeId,positionSeconds,durationSeconds,percent,completed);

@override
String toString() {
  return 'TitleProgress(episodeId: $episodeId, positionSeconds: $positionSeconds, durationSeconds: $durationSeconds, percent: $percent, completed: $completed)';
}


}

/// @nodoc
abstract mixin class _$TitleProgressCopyWith<$Res> implements $TitleProgressCopyWith<$Res> {
  factory _$TitleProgressCopyWith(_TitleProgress value, $Res Function(_TitleProgress) _then) = __$TitleProgressCopyWithImpl;
@override @useResult
$Res call({
 String? episodeId, int positionSeconds, int durationSeconds, int percent, bool completed
});




}
/// @nodoc
class __$TitleProgressCopyWithImpl<$Res>
    implements _$TitleProgressCopyWith<$Res> {
  __$TitleProgressCopyWithImpl(this._self, this._then);

  final _TitleProgress _self;
  final $Res Function(_TitleProgress) _then;

/// Create a copy of TitleProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? episodeId = freezed,Object? positionSeconds = null,Object? durationSeconds = null,Object? percent = null,Object? completed = null,}) {
  return _then(_TitleProgress(
episodeId: freezed == episodeId ? _self.episodeId : episodeId // ignore: cast_nullable_to_non_nullable
as String?,positionSeconds: null == positionSeconds ? _self.positionSeconds : positionSeconds // ignore: cast_nullable_to_non_nullable
as int,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,percent: null == percent ? _self.percent : percent // ignore: cast_nullable_to_non_nullable
as int,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$TitleCard {

 String get id; String get slug; String get name; String get kind; int get releaseYear; String get maturityRating; int get runtimeMinutes; String get posterPath; String get backdropPath; String? get logoPath; int get matchPercent; List<String> get badges; List<Genre> get genres; TitleProgress? get progress;
/// Create a copy of TitleCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TitleCardCopyWith<TitleCard> get copyWith => _$TitleCardCopyWithImpl<TitleCard>(this as TitleCard, _$identity);

  /// Serializes this TitleCard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TitleCard&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.releaseYear, releaseYear) || other.releaseYear == releaseYear)&&(identical(other.maturityRating, maturityRating) || other.maturityRating == maturityRating)&&(identical(other.runtimeMinutes, runtimeMinutes) || other.runtimeMinutes == runtimeMinutes)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.backdropPath, backdropPath) || other.backdropPath == backdropPath)&&(identical(other.logoPath, logoPath) || other.logoPath == logoPath)&&(identical(other.matchPercent, matchPercent) || other.matchPercent == matchPercent)&&const DeepCollectionEquality().equals(other.badges, badges)&&const DeepCollectionEquality().equals(other.genres, genres)&&(identical(other.progress, progress) || other.progress == progress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,name,kind,releaseYear,maturityRating,runtimeMinutes,posterPath,backdropPath,logoPath,matchPercent,const DeepCollectionEquality().hash(badges),const DeepCollectionEquality().hash(genres),progress);

@override
String toString() {
  return 'TitleCard(id: $id, slug: $slug, name: $name, kind: $kind, releaseYear: $releaseYear, maturityRating: $maturityRating, runtimeMinutes: $runtimeMinutes, posterPath: $posterPath, backdropPath: $backdropPath, logoPath: $logoPath, matchPercent: $matchPercent, badges: $badges, genres: $genres, progress: $progress)';
}


}

/// @nodoc
abstract mixin class $TitleCardCopyWith<$Res>  {
  factory $TitleCardCopyWith(TitleCard value, $Res Function(TitleCard) _then) = _$TitleCardCopyWithImpl;
@useResult
$Res call({
 String id, String slug, String name, String kind, int releaseYear, String maturityRating, int runtimeMinutes, String posterPath, String backdropPath, String? logoPath, int matchPercent, List<String> badges, List<Genre> genres, TitleProgress? progress
});


$TitleProgressCopyWith<$Res>? get progress;

}
/// @nodoc
class _$TitleCardCopyWithImpl<$Res>
    implements $TitleCardCopyWith<$Res> {
  _$TitleCardCopyWithImpl(this._self, this._then);

  final TitleCard _self;
  final $Res Function(TitleCard) _then;

/// Create a copy of TitleCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? slug = null,Object? name = null,Object? kind = null,Object? releaseYear = null,Object? maturityRating = null,Object? runtimeMinutes = null,Object? posterPath = null,Object? backdropPath = null,Object? logoPath = freezed,Object? matchPercent = null,Object? badges = null,Object? genres = null,Object? progress = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,releaseYear: null == releaseYear ? _self.releaseYear : releaseYear // ignore: cast_nullable_to_non_nullable
as int,maturityRating: null == maturityRating ? _self.maturityRating : maturityRating // ignore: cast_nullable_to_non_nullable
as String,runtimeMinutes: null == runtimeMinutes ? _self.runtimeMinutes : runtimeMinutes // ignore: cast_nullable_to_non_nullable
as int,posterPath: null == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String,backdropPath: null == backdropPath ? _self.backdropPath : backdropPath // ignore: cast_nullable_to_non_nullable
as String,logoPath: freezed == logoPath ? _self.logoPath : logoPath // ignore: cast_nullable_to_non_nullable
as String?,matchPercent: null == matchPercent ? _self.matchPercent : matchPercent // ignore: cast_nullable_to_non_nullable
as int,badges: null == badges ? _self.badges : badges // ignore: cast_nullable_to_non_nullable
as List<String>,genres: null == genres ? _self.genres : genres // ignore: cast_nullable_to_non_nullable
as List<Genre>,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as TitleProgress?,
  ));
}
/// Create a copy of TitleCard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TitleProgressCopyWith<$Res>? get progress {
    if (_self.progress == null) {
    return null;
  }

  return $TitleProgressCopyWith<$Res>(_self.progress!, (value) {
    return _then(_self.copyWith(progress: value));
  });
}
}


/// Adds pattern-matching-related methods to [TitleCard].
extension TitleCardPatterns on TitleCard {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TitleCard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TitleCard() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TitleCard value)  $default,){
final _that = this;
switch (_that) {
case _TitleCard():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TitleCard value)?  $default,){
final _that = this;
switch (_that) {
case _TitleCard() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String slug,  String name,  String kind,  int releaseYear,  String maturityRating,  int runtimeMinutes,  String posterPath,  String backdropPath,  String? logoPath,  int matchPercent,  List<String> badges,  List<Genre> genres,  TitleProgress? progress)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TitleCard() when $default != null:
return $default(_that.id,_that.slug,_that.name,_that.kind,_that.releaseYear,_that.maturityRating,_that.runtimeMinutes,_that.posterPath,_that.backdropPath,_that.logoPath,_that.matchPercent,_that.badges,_that.genres,_that.progress);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String slug,  String name,  String kind,  int releaseYear,  String maturityRating,  int runtimeMinutes,  String posterPath,  String backdropPath,  String? logoPath,  int matchPercent,  List<String> badges,  List<Genre> genres,  TitleProgress? progress)  $default,) {final _that = this;
switch (_that) {
case _TitleCard():
return $default(_that.id,_that.slug,_that.name,_that.kind,_that.releaseYear,_that.maturityRating,_that.runtimeMinutes,_that.posterPath,_that.backdropPath,_that.logoPath,_that.matchPercent,_that.badges,_that.genres,_that.progress);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String slug,  String name,  String kind,  int releaseYear,  String maturityRating,  int runtimeMinutes,  String posterPath,  String backdropPath,  String? logoPath,  int matchPercent,  List<String> badges,  List<Genre> genres,  TitleProgress? progress)?  $default,) {final _that = this;
switch (_that) {
case _TitleCard() when $default != null:
return $default(_that.id,_that.slug,_that.name,_that.kind,_that.releaseYear,_that.maturityRating,_that.runtimeMinutes,_that.posterPath,_that.backdropPath,_that.logoPath,_that.matchPercent,_that.badges,_that.genres,_that.progress);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TitleCard implements TitleCard {
  const _TitleCard({required this.id, required this.slug, required this.name, this.kind = 'movie', this.releaseYear = 0, this.maturityRating = '', this.runtimeMinutes = 0, this.posterPath = '', this.backdropPath = '', this.logoPath, this.matchPercent = 0, final  List<String> badges = const <String>[], final  List<Genre> genres = const <Genre>[], this.progress}): _badges = badges,_genres = genres;
  factory _TitleCard.fromJson(Map<String, dynamic> json) => _$TitleCardFromJson(json);

@override final  String id;
@override final  String slug;
@override final  String name;
@override@JsonKey() final  String kind;
@override@JsonKey() final  int releaseYear;
@override@JsonKey() final  String maturityRating;
@override@JsonKey() final  int runtimeMinutes;
@override@JsonKey() final  String posterPath;
@override@JsonKey() final  String backdropPath;
@override final  String? logoPath;
@override@JsonKey() final  int matchPercent;
 final  List<String> _badges;
@override@JsonKey() List<String> get badges {
  if (_badges is EqualUnmodifiableListView) return _badges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_badges);
}

 final  List<Genre> _genres;
@override@JsonKey() List<Genre> get genres {
  if (_genres is EqualUnmodifiableListView) return _genres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genres);
}

@override final  TitleProgress? progress;

/// Create a copy of TitleCard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TitleCardCopyWith<_TitleCard> get copyWith => __$TitleCardCopyWithImpl<_TitleCard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TitleCardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TitleCard&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.releaseYear, releaseYear) || other.releaseYear == releaseYear)&&(identical(other.maturityRating, maturityRating) || other.maturityRating == maturityRating)&&(identical(other.runtimeMinutes, runtimeMinutes) || other.runtimeMinutes == runtimeMinutes)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.backdropPath, backdropPath) || other.backdropPath == backdropPath)&&(identical(other.logoPath, logoPath) || other.logoPath == logoPath)&&(identical(other.matchPercent, matchPercent) || other.matchPercent == matchPercent)&&const DeepCollectionEquality().equals(other._badges, _badges)&&const DeepCollectionEquality().equals(other._genres, _genres)&&(identical(other.progress, progress) || other.progress == progress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,name,kind,releaseYear,maturityRating,runtimeMinutes,posterPath,backdropPath,logoPath,matchPercent,const DeepCollectionEquality().hash(_badges),const DeepCollectionEquality().hash(_genres),progress);

@override
String toString() {
  return 'TitleCard(id: $id, slug: $slug, name: $name, kind: $kind, releaseYear: $releaseYear, maturityRating: $maturityRating, runtimeMinutes: $runtimeMinutes, posterPath: $posterPath, backdropPath: $backdropPath, logoPath: $logoPath, matchPercent: $matchPercent, badges: $badges, genres: $genres, progress: $progress)';
}


}

/// @nodoc
abstract mixin class _$TitleCardCopyWith<$Res> implements $TitleCardCopyWith<$Res> {
  factory _$TitleCardCopyWith(_TitleCard value, $Res Function(_TitleCard) _then) = __$TitleCardCopyWithImpl;
@override @useResult
$Res call({
 String id, String slug, String name, String kind, int releaseYear, String maturityRating, int runtimeMinutes, String posterPath, String backdropPath, String? logoPath, int matchPercent, List<String> badges, List<Genre> genres, TitleProgress? progress
});


@override $TitleProgressCopyWith<$Res>? get progress;

}
/// @nodoc
class __$TitleCardCopyWithImpl<$Res>
    implements _$TitleCardCopyWith<$Res> {
  __$TitleCardCopyWithImpl(this._self, this._then);

  final _TitleCard _self;
  final $Res Function(_TitleCard) _then;

/// Create a copy of TitleCard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? slug = null,Object? name = null,Object? kind = null,Object? releaseYear = null,Object? maturityRating = null,Object? runtimeMinutes = null,Object? posterPath = null,Object? backdropPath = null,Object? logoPath = freezed,Object? matchPercent = null,Object? badges = null,Object? genres = null,Object? progress = freezed,}) {
  return _then(_TitleCard(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,releaseYear: null == releaseYear ? _self.releaseYear : releaseYear // ignore: cast_nullable_to_non_nullable
as int,maturityRating: null == maturityRating ? _self.maturityRating : maturityRating // ignore: cast_nullable_to_non_nullable
as String,runtimeMinutes: null == runtimeMinutes ? _self.runtimeMinutes : runtimeMinutes // ignore: cast_nullable_to_non_nullable
as int,posterPath: null == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String,backdropPath: null == backdropPath ? _self.backdropPath : backdropPath // ignore: cast_nullable_to_non_nullable
as String,logoPath: freezed == logoPath ? _self.logoPath : logoPath // ignore: cast_nullable_to_non_nullable
as String?,matchPercent: null == matchPercent ? _self.matchPercent : matchPercent // ignore: cast_nullable_to_non_nullable
as int,badges: null == badges ? _self._badges : badges // ignore: cast_nullable_to_non_nullable
as List<String>,genres: null == genres ? _self._genres : genres // ignore: cast_nullable_to_non_nullable
as List<Genre>,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as TitleProgress?,
  ));
}

/// Create a copy of TitleCard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TitleProgressCopyWith<$Res>? get progress {
    if (_self.progress == null) {
    return null;
  }

  return $TitleProgressCopyWith<$Res>(_self.progress!, (value) {
    return _then(_self.copyWith(progress: value));
  });
}
}


/// @nodoc
mixin _$Episode {

 String get id; int get number; int get seasonNumber; String get name; String get synopsis; int get runtimeMinutes; String get stillPath;
/// Create a copy of Episode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EpisodeCopyWith<Episode> get copyWith => _$EpisodeCopyWithImpl<Episode>(this as Episode, _$identity);

  /// Serializes this Episode to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Episode&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.seasonNumber, seasonNumber) || other.seasonNumber == seasonNumber)&&(identical(other.name, name) || other.name == name)&&(identical(other.synopsis, synopsis) || other.synopsis == synopsis)&&(identical(other.runtimeMinutes, runtimeMinutes) || other.runtimeMinutes == runtimeMinutes)&&(identical(other.stillPath, stillPath) || other.stillPath == stillPath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,number,seasonNumber,name,synopsis,runtimeMinutes,stillPath);

@override
String toString() {
  return 'Episode(id: $id, number: $number, seasonNumber: $seasonNumber, name: $name, synopsis: $synopsis, runtimeMinutes: $runtimeMinutes, stillPath: $stillPath)';
}


}

/// @nodoc
abstract mixin class $EpisodeCopyWith<$Res>  {
  factory $EpisodeCopyWith(Episode value, $Res Function(Episode) _then) = _$EpisodeCopyWithImpl;
@useResult
$Res call({
 String id, int number, int seasonNumber, String name, String synopsis, int runtimeMinutes, String stillPath
});




}
/// @nodoc
class _$EpisodeCopyWithImpl<$Res>
    implements $EpisodeCopyWith<$Res> {
  _$EpisodeCopyWithImpl(this._self, this._then);

  final Episode _self;
  final $Res Function(Episode) _then;

/// Create a copy of Episode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? number = null,Object? seasonNumber = null,Object? name = null,Object? synopsis = null,Object? runtimeMinutes = null,Object? stillPath = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,seasonNumber: null == seasonNumber ? _self.seasonNumber : seasonNumber // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,synopsis: null == synopsis ? _self.synopsis : synopsis // ignore: cast_nullable_to_non_nullable
as String,runtimeMinutes: null == runtimeMinutes ? _self.runtimeMinutes : runtimeMinutes // ignore: cast_nullable_to_non_nullable
as int,stillPath: null == stillPath ? _self.stillPath : stillPath // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Episode].
extension EpisodePatterns on Episode {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Episode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Episode() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Episode value)  $default,){
final _that = this;
switch (_that) {
case _Episode():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Episode value)?  $default,){
final _that = this;
switch (_that) {
case _Episode() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int number,  int seasonNumber,  String name,  String synopsis,  int runtimeMinutes,  String stillPath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Episode() when $default != null:
return $default(_that.id,_that.number,_that.seasonNumber,_that.name,_that.synopsis,_that.runtimeMinutes,_that.stillPath);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int number,  int seasonNumber,  String name,  String synopsis,  int runtimeMinutes,  String stillPath)  $default,) {final _that = this;
switch (_that) {
case _Episode():
return $default(_that.id,_that.number,_that.seasonNumber,_that.name,_that.synopsis,_that.runtimeMinutes,_that.stillPath);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int number,  int seasonNumber,  String name,  String synopsis,  int runtimeMinutes,  String stillPath)?  $default,) {final _that = this;
switch (_that) {
case _Episode() when $default != null:
return $default(_that.id,_that.number,_that.seasonNumber,_that.name,_that.synopsis,_that.runtimeMinutes,_that.stillPath);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Episode implements Episode {
  const _Episode({required this.id, this.number = 0, this.seasonNumber = 0, required this.name, this.synopsis = '', this.runtimeMinutes = 0, this.stillPath = ''});
  factory _Episode.fromJson(Map<String, dynamic> json) => _$EpisodeFromJson(json);

@override final  String id;
@override@JsonKey() final  int number;
@override@JsonKey() final  int seasonNumber;
@override final  String name;
@override@JsonKey() final  String synopsis;
@override@JsonKey() final  int runtimeMinutes;
@override@JsonKey() final  String stillPath;

/// Create a copy of Episode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EpisodeCopyWith<_Episode> get copyWith => __$EpisodeCopyWithImpl<_Episode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EpisodeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Episode&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.seasonNumber, seasonNumber) || other.seasonNumber == seasonNumber)&&(identical(other.name, name) || other.name == name)&&(identical(other.synopsis, synopsis) || other.synopsis == synopsis)&&(identical(other.runtimeMinutes, runtimeMinutes) || other.runtimeMinutes == runtimeMinutes)&&(identical(other.stillPath, stillPath) || other.stillPath == stillPath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,number,seasonNumber,name,synopsis,runtimeMinutes,stillPath);

@override
String toString() {
  return 'Episode(id: $id, number: $number, seasonNumber: $seasonNumber, name: $name, synopsis: $synopsis, runtimeMinutes: $runtimeMinutes, stillPath: $stillPath)';
}


}

/// @nodoc
abstract mixin class _$EpisodeCopyWith<$Res> implements $EpisodeCopyWith<$Res> {
  factory _$EpisodeCopyWith(_Episode value, $Res Function(_Episode) _then) = __$EpisodeCopyWithImpl;
@override @useResult
$Res call({
 String id, int number, int seasonNumber, String name, String synopsis, int runtimeMinutes, String stillPath
});




}
/// @nodoc
class __$EpisodeCopyWithImpl<$Res>
    implements _$EpisodeCopyWith<$Res> {
  __$EpisodeCopyWithImpl(this._self, this._then);

  final _Episode _self;
  final $Res Function(_Episode) _then;

/// Create a copy of Episode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? number = null,Object? seasonNumber = null,Object? name = null,Object? synopsis = null,Object? runtimeMinutes = null,Object? stillPath = null,}) {
  return _then(_Episode(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,seasonNumber: null == seasonNumber ? _self.seasonNumber : seasonNumber // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,synopsis: null == synopsis ? _self.synopsis : synopsis // ignore: cast_nullable_to_non_nullable
as String,runtimeMinutes: null == runtimeMinutes ? _self.runtimeMinutes : runtimeMinutes // ignore: cast_nullable_to_non_nullable
as int,stillPath: null == stillPath ? _self.stillPath : stillPath // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Season {

 String get id; int get number; String get name; List<Episode> get episodes;
/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeasonCopyWith<Season> get copyWith => _$SeasonCopyWithImpl<Season>(this as Season, _$identity);

  /// Serializes this Season to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Season&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.episodes, episodes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,number,name,const DeepCollectionEquality().hash(episodes));

@override
String toString() {
  return 'Season(id: $id, number: $number, name: $name, episodes: $episodes)';
}


}

/// @nodoc
abstract mixin class $SeasonCopyWith<$Res>  {
  factory $SeasonCopyWith(Season value, $Res Function(Season) _then) = _$SeasonCopyWithImpl;
@useResult
$Res call({
 String id, int number, String name, List<Episode> episodes
});




}
/// @nodoc
class _$SeasonCopyWithImpl<$Res>
    implements $SeasonCopyWith<$Res> {
  _$SeasonCopyWithImpl(this._self, this._then);

  final Season _self;
  final $Res Function(Season) _then;

/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? number = null,Object? name = null,Object? episodes = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,episodes: null == episodes ? _self.episodes : episodes // ignore: cast_nullable_to_non_nullable
as List<Episode>,
  ));
}

}


/// Adds pattern-matching-related methods to [Season].
extension SeasonPatterns on Season {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Season value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Season() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Season value)  $default,){
final _that = this;
switch (_that) {
case _Season():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Season value)?  $default,){
final _that = this;
switch (_that) {
case _Season() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int number,  String name,  List<Episode> episodes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Season() when $default != null:
return $default(_that.id,_that.number,_that.name,_that.episodes);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int number,  String name,  List<Episode> episodes)  $default,) {final _that = this;
switch (_that) {
case _Season():
return $default(_that.id,_that.number,_that.name,_that.episodes);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int number,  String name,  List<Episode> episodes)?  $default,) {final _that = this;
switch (_that) {
case _Season() when $default != null:
return $default(_that.id,_that.number,_that.name,_that.episodes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Season implements Season {
  const _Season({required this.id, this.number = 0, required this.name, final  List<Episode> episodes = const <Episode>[]}): _episodes = episodes;
  factory _Season.fromJson(Map<String, dynamic> json) => _$SeasonFromJson(json);

@override final  String id;
@override@JsonKey() final  int number;
@override final  String name;
 final  List<Episode> _episodes;
@override@JsonKey() List<Episode> get episodes {
  if (_episodes is EqualUnmodifiableListView) return _episodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_episodes);
}


/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SeasonCopyWith<_Season> get copyWith => __$SeasonCopyWithImpl<_Season>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SeasonToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Season&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._episodes, _episodes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,number,name,const DeepCollectionEquality().hash(_episodes));

@override
String toString() {
  return 'Season(id: $id, number: $number, name: $name, episodes: $episodes)';
}


}

/// @nodoc
abstract mixin class _$SeasonCopyWith<$Res> implements $SeasonCopyWith<$Res> {
  factory _$SeasonCopyWith(_Season value, $Res Function(_Season) _then) = __$SeasonCopyWithImpl;
@override @useResult
$Res call({
 String id, int number, String name, List<Episode> episodes
});




}
/// @nodoc
class __$SeasonCopyWithImpl<$Res>
    implements _$SeasonCopyWith<$Res> {
  __$SeasonCopyWithImpl(this._self, this._then);

  final _Season _self;
  final $Res Function(_Season) _then;

/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? number = null,Object? name = null,Object? episodes = null,}) {
  return _then(_Season(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,episodes: null == episodes ? _self._episodes : episodes // ignore: cast_nullable_to_non_nullable
as List<Episode>,
  ));
}


}


/// @nodoc
mixin _$TitleOffer {

 String get titleId; String get sourceId; String get sourceName; int get episodeCount; bool get selected;
/// Create a copy of TitleOffer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TitleOfferCopyWith<TitleOffer> get copyWith => _$TitleOfferCopyWithImpl<TitleOffer>(this as TitleOffer, _$identity);

  /// Serializes this TitleOffer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TitleOffer&&(identical(other.titleId, titleId) || other.titleId == titleId)&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.sourceName, sourceName) || other.sourceName == sourceName)&&(identical(other.episodeCount, episodeCount) || other.episodeCount == episodeCount)&&(identical(other.selected, selected) || other.selected == selected));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,titleId,sourceId,sourceName,episodeCount,selected);

@override
String toString() {
  return 'TitleOffer(titleId: $titleId, sourceId: $sourceId, sourceName: $sourceName, episodeCount: $episodeCount, selected: $selected)';
}


}

/// @nodoc
abstract mixin class $TitleOfferCopyWith<$Res>  {
  factory $TitleOfferCopyWith(TitleOffer value, $Res Function(TitleOffer) _then) = _$TitleOfferCopyWithImpl;
@useResult
$Res call({
 String titleId, String sourceId, String sourceName, int episodeCount, bool selected
});




}
/// @nodoc
class _$TitleOfferCopyWithImpl<$Res>
    implements $TitleOfferCopyWith<$Res> {
  _$TitleOfferCopyWithImpl(this._self, this._then);

  final TitleOffer _self;
  final $Res Function(TitleOffer) _then;

/// Create a copy of TitleOffer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? titleId = null,Object? sourceId = null,Object? sourceName = null,Object? episodeCount = null,Object? selected = null,}) {
  return _then(_self.copyWith(
titleId: null == titleId ? _self.titleId : titleId // ignore: cast_nullable_to_non_nullable
as String,sourceId: null == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String,sourceName: null == sourceName ? _self.sourceName : sourceName // ignore: cast_nullable_to_non_nullable
as String,episodeCount: null == episodeCount ? _self.episodeCount : episodeCount // ignore: cast_nullable_to_non_nullable
as int,selected: null == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TitleOffer].
extension TitleOfferPatterns on TitleOffer {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TitleOffer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TitleOffer() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TitleOffer value)  $default,){
final _that = this;
switch (_that) {
case _TitleOffer():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TitleOffer value)?  $default,){
final _that = this;
switch (_that) {
case _TitleOffer() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String titleId,  String sourceId,  String sourceName,  int episodeCount,  bool selected)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TitleOffer() when $default != null:
return $default(_that.titleId,_that.sourceId,_that.sourceName,_that.episodeCount,_that.selected);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String titleId,  String sourceId,  String sourceName,  int episodeCount,  bool selected)  $default,) {final _that = this;
switch (_that) {
case _TitleOffer():
return $default(_that.titleId,_that.sourceId,_that.sourceName,_that.episodeCount,_that.selected);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String titleId,  String sourceId,  String sourceName,  int episodeCount,  bool selected)?  $default,) {final _that = this;
switch (_that) {
case _TitleOffer() when $default != null:
return $default(_that.titleId,_that.sourceId,_that.sourceName,_that.episodeCount,_that.selected);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TitleOffer implements TitleOffer {
  const _TitleOffer({required this.titleId, this.sourceId = '', this.sourceName = '', this.episodeCount = 0, this.selected = false});
  factory _TitleOffer.fromJson(Map<String, dynamic> json) => _$TitleOfferFromJson(json);

@override final  String titleId;
@override@JsonKey() final  String sourceId;
@override@JsonKey() final  String sourceName;
@override@JsonKey() final  int episodeCount;
@override@JsonKey() final  bool selected;

/// Create a copy of TitleOffer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TitleOfferCopyWith<_TitleOffer> get copyWith => __$TitleOfferCopyWithImpl<_TitleOffer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TitleOfferToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TitleOffer&&(identical(other.titleId, titleId) || other.titleId == titleId)&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.sourceName, sourceName) || other.sourceName == sourceName)&&(identical(other.episodeCount, episodeCount) || other.episodeCount == episodeCount)&&(identical(other.selected, selected) || other.selected == selected));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,titleId,sourceId,sourceName,episodeCount,selected);

@override
String toString() {
  return 'TitleOffer(titleId: $titleId, sourceId: $sourceId, sourceName: $sourceName, episodeCount: $episodeCount, selected: $selected)';
}


}

/// @nodoc
abstract mixin class _$TitleOfferCopyWith<$Res> implements $TitleOfferCopyWith<$Res> {
  factory _$TitleOfferCopyWith(_TitleOffer value, $Res Function(_TitleOffer) _then) = __$TitleOfferCopyWithImpl;
@override @useResult
$Res call({
 String titleId, String sourceId, String sourceName, int episodeCount, bool selected
});




}
/// @nodoc
class __$TitleOfferCopyWithImpl<$Res>
    implements _$TitleOfferCopyWith<$Res> {
  __$TitleOfferCopyWithImpl(this._self, this._then);

  final _TitleOffer _self;
  final $Res Function(_TitleOffer) _then;

/// Create a copy of TitleOffer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? titleId = null,Object? sourceId = null,Object? sourceName = null,Object? episodeCount = null,Object? selected = null,}) {
  return _then(_TitleOffer(
titleId: null == titleId ? _self.titleId : titleId // ignore: cast_nullable_to_non_nullable
as String,sourceId: null == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String,sourceName: null == sourceName ? _self.sourceName : sourceName // ignore: cast_nullable_to_non_nullable
as String,episodeCount: null == episodeCount ? _self.episodeCount : episodeCount // ignore: cast_nullable_to_non_nullable
as int,selected: null == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$TitleDetail {

 String get id; String get slug; String get name; String get kind; int get releaseYear; String get maturityRating; int get runtimeMinutes; String get posterPath; String get backdropPath; String? get logoPath; int get matchPercent; List<String> get badges; List<Genre> get genres; String get originalName; String get synopsis; String get tagline; String get director; String get country; List<String> get cast; String get trailerUrl; bool get inWatchlist; TitleProgress? get resume; TitleProgress? get progress; List<Season> get seasons; List<TitleOffer> get offers;
/// Create a copy of TitleDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TitleDetailCopyWith<TitleDetail> get copyWith => _$TitleDetailCopyWithImpl<TitleDetail>(this as TitleDetail, _$identity);

  /// Serializes this TitleDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TitleDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.releaseYear, releaseYear) || other.releaseYear == releaseYear)&&(identical(other.maturityRating, maturityRating) || other.maturityRating == maturityRating)&&(identical(other.runtimeMinutes, runtimeMinutes) || other.runtimeMinutes == runtimeMinutes)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.backdropPath, backdropPath) || other.backdropPath == backdropPath)&&(identical(other.logoPath, logoPath) || other.logoPath == logoPath)&&(identical(other.matchPercent, matchPercent) || other.matchPercent == matchPercent)&&const DeepCollectionEquality().equals(other.badges, badges)&&const DeepCollectionEquality().equals(other.genres, genres)&&(identical(other.originalName, originalName) || other.originalName == originalName)&&(identical(other.synopsis, synopsis) || other.synopsis == synopsis)&&(identical(other.tagline, tagline) || other.tagline == tagline)&&(identical(other.director, director) || other.director == director)&&(identical(other.country, country) || other.country == country)&&const DeepCollectionEquality().equals(other.cast, cast)&&(identical(other.trailerUrl, trailerUrl) || other.trailerUrl == trailerUrl)&&(identical(other.inWatchlist, inWatchlist) || other.inWatchlist == inWatchlist)&&(identical(other.resume, resume) || other.resume == resume)&&(identical(other.progress, progress) || other.progress == progress)&&const DeepCollectionEquality().equals(other.seasons, seasons)&&const DeepCollectionEquality().equals(other.offers, offers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,slug,name,kind,releaseYear,maturityRating,runtimeMinutes,posterPath,backdropPath,logoPath,matchPercent,const DeepCollectionEquality().hash(badges),const DeepCollectionEquality().hash(genres),originalName,synopsis,tagline,director,country,const DeepCollectionEquality().hash(cast),trailerUrl,inWatchlist,resume,progress,const DeepCollectionEquality().hash(seasons),const DeepCollectionEquality().hash(offers)]);

@override
String toString() {
  return 'TitleDetail(id: $id, slug: $slug, name: $name, kind: $kind, releaseYear: $releaseYear, maturityRating: $maturityRating, runtimeMinutes: $runtimeMinutes, posterPath: $posterPath, backdropPath: $backdropPath, logoPath: $logoPath, matchPercent: $matchPercent, badges: $badges, genres: $genres, originalName: $originalName, synopsis: $synopsis, tagline: $tagline, director: $director, country: $country, cast: $cast, trailerUrl: $trailerUrl, inWatchlist: $inWatchlist, resume: $resume, progress: $progress, seasons: $seasons, offers: $offers)';
}


}

/// @nodoc
abstract mixin class $TitleDetailCopyWith<$Res>  {
  factory $TitleDetailCopyWith(TitleDetail value, $Res Function(TitleDetail) _then) = _$TitleDetailCopyWithImpl;
@useResult
$Res call({
 String id, String slug, String name, String kind, int releaseYear, String maturityRating, int runtimeMinutes, String posterPath, String backdropPath, String? logoPath, int matchPercent, List<String> badges, List<Genre> genres, String originalName, String synopsis, String tagline, String director, String country, List<String> cast, String trailerUrl, bool inWatchlist, TitleProgress? resume, TitleProgress? progress, List<Season> seasons, List<TitleOffer> offers
});


$TitleProgressCopyWith<$Res>? get resume;$TitleProgressCopyWith<$Res>? get progress;

}
/// @nodoc
class _$TitleDetailCopyWithImpl<$Res>
    implements $TitleDetailCopyWith<$Res> {
  _$TitleDetailCopyWithImpl(this._self, this._then);

  final TitleDetail _self;
  final $Res Function(TitleDetail) _then;

/// Create a copy of TitleDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? slug = null,Object? name = null,Object? kind = null,Object? releaseYear = null,Object? maturityRating = null,Object? runtimeMinutes = null,Object? posterPath = null,Object? backdropPath = null,Object? logoPath = freezed,Object? matchPercent = null,Object? badges = null,Object? genres = null,Object? originalName = null,Object? synopsis = null,Object? tagline = null,Object? director = null,Object? country = null,Object? cast = null,Object? trailerUrl = null,Object? inWatchlist = null,Object? resume = freezed,Object? progress = freezed,Object? seasons = null,Object? offers = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,releaseYear: null == releaseYear ? _self.releaseYear : releaseYear // ignore: cast_nullable_to_non_nullable
as int,maturityRating: null == maturityRating ? _self.maturityRating : maturityRating // ignore: cast_nullable_to_non_nullable
as String,runtimeMinutes: null == runtimeMinutes ? _self.runtimeMinutes : runtimeMinutes // ignore: cast_nullable_to_non_nullable
as int,posterPath: null == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String,backdropPath: null == backdropPath ? _self.backdropPath : backdropPath // ignore: cast_nullable_to_non_nullable
as String,logoPath: freezed == logoPath ? _self.logoPath : logoPath // ignore: cast_nullable_to_non_nullable
as String?,matchPercent: null == matchPercent ? _self.matchPercent : matchPercent // ignore: cast_nullable_to_non_nullable
as int,badges: null == badges ? _self.badges : badges // ignore: cast_nullable_to_non_nullable
as List<String>,genres: null == genres ? _self.genres : genres // ignore: cast_nullable_to_non_nullable
as List<Genre>,originalName: null == originalName ? _self.originalName : originalName // ignore: cast_nullable_to_non_nullable
as String,synopsis: null == synopsis ? _self.synopsis : synopsis // ignore: cast_nullable_to_non_nullable
as String,tagline: null == tagline ? _self.tagline : tagline // ignore: cast_nullable_to_non_nullable
as String,director: null == director ? _self.director : director // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,cast: null == cast ? _self.cast : cast // ignore: cast_nullable_to_non_nullable
as List<String>,trailerUrl: null == trailerUrl ? _self.trailerUrl : trailerUrl // ignore: cast_nullable_to_non_nullable
as String,inWatchlist: null == inWatchlist ? _self.inWatchlist : inWatchlist // ignore: cast_nullable_to_non_nullable
as bool,resume: freezed == resume ? _self.resume : resume // ignore: cast_nullable_to_non_nullable
as TitleProgress?,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as TitleProgress?,seasons: null == seasons ? _self.seasons : seasons // ignore: cast_nullable_to_non_nullable
as List<Season>,offers: null == offers ? _self.offers : offers // ignore: cast_nullable_to_non_nullable
as List<TitleOffer>,
  ));
}
/// Create a copy of TitleDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TitleProgressCopyWith<$Res>? get resume {
    if (_self.resume == null) {
    return null;
  }

  return $TitleProgressCopyWith<$Res>(_self.resume!, (value) {
    return _then(_self.copyWith(resume: value));
  });
}/// Create a copy of TitleDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TitleProgressCopyWith<$Res>? get progress {
    if (_self.progress == null) {
    return null;
  }

  return $TitleProgressCopyWith<$Res>(_self.progress!, (value) {
    return _then(_self.copyWith(progress: value));
  });
}
}


/// Adds pattern-matching-related methods to [TitleDetail].
extension TitleDetailPatterns on TitleDetail {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TitleDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TitleDetail() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TitleDetail value)  $default,){
final _that = this;
switch (_that) {
case _TitleDetail():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TitleDetail value)?  $default,){
final _that = this;
switch (_that) {
case _TitleDetail() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String slug,  String name,  String kind,  int releaseYear,  String maturityRating,  int runtimeMinutes,  String posterPath,  String backdropPath,  String? logoPath,  int matchPercent,  List<String> badges,  List<Genre> genres,  String originalName,  String synopsis,  String tagline,  String director,  String country,  List<String> cast,  String trailerUrl,  bool inWatchlist,  TitleProgress? resume,  TitleProgress? progress,  List<Season> seasons,  List<TitleOffer> offers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TitleDetail() when $default != null:
return $default(_that.id,_that.slug,_that.name,_that.kind,_that.releaseYear,_that.maturityRating,_that.runtimeMinutes,_that.posterPath,_that.backdropPath,_that.logoPath,_that.matchPercent,_that.badges,_that.genres,_that.originalName,_that.synopsis,_that.tagline,_that.director,_that.country,_that.cast,_that.trailerUrl,_that.inWatchlist,_that.resume,_that.progress,_that.seasons,_that.offers);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String slug,  String name,  String kind,  int releaseYear,  String maturityRating,  int runtimeMinutes,  String posterPath,  String backdropPath,  String? logoPath,  int matchPercent,  List<String> badges,  List<Genre> genres,  String originalName,  String synopsis,  String tagline,  String director,  String country,  List<String> cast,  String trailerUrl,  bool inWatchlist,  TitleProgress? resume,  TitleProgress? progress,  List<Season> seasons,  List<TitleOffer> offers)  $default,) {final _that = this;
switch (_that) {
case _TitleDetail():
return $default(_that.id,_that.slug,_that.name,_that.kind,_that.releaseYear,_that.maturityRating,_that.runtimeMinutes,_that.posterPath,_that.backdropPath,_that.logoPath,_that.matchPercent,_that.badges,_that.genres,_that.originalName,_that.synopsis,_that.tagline,_that.director,_that.country,_that.cast,_that.trailerUrl,_that.inWatchlist,_that.resume,_that.progress,_that.seasons,_that.offers);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String slug,  String name,  String kind,  int releaseYear,  String maturityRating,  int runtimeMinutes,  String posterPath,  String backdropPath,  String? logoPath,  int matchPercent,  List<String> badges,  List<Genre> genres,  String originalName,  String synopsis,  String tagline,  String director,  String country,  List<String> cast,  String trailerUrl,  bool inWatchlist,  TitleProgress? resume,  TitleProgress? progress,  List<Season> seasons,  List<TitleOffer> offers)?  $default,) {final _that = this;
switch (_that) {
case _TitleDetail() when $default != null:
return $default(_that.id,_that.slug,_that.name,_that.kind,_that.releaseYear,_that.maturityRating,_that.runtimeMinutes,_that.posterPath,_that.backdropPath,_that.logoPath,_that.matchPercent,_that.badges,_that.genres,_that.originalName,_that.synopsis,_that.tagline,_that.director,_that.country,_that.cast,_that.trailerUrl,_that.inWatchlist,_that.resume,_that.progress,_that.seasons,_that.offers);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TitleDetail implements TitleDetail {
  const _TitleDetail({required this.id, required this.slug, required this.name, this.kind = 'movie', this.releaseYear = 0, this.maturityRating = '', this.runtimeMinutes = 0, this.posterPath = '', this.backdropPath = '', this.logoPath, this.matchPercent = 0, final  List<String> badges = const <String>[], final  List<Genre> genres = const <Genre>[], this.originalName = '', this.synopsis = '', this.tagline = '', this.director = '', this.country = '', final  List<String> cast = const <String>[], this.trailerUrl = '', this.inWatchlist = false, this.resume, this.progress, final  List<Season> seasons = const <Season>[], final  List<TitleOffer> offers = const <TitleOffer>[]}): _badges = badges,_genres = genres,_cast = cast,_seasons = seasons,_offers = offers;
  factory _TitleDetail.fromJson(Map<String, dynamic> json) => _$TitleDetailFromJson(json);

@override final  String id;
@override final  String slug;
@override final  String name;
@override@JsonKey() final  String kind;
@override@JsonKey() final  int releaseYear;
@override@JsonKey() final  String maturityRating;
@override@JsonKey() final  int runtimeMinutes;
@override@JsonKey() final  String posterPath;
@override@JsonKey() final  String backdropPath;
@override final  String? logoPath;
@override@JsonKey() final  int matchPercent;
 final  List<String> _badges;
@override@JsonKey() List<String> get badges {
  if (_badges is EqualUnmodifiableListView) return _badges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_badges);
}

 final  List<Genre> _genres;
@override@JsonKey() List<Genre> get genres {
  if (_genres is EqualUnmodifiableListView) return _genres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genres);
}

@override@JsonKey() final  String originalName;
@override@JsonKey() final  String synopsis;
@override@JsonKey() final  String tagline;
@override@JsonKey() final  String director;
@override@JsonKey() final  String country;
 final  List<String> _cast;
@override@JsonKey() List<String> get cast {
  if (_cast is EqualUnmodifiableListView) return _cast;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cast);
}

@override@JsonKey() final  String trailerUrl;
@override@JsonKey() final  bool inWatchlist;
@override final  TitleProgress? resume;
@override final  TitleProgress? progress;
 final  List<Season> _seasons;
@override@JsonKey() List<Season> get seasons {
  if (_seasons is EqualUnmodifiableListView) return _seasons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_seasons);
}

 final  List<TitleOffer> _offers;
@override@JsonKey() List<TitleOffer> get offers {
  if (_offers is EqualUnmodifiableListView) return _offers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_offers);
}


/// Create a copy of TitleDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TitleDetailCopyWith<_TitleDetail> get copyWith => __$TitleDetailCopyWithImpl<_TitleDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TitleDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TitleDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.releaseYear, releaseYear) || other.releaseYear == releaseYear)&&(identical(other.maturityRating, maturityRating) || other.maturityRating == maturityRating)&&(identical(other.runtimeMinutes, runtimeMinutes) || other.runtimeMinutes == runtimeMinutes)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.backdropPath, backdropPath) || other.backdropPath == backdropPath)&&(identical(other.logoPath, logoPath) || other.logoPath == logoPath)&&(identical(other.matchPercent, matchPercent) || other.matchPercent == matchPercent)&&const DeepCollectionEquality().equals(other._badges, _badges)&&const DeepCollectionEquality().equals(other._genres, _genres)&&(identical(other.originalName, originalName) || other.originalName == originalName)&&(identical(other.synopsis, synopsis) || other.synopsis == synopsis)&&(identical(other.tagline, tagline) || other.tagline == tagline)&&(identical(other.director, director) || other.director == director)&&(identical(other.country, country) || other.country == country)&&const DeepCollectionEquality().equals(other._cast, _cast)&&(identical(other.trailerUrl, trailerUrl) || other.trailerUrl == trailerUrl)&&(identical(other.inWatchlist, inWatchlist) || other.inWatchlist == inWatchlist)&&(identical(other.resume, resume) || other.resume == resume)&&(identical(other.progress, progress) || other.progress == progress)&&const DeepCollectionEquality().equals(other._seasons, _seasons)&&const DeepCollectionEquality().equals(other._offers, _offers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,slug,name,kind,releaseYear,maturityRating,runtimeMinutes,posterPath,backdropPath,logoPath,matchPercent,const DeepCollectionEquality().hash(_badges),const DeepCollectionEquality().hash(_genres),originalName,synopsis,tagline,director,country,const DeepCollectionEquality().hash(_cast),trailerUrl,inWatchlist,resume,progress,const DeepCollectionEquality().hash(_seasons),const DeepCollectionEquality().hash(_offers)]);

@override
String toString() {
  return 'TitleDetail(id: $id, slug: $slug, name: $name, kind: $kind, releaseYear: $releaseYear, maturityRating: $maturityRating, runtimeMinutes: $runtimeMinutes, posterPath: $posterPath, backdropPath: $backdropPath, logoPath: $logoPath, matchPercent: $matchPercent, badges: $badges, genres: $genres, originalName: $originalName, synopsis: $synopsis, tagline: $tagline, director: $director, country: $country, cast: $cast, trailerUrl: $trailerUrl, inWatchlist: $inWatchlist, resume: $resume, progress: $progress, seasons: $seasons, offers: $offers)';
}


}

/// @nodoc
abstract mixin class _$TitleDetailCopyWith<$Res> implements $TitleDetailCopyWith<$Res> {
  factory _$TitleDetailCopyWith(_TitleDetail value, $Res Function(_TitleDetail) _then) = __$TitleDetailCopyWithImpl;
@override @useResult
$Res call({
 String id, String slug, String name, String kind, int releaseYear, String maturityRating, int runtimeMinutes, String posterPath, String backdropPath, String? logoPath, int matchPercent, List<String> badges, List<Genre> genres, String originalName, String synopsis, String tagline, String director, String country, List<String> cast, String trailerUrl, bool inWatchlist, TitleProgress? resume, TitleProgress? progress, List<Season> seasons, List<TitleOffer> offers
});


@override $TitleProgressCopyWith<$Res>? get resume;@override $TitleProgressCopyWith<$Res>? get progress;

}
/// @nodoc
class __$TitleDetailCopyWithImpl<$Res>
    implements _$TitleDetailCopyWith<$Res> {
  __$TitleDetailCopyWithImpl(this._self, this._then);

  final _TitleDetail _self;
  final $Res Function(_TitleDetail) _then;

/// Create a copy of TitleDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? slug = null,Object? name = null,Object? kind = null,Object? releaseYear = null,Object? maturityRating = null,Object? runtimeMinutes = null,Object? posterPath = null,Object? backdropPath = null,Object? logoPath = freezed,Object? matchPercent = null,Object? badges = null,Object? genres = null,Object? originalName = null,Object? synopsis = null,Object? tagline = null,Object? director = null,Object? country = null,Object? cast = null,Object? trailerUrl = null,Object? inWatchlist = null,Object? resume = freezed,Object? progress = freezed,Object? seasons = null,Object? offers = null,}) {
  return _then(_TitleDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,releaseYear: null == releaseYear ? _self.releaseYear : releaseYear // ignore: cast_nullable_to_non_nullable
as int,maturityRating: null == maturityRating ? _self.maturityRating : maturityRating // ignore: cast_nullable_to_non_nullable
as String,runtimeMinutes: null == runtimeMinutes ? _self.runtimeMinutes : runtimeMinutes // ignore: cast_nullable_to_non_nullable
as int,posterPath: null == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String,backdropPath: null == backdropPath ? _self.backdropPath : backdropPath // ignore: cast_nullable_to_non_nullable
as String,logoPath: freezed == logoPath ? _self.logoPath : logoPath // ignore: cast_nullable_to_non_nullable
as String?,matchPercent: null == matchPercent ? _self.matchPercent : matchPercent // ignore: cast_nullable_to_non_nullable
as int,badges: null == badges ? _self._badges : badges // ignore: cast_nullable_to_non_nullable
as List<String>,genres: null == genres ? _self._genres : genres // ignore: cast_nullable_to_non_nullable
as List<Genre>,originalName: null == originalName ? _self.originalName : originalName // ignore: cast_nullable_to_non_nullable
as String,synopsis: null == synopsis ? _self.synopsis : synopsis // ignore: cast_nullable_to_non_nullable
as String,tagline: null == tagline ? _self.tagline : tagline // ignore: cast_nullable_to_non_nullable
as String,director: null == director ? _self.director : director // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,cast: null == cast ? _self._cast : cast // ignore: cast_nullable_to_non_nullable
as List<String>,trailerUrl: null == trailerUrl ? _self.trailerUrl : trailerUrl // ignore: cast_nullable_to_non_nullable
as String,inWatchlist: null == inWatchlist ? _self.inWatchlist : inWatchlist // ignore: cast_nullable_to_non_nullable
as bool,resume: freezed == resume ? _self.resume : resume // ignore: cast_nullable_to_non_nullable
as TitleProgress?,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as TitleProgress?,seasons: null == seasons ? _self._seasons : seasons // ignore: cast_nullable_to_non_nullable
as List<Season>,offers: null == offers ? _self._offers : offers // ignore: cast_nullable_to_non_nullable
as List<TitleOffer>,
  ));
}

/// Create a copy of TitleDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TitleProgressCopyWith<$Res>? get resume {
    if (_self.resume == null) {
    return null;
  }

  return $TitleProgressCopyWith<$Res>(_self.resume!, (value) {
    return _then(_self.copyWith(resume: value));
  });
}/// Create a copy of TitleDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TitleProgressCopyWith<$Res>? get progress {
    if (_self.progress == null) {
    return null;
  }

  return $TitleProgressCopyWith<$Res>(_self.progress!, (value) {
    return _then(_self.copyWith(progress: value));
  });
}
}


/// @nodoc
mixin _$BrowsePage {

 List<TitleCard> get items; int get page; int get pageSize; int get total; bool get hasMore;
/// Create a copy of BrowsePage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BrowsePageCopyWith<BrowsePage> get copyWith => _$BrowsePageCopyWithImpl<BrowsePage>(this as BrowsePage, _$identity);

  /// Serializes this BrowsePage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BrowsePage&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.total, total) || other.total == total)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),page,pageSize,total,hasMore);

@override
String toString() {
  return 'BrowsePage(items: $items, page: $page, pageSize: $pageSize, total: $total, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class $BrowsePageCopyWith<$Res>  {
  factory $BrowsePageCopyWith(BrowsePage value, $Res Function(BrowsePage) _then) = _$BrowsePageCopyWithImpl;
@useResult
$Res call({
 List<TitleCard> items, int page, int pageSize, int total, bool hasMore
});




}
/// @nodoc
class _$BrowsePageCopyWithImpl<$Res>
    implements $BrowsePageCopyWith<$Res> {
  _$BrowsePageCopyWithImpl(this._self, this._then);

  final BrowsePage _self;
  final $Res Function(BrowsePage) _then;

/// Create a copy of BrowsePage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? page = null,Object? pageSize = null,Object? total = null,Object? hasMore = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<TitleCard>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [BrowsePage].
extension BrowsePagePatterns on BrowsePage {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BrowsePage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BrowsePage() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BrowsePage value)  $default,){
final _that = this;
switch (_that) {
case _BrowsePage():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BrowsePage value)?  $default,){
final _that = this;
switch (_that) {
case _BrowsePage() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TitleCard> items,  int page,  int pageSize,  int total,  bool hasMore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BrowsePage() when $default != null:
return $default(_that.items,_that.page,_that.pageSize,_that.total,_that.hasMore);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TitleCard> items,  int page,  int pageSize,  int total,  bool hasMore)  $default,) {final _that = this;
switch (_that) {
case _BrowsePage():
return $default(_that.items,_that.page,_that.pageSize,_that.total,_that.hasMore);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TitleCard> items,  int page,  int pageSize,  int total,  bool hasMore)?  $default,) {final _that = this;
switch (_that) {
case _BrowsePage() when $default != null:
return $default(_that.items,_that.page,_that.pageSize,_that.total,_that.hasMore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BrowsePage implements BrowsePage {
  const _BrowsePage({final  List<TitleCard> items = const <TitleCard>[], this.page = 1, this.pageSize = 20, this.total = 0, this.hasMore = false}): _items = items;
  factory _BrowsePage.fromJson(Map<String, dynamic> json) => _$BrowsePageFromJson(json);

 final  List<TitleCard> _items;
@override@JsonKey() List<TitleCard> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  int page;
@override@JsonKey() final  int pageSize;
@override@JsonKey() final  int total;
@override@JsonKey() final  bool hasMore;

/// Create a copy of BrowsePage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BrowsePageCopyWith<_BrowsePage> get copyWith => __$BrowsePageCopyWithImpl<_BrowsePage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BrowsePageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BrowsePage&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.total, total) || other.total == total)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),page,pageSize,total,hasMore);

@override
String toString() {
  return 'BrowsePage(items: $items, page: $page, pageSize: $pageSize, total: $total, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class _$BrowsePageCopyWith<$Res> implements $BrowsePageCopyWith<$Res> {
  factory _$BrowsePageCopyWith(_BrowsePage value, $Res Function(_BrowsePage) _then) = __$BrowsePageCopyWithImpl;
@override @useResult
$Res call({
 List<TitleCard> items, int page, int pageSize, int total, bool hasMore
});




}
/// @nodoc
class __$BrowsePageCopyWithImpl<$Res>
    implements _$BrowsePageCopyWith<$Res> {
  __$BrowsePageCopyWithImpl(this._self, this._then);

  final _BrowsePage _self;
  final $Res Function(_BrowsePage) _then;

/// Create a copy of BrowsePage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? page = null,Object? pageSize = null,Object? total = null,Object? hasMore = null,}) {
  return _then(_BrowsePage(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<TitleCard>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
