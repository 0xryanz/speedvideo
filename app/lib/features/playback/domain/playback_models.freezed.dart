// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playback_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlaybackEpisode {

 String get id; int get number; int get seasonNumber; String get name; int get runtimeMinutes;
/// Create a copy of PlaybackEpisode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaybackEpisodeCopyWith<PlaybackEpisode> get copyWith => _$PlaybackEpisodeCopyWithImpl<PlaybackEpisode>(this as PlaybackEpisode, _$identity);

  /// Serializes this PlaybackEpisode to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaybackEpisode&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.seasonNumber, seasonNumber) || other.seasonNumber == seasonNumber)&&(identical(other.name, name) || other.name == name)&&(identical(other.runtimeMinutes, runtimeMinutes) || other.runtimeMinutes == runtimeMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,number,seasonNumber,name,runtimeMinutes);

@override
String toString() {
  return 'PlaybackEpisode(id: $id, number: $number, seasonNumber: $seasonNumber, name: $name, runtimeMinutes: $runtimeMinutes)';
}


}

/// @nodoc
abstract mixin class $PlaybackEpisodeCopyWith<$Res>  {
  factory $PlaybackEpisodeCopyWith(PlaybackEpisode value, $Res Function(PlaybackEpisode) _then) = _$PlaybackEpisodeCopyWithImpl;
@useResult
$Res call({
 String id, int number, int seasonNumber, String name, int runtimeMinutes
});




}
/// @nodoc
class _$PlaybackEpisodeCopyWithImpl<$Res>
    implements $PlaybackEpisodeCopyWith<$Res> {
  _$PlaybackEpisodeCopyWithImpl(this._self, this._then);

  final PlaybackEpisode _self;
  final $Res Function(PlaybackEpisode) _then;

/// Create a copy of PlaybackEpisode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? number = null,Object? seasonNumber = null,Object? name = null,Object? runtimeMinutes = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,seasonNumber: null == seasonNumber ? _self.seasonNumber : seasonNumber // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,runtimeMinutes: null == runtimeMinutes ? _self.runtimeMinutes : runtimeMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PlaybackEpisode].
extension PlaybackEpisodePatterns on PlaybackEpisode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaybackEpisode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaybackEpisode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaybackEpisode value)  $default,){
final _that = this;
switch (_that) {
case _PlaybackEpisode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaybackEpisode value)?  $default,){
final _that = this;
switch (_that) {
case _PlaybackEpisode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int number,  int seasonNumber,  String name,  int runtimeMinutes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaybackEpisode() when $default != null:
return $default(_that.id,_that.number,_that.seasonNumber,_that.name,_that.runtimeMinutes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int number,  int seasonNumber,  String name,  int runtimeMinutes)  $default,) {final _that = this;
switch (_that) {
case _PlaybackEpisode():
return $default(_that.id,_that.number,_that.seasonNumber,_that.name,_that.runtimeMinutes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int number,  int seasonNumber,  String name,  int runtimeMinutes)?  $default,) {final _that = this;
switch (_that) {
case _PlaybackEpisode() when $default != null:
return $default(_that.id,_that.number,_that.seasonNumber,_that.name,_that.runtimeMinutes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlaybackEpisode implements PlaybackEpisode {
  const _PlaybackEpisode({required this.id, this.number = 0, this.seasonNumber = 0, required this.name, this.runtimeMinutes = 0});
  factory _PlaybackEpisode.fromJson(Map<String, dynamic> json) => _$PlaybackEpisodeFromJson(json);

@override final  String id;
@override@JsonKey() final  int number;
@override@JsonKey() final  int seasonNumber;
@override final  String name;
@override@JsonKey() final  int runtimeMinutes;

/// Create a copy of PlaybackEpisode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaybackEpisodeCopyWith<_PlaybackEpisode> get copyWith => __$PlaybackEpisodeCopyWithImpl<_PlaybackEpisode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlaybackEpisodeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaybackEpisode&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.seasonNumber, seasonNumber) || other.seasonNumber == seasonNumber)&&(identical(other.name, name) || other.name == name)&&(identical(other.runtimeMinutes, runtimeMinutes) || other.runtimeMinutes == runtimeMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,number,seasonNumber,name,runtimeMinutes);

@override
String toString() {
  return 'PlaybackEpisode(id: $id, number: $number, seasonNumber: $seasonNumber, name: $name, runtimeMinutes: $runtimeMinutes)';
}


}

/// @nodoc
abstract mixin class _$PlaybackEpisodeCopyWith<$Res> implements $PlaybackEpisodeCopyWith<$Res> {
  factory _$PlaybackEpisodeCopyWith(_PlaybackEpisode value, $Res Function(_PlaybackEpisode) _then) = __$PlaybackEpisodeCopyWithImpl;
@override @useResult
$Res call({
 String id, int number, int seasonNumber, String name, int runtimeMinutes
});




}
/// @nodoc
class __$PlaybackEpisodeCopyWithImpl<$Res>
    implements _$PlaybackEpisodeCopyWith<$Res> {
  __$PlaybackEpisodeCopyWithImpl(this._self, this._then);

  final _PlaybackEpisode _self;
  final $Res Function(_PlaybackEpisode) _then;

/// Create a copy of PlaybackEpisode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? number = null,Object? seasonNumber = null,Object? name = null,Object? runtimeMinutes = null,}) {
  return _then(_PlaybackEpisode(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,seasonNumber: null == seasonNumber ? _self.seasonNumber : seasonNumber // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,runtimeMinutes: null == runtimeMinutes ? _self.runtimeMinutes : runtimeMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$AudioTrack {

 String get language; String get label; bool get isDefault;
/// Create a copy of AudioTrack
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AudioTrackCopyWith<AudioTrack> get copyWith => _$AudioTrackCopyWithImpl<AudioTrack>(this as AudioTrack, _$identity);

  /// Serializes this AudioTrack to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AudioTrack&&(identical(other.language, language) || other.language == language)&&(identical(other.label, label) || other.label == label)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,language,label,isDefault);

@override
String toString() {
  return 'AudioTrack(language: $language, label: $label, isDefault: $isDefault)';
}


}

/// @nodoc
abstract mixin class $AudioTrackCopyWith<$Res>  {
  factory $AudioTrackCopyWith(AudioTrack value, $Res Function(AudioTrack) _then) = _$AudioTrackCopyWithImpl;
@useResult
$Res call({
 String language, String label, bool isDefault
});




}
/// @nodoc
class _$AudioTrackCopyWithImpl<$Res>
    implements $AudioTrackCopyWith<$Res> {
  _$AudioTrackCopyWithImpl(this._self, this._then);

  final AudioTrack _self;
  final $Res Function(AudioTrack) _then;

/// Create a copy of AudioTrack
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? language = null,Object? label = null,Object? isDefault = null,}) {
  return _then(_self.copyWith(
language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AudioTrack].
extension AudioTrackPatterns on AudioTrack {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AudioTrack value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AudioTrack() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AudioTrack value)  $default,){
final _that = this;
switch (_that) {
case _AudioTrack():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AudioTrack value)?  $default,){
final _that = this;
switch (_that) {
case _AudioTrack() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String language,  String label,  bool isDefault)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AudioTrack() when $default != null:
return $default(_that.language,_that.label,_that.isDefault);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String language,  String label,  bool isDefault)  $default,) {final _that = this;
switch (_that) {
case _AudioTrack():
return $default(_that.language,_that.label,_that.isDefault);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String language,  String label,  bool isDefault)?  $default,) {final _that = this;
switch (_that) {
case _AudioTrack() when $default != null:
return $default(_that.language,_that.label,_that.isDefault);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AudioTrack implements AudioTrack {
  const _AudioTrack({required this.language, required this.label, this.isDefault = false});
  factory _AudioTrack.fromJson(Map<String, dynamic> json) => _$AudioTrackFromJson(json);

@override final  String language;
@override final  String label;
@override@JsonKey() final  bool isDefault;

/// Create a copy of AudioTrack
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AudioTrackCopyWith<_AudioTrack> get copyWith => __$AudioTrackCopyWithImpl<_AudioTrack>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AudioTrackToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AudioTrack&&(identical(other.language, language) || other.language == language)&&(identical(other.label, label) || other.label == label)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,language,label,isDefault);

@override
String toString() {
  return 'AudioTrack(language: $language, label: $label, isDefault: $isDefault)';
}


}

/// @nodoc
abstract mixin class _$AudioTrackCopyWith<$Res> implements $AudioTrackCopyWith<$Res> {
  factory _$AudioTrackCopyWith(_AudioTrack value, $Res Function(_AudioTrack) _then) = __$AudioTrackCopyWithImpl;
@override @useResult
$Res call({
 String language, String label, bool isDefault
});




}
/// @nodoc
class __$AudioTrackCopyWithImpl<$Res>
    implements _$AudioTrackCopyWith<$Res> {
  __$AudioTrackCopyWithImpl(this._self, this._then);

  final _AudioTrack _self;
  final $Res Function(_AudioTrack) _then;

/// Create a copy of AudioTrack
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? language = null,Object? label = null,Object? isDefault = null,}) {
  return _then(_AudioTrack(
language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$SubtitleTrack {

 String get language; String get label; bool get isDefault;
/// Create a copy of SubtitleTrack
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubtitleTrackCopyWith<SubtitleTrack> get copyWith => _$SubtitleTrackCopyWithImpl<SubtitleTrack>(this as SubtitleTrack, _$identity);

  /// Serializes this SubtitleTrack to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubtitleTrack&&(identical(other.language, language) || other.language == language)&&(identical(other.label, label) || other.label == label)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,language,label,isDefault);

@override
String toString() {
  return 'SubtitleTrack(language: $language, label: $label, isDefault: $isDefault)';
}


}

/// @nodoc
abstract mixin class $SubtitleTrackCopyWith<$Res>  {
  factory $SubtitleTrackCopyWith(SubtitleTrack value, $Res Function(SubtitleTrack) _then) = _$SubtitleTrackCopyWithImpl;
@useResult
$Res call({
 String language, String label, bool isDefault
});




}
/// @nodoc
class _$SubtitleTrackCopyWithImpl<$Res>
    implements $SubtitleTrackCopyWith<$Res> {
  _$SubtitleTrackCopyWithImpl(this._self, this._then);

  final SubtitleTrack _self;
  final $Res Function(SubtitleTrack) _then;

/// Create a copy of SubtitleTrack
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? language = null,Object? label = null,Object? isDefault = null,}) {
  return _then(_self.copyWith(
language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SubtitleTrack].
extension SubtitleTrackPatterns on SubtitleTrack {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubtitleTrack value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubtitleTrack() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubtitleTrack value)  $default,){
final _that = this;
switch (_that) {
case _SubtitleTrack():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubtitleTrack value)?  $default,){
final _that = this;
switch (_that) {
case _SubtitleTrack() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String language,  String label,  bool isDefault)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubtitleTrack() when $default != null:
return $default(_that.language,_that.label,_that.isDefault);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String language,  String label,  bool isDefault)  $default,) {final _that = this;
switch (_that) {
case _SubtitleTrack():
return $default(_that.language,_that.label,_that.isDefault);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String language,  String label,  bool isDefault)?  $default,) {final _that = this;
switch (_that) {
case _SubtitleTrack() when $default != null:
return $default(_that.language,_that.label,_that.isDefault);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubtitleTrack implements SubtitleTrack {
  const _SubtitleTrack({required this.language, required this.label, this.isDefault = false});
  factory _SubtitleTrack.fromJson(Map<String, dynamic> json) => _$SubtitleTrackFromJson(json);

@override final  String language;
@override final  String label;
@override@JsonKey() final  bool isDefault;

/// Create a copy of SubtitleTrack
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubtitleTrackCopyWith<_SubtitleTrack> get copyWith => __$SubtitleTrackCopyWithImpl<_SubtitleTrack>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubtitleTrackToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubtitleTrack&&(identical(other.language, language) || other.language == language)&&(identical(other.label, label) || other.label == label)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,language,label,isDefault);

@override
String toString() {
  return 'SubtitleTrack(language: $language, label: $label, isDefault: $isDefault)';
}


}

/// @nodoc
abstract mixin class _$SubtitleTrackCopyWith<$Res> implements $SubtitleTrackCopyWith<$Res> {
  factory _$SubtitleTrackCopyWith(_SubtitleTrack value, $Res Function(_SubtitleTrack) _then) = __$SubtitleTrackCopyWithImpl;
@override @useResult
$Res call({
 String language, String label, bool isDefault
});




}
/// @nodoc
class __$SubtitleTrackCopyWithImpl<$Res>
    implements _$SubtitleTrackCopyWith<$Res> {
  __$SubtitleTrackCopyWithImpl(this._self, this._then);

  final _SubtitleTrack _self;
  final $Res Function(_SubtitleTrack) _then;

/// Create a copy of SubtitleTrack
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? language = null,Object? label = null,Object? isDefault = null,}) {
  return _then(_SubtitleTrack(
language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$PlaybackInfo {

 String get manifestUrl; DateTime? get expiresAt; String get titleId; String get titleName; PlaybackEpisode? get episode; String get posterPath; String get backdropPath; int get resumePositionSeconds; int get durationSeconds; List<AudioTrack> get audioTracks; List<SubtitleTrack> get subtitleTracks;
/// Create a copy of PlaybackInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaybackInfoCopyWith<PlaybackInfo> get copyWith => _$PlaybackInfoCopyWithImpl<PlaybackInfo>(this as PlaybackInfo, _$identity);

  /// Serializes this PlaybackInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaybackInfo&&(identical(other.manifestUrl, manifestUrl) || other.manifestUrl == manifestUrl)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.titleId, titleId) || other.titleId == titleId)&&(identical(other.titleName, titleName) || other.titleName == titleName)&&(identical(other.episode, episode) || other.episode == episode)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.backdropPath, backdropPath) || other.backdropPath == backdropPath)&&(identical(other.resumePositionSeconds, resumePositionSeconds) || other.resumePositionSeconds == resumePositionSeconds)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&const DeepCollectionEquality().equals(other.audioTracks, audioTracks)&&const DeepCollectionEquality().equals(other.subtitleTracks, subtitleTracks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,manifestUrl,expiresAt,titleId,titleName,episode,posterPath,backdropPath,resumePositionSeconds,durationSeconds,const DeepCollectionEquality().hash(audioTracks),const DeepCollectionEquality().hash(subtitleTracks));

@override
String toString() {
  return 'PlaybackInfo(manifestUrl: $manifestUrl, expiresAt: $expiresAt, titleId: $titleId, titleName: $titleName, episode: $episode, posterPath: $posterPath, backdropPath: $backdropPath, resumePositionSeconds: $resumePositionSeconds, durationSeconds: $durationSeconds, audioTracks: $audioTracks, subtitleTracks: $subtitleTracks)';
}


}

/// @nodoc
abstract mixin class $PlaybackInfoCopyWith<$Res>  {
  factory $PlaybackInfoCopyWith(PlaybackInfo value, $Res Function(PlaybackInfo) _then) = _$PlaybackInfoCopyWithImpl;
@useResult
$Res call({
 String manifestUrl, DateTime? expiresAt, String titleId, String titleName, PlaybackEpisode? episode, String posterPath, String backdropPath, int resumePositionSeconds, int durationSeconds, List<AudioTrack> audioTracks, List<SubtitleTrack> subtitleTracks
});


$PlaybackEpisodeCopyWith<$Res>? get episode;

}
/// @nodoc
class _$PlaybackInfoCopyWithImpl<$Res>
    implements $PlaybackInfoCopyWith<$Res> {
  _$PlaybackInfoCopyWithImpl(this._self, this._then);

  final PlaybackInfo _self;
  final $Res Function(PlaybackInfo) _then;

/// Create a copy of PlaybackInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? manifestUrl = null,Object? expiresAt = freezed,Object? titleId = null,Object? titleName = null,Object? episode = freezed,Object? posterPath = null,Object? backdropPath = null,Object? resumePositionSeconds = null,Object? durationSeconds = null,Object? audioTracks = null,Object? subtitleTracks = null,}) {
  return _then(_self.copyWith(
manifestUrl: null == manifestUrl ? _self.manifestUrl : manifestUrl // ignore: cast_nullable_to_non_nullable
as String,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,titleId: null == titleId ? _self.titleId : titleId // ignore: cast_nullable_to_non_nullable
as String,titleName: null == titleName ? _self.titleName : titleName // ignore: cast_nullable_to_non_nullable
as String,episode: freezed == episode ? _self.episode : episode // ignore: cast_nullable_to_non_nullable
as PlaybackEpisode?,posterPath: null == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String,backdropPath: null == backdropPath ? _self.backdropPath : backdropPath // ignore: cast_nullable_to_non_nullable
as String,resumePositionSeconds: null == resumePositionSeconds ? _self.resumePositionSeconds : resumePositionSeconds // ignore: cast_nullable_to_non_nullable
as int,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,audioTracks: null == audioTracks ? _self.audioTracks : audioTracks // ignore: cast_nullable_to_non_nullable
as List<AudioTrack>,subtitleTracks: null == subtitleTracks ? _self.subtitleTracks : subtitleTracks // ignore: cast_nullable_to_non_nullable
as List<SubtitleTrack>,
  ));
}
/// Create a copy of PlaybackInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaybackEpisodeCopyWith<$Res>? get episode {
    if (_self.episode == null) {
    return null;
  }

  return $PlaybackEpisodeCopyWith<$Res>(_self.episode!, (value) {
    return _then(_self.copyWith(episode: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlaybackInfo].
extension PlaybackInfoPatterns on PlaybackInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaybackInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaybackInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaybackInfo value)  $default,){
final _that = this;
switch (_that) {
case _PlaybackInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaybackInfo value)?  $default,){
final _that = this;
switch (_that) {
case _PlaybackInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String manifestUrl,  DateTime? expiresAt,  String titleId,  String titleName,  PlaybackEpisode? episode,  String posterPath,  String backdropPath,  int resumePositionSeconds,  int durationSeconds,  List<AudioTrack> audioTracks,  List<SubtitleTrack> subtitleTracks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaybackInfo() when $default != null:
return $default(_that.manifestUrl,_that.expiresAt,_that.titleId,_that.titleName,_that.episode,_that.posterPath,_that.backdropPath,_that.resumePositionSeconds,_that.durationSeconds,_that.audioTracks,_that.subtitleTracks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String manifestUrl,  DateTime? expiresAt,  String titleId,  String titleName,  PlaybackEpisode? episode,  String posterPath,  String backdropPath,  int resumePositionSeconds,  int durationSeconds,  List<AudioTrack> audioTracks,  List<SubtitleTrack> subtitleTracks)  $default,) {final _that = this;
switch (_that) {
case _PlaybackInfo():
return $default(_that.manifestUrl,_that.expiresAt,_that.titleId,_that.titleName,_that.episode,_that.posterPath,_that.backdropPath,_that.resumePositionSeconds,_that.durationSeconds,_that.audioTracks,_that.subtitleTracks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String manifestUrl,  DateTime? expiresAt,  String titleId,  String titleName,  PlaybackEpisode? episode,  String posterPath,  String backdropPath,  int resumePositionSeconds,  int durationSeconds,  List<AudioTrack> audioTracks,  List<SubtitleTrack> subtitleTracks)?  $default,) {final _that = this;
switch (_that) {
case _PlaybackInfo() when $default != null:
return $default(_that.manifestUrl,_that.expiresAt,_that.titleId,_that.titleName,_that.episode,_that.posterPath,_that.backdropPath,_that.resumePositionSeconds,_that.durationSeconds,_that.audioTracks,_that.subtitleTracks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlaybackInfo implements PlaybackInfo {
  const _PlaybackInfo({required this.manifestUrl, this.expiresAt, required this.titleId, this.titleName = '', this.episode, this.posterPath = '', this.backdropPath = '', this.resumePositionSeconds = 0, this.durationSeconds = 0, final  List<AudioTrack> audioTracks = const <AudioTrack>[], final  List<SubtitleTrack> subtitleTracks = const <SubtitleTrack>[]}): _audioTracks = audioTracks,_subtitleTracks = subtitleTracks;
  factory _PlaybackInfo.fromJson(Map<String, dynamic> json) => _$PlaybackInfoFromJson(json);

@override final  String manifestUrl;
@override final  DateTime? expiresAt;
@override final  String titleId;
@override@JsonKey() final  String titleName;
@override final  PlaybackEpisode? episode;
@override@JsonKey() final  String posterPath;
@override@JsonKey() final  String backdropPath;
@override@JsonKey() final  int resumePositionSeconds;
@override@JsonKey() final  int durationSeconds;
 final  List<AudioTrack> _audioTracks;
@override@JsonKey() List<AudioTrack> get audioTracks {
  if (_audioTracks is EqualUnmodifiableListView) return _audioTracks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_audioTracks);
}

 final  List<SubtitleTrack> _subtitleTracks;
@override@JsonKey() List<SubtitleTrack> get subtitleTracks {
  if (_subtitleTracks is EqualUnmodifiableListView) return _subtitleTracks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_subtitleTracks);
}


/// Create a copy of PlaybackInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaybackInfoCopyWith<_PlaybackInfo> get copyWith => __$PlaybackInfoCopyWithImpl<_PlaybackInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlaybackInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaybackInfo&&(identical(other.manifestUrl, manifestUrl) || other.manifestUrl == manifestUrl)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.titleId, titleId) || other.titleId == titleId)&&(identical(other.titleName, titleName) || other.titleName == titleName)&&(identical(other.episode, episode) || other.episode == episode)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.backdropPath, backdropPath) || other.backdropPath == backdropPath)&&(identical(other.resumePositionSeconds, resumePositionSeconds) || other.resumePositionSeconds == resumePositionSeconds)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&const DeepCollectionEquality().equals(other._audioTracks, _audioTracks)&&const DeepCollectionEquality().equals(other._subtitleTracks, _subtitleTracks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,manifestUrl,expiresAt,titleId,titleName,episode,posterPath,backdropPath,resumePositionSeconds,durationSeconds,const DeepCollectionEquality().hash(_audioTracks),const DeepCollectionEquality().hash(_subtitleTracks));

@override
String toString() {
  return 'PlaybackInfo(manifestUrl: $manifestUrl, expiresAt: $expiresAt, titleId: $titleId, titleName: $titleName, episode: $episode, posterPath: $posterPath, backdropPath: $backdropPath, resumePositionSeconds: $resumePositionSeconds, durationSeconds: $durationSeconds, audioTracks: $audioTracks, subtitleTracks: $subtitleTracks)';
}


}

/// @nodoc
abstract mixin class _$PlaybackInfoCopyWith<$Res> implements $PlaybackInfoCopyWith<$Res> {
  factory _$PlaybackInfoCopyWith(_PlaybackInfo value, $Res Function(_PlaybackInfo) _then) = __$PlaybackInfoCopyWithImpl;
@override @useResult
$Res call({
 String manifestUrl, DateTime? expiresAt, String titleId, String titleName, PlaybackEpisode? episode, String posterPath, String backdropPath, int resumePositionSeconds, int durationSeconds, List<AudioTrack> audioTracks, List<SubtitleTrack> subtitleTracks
});


@override $PlaybackEpisodeCopyWith<$Res>? get episode;

}
/// @nodoc
class __$PlaybackInfoCopyWithImpl<$Res>
    implements _$PlaybackInfoCopyWith<$Res> {
  __$PlaybackInfoCopyWithImpl(this._self, this._then);

  final _PlaybackInfo _self;
  final $Res Function(_PlaybackInfo) _then;

/// Create a copy of PlaybackInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? manifestUrl = null,Object? expiresAt = freezed,Object? titleId = null,Object? titleName = null,Object? episode = freezed,Object? posterPath = null,Object? backdropPath = null,Object? resumePositionSeconds = null,Object? durationSeconds = null,Object? audioTracks = null,Object? subtitleTracks = null,}) {
  return _then(_PlaybackInfo(
manifestUrl: null == manifestUrl ? _self.manifestUrl : manifestUrl // ignore: cast_nullable_to_non_nullable
as String,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,titleId: null == titleId ? _self.titleId : titleId // ignore: cast_nullable_to_non_nullable
as String,titleName: null == titleName ? _self.titleName : titleName // ignore: cast_nullable_to_non_nullable
as String,episode: freezed == episode ? _self.episode : episode // ignore: cast_nullable_to_non_nullable
as PlaybackEpisode?,posterPath: null == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String,backdropPath: null == backdropPath ? _self.backdropPath : backdropPath // ignore: cast_nullable_to_non_nullable
as String,resumePositionSeconds: null == resumePositionSeconds ? _self.resumePositionSeconds : resumePositionSeconds // ignore: cast_nullable_to_non_nullable
as int,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,audioTracks: null == audioTracks ? _self._audioTracks : audioTracks // ignore: cast_nullable_to_non_nullable
as List<AudioTrack>,subtitleTracks: null == subtitleTracks ? _self._subtitleTracks : subtitleTracks // ignore: cast_nullable_to_non_nullable
as List<SubtitleTrack>,
  ));
}

/// Create a copy of PlaybackInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaybackEpisodeCopyWith<$Res>? get episode {
    if (_self.episode == null) {
    return null;
  }

  return $PlaybackEpisodeCopyWith<$Res>(_self.episode!, (value) {
    return _then(_self.copyWith(episode: value));
  });
}
}

// dart format on
