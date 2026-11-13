// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HomeRow {

 String get id; String get title; String get kind; bool get ranked; List<TitleCard> get items;
/// Create a copy of HomeRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeRowCopyWith<HomeRow> get copyWith => _$HomeRowCopyWithImpl<HomeRow>(this as HomeRow, _$identity);

  /// Serializes this HomeRow to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeRow&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.ranked, ranked) || other.ranked == ranked)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,kind,ranked,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'HomeRow(id: $id, title: $title, kind: $kind, ranked: $ranked, items: $items)';
}


}

/// @nodoc
abstract mixin class $HomeRowCopyWith<$Res>  {
  factory $HomeRowCopyWith(HomeRow value, $Res Function(HomeRow) _then) = _$HomeRowCopyWithImpl;
@useResult
$Res call({
 String id, String title, String kind, bool ranked, List<TitleCard> items
});




}
/// @nodoc
class _$HomeRowCopyWithImpl<$Res>
    implements $HomeRowCopyWith<$Res> {
  _$HomeRowCopyWithImpl(this._self, this._then);

  final HomeRow _self;
  final $Res Function(HomeRow) _then;

/// Create a copy of HomeRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? kind = null,Object? ranked = null,Object? items = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,ranked: null == ranked ? _self.ranked : ranked // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<TitleCard>,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeRow].
extension HomeRowPatterns on HomeRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeRow value)  $default,){
final _that = this;
switch (_that) {
case _HomeRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeRow value)?  $default,){
final _that = this;
switch (_that) {
case _HomeRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String kind,  bool ranked,  List<TitleCard> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeRow() when $default != null:
return $default(_that.id,_that.title,_that.kind,_that.ranked,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String kind,  bool ranked,  List<TitleCard> items)  $default,) {final _that = this;
switch (_that) {
case _HomeRow():
return $default(_that.id,_that.title,_that.kind,_that.ranked,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String kind,  bool ranked,  List<TitleCard> items)?  $default,) {final _that = this;
switch (_that) {
case _HomeRow() when $default != null:
return $default(_that.id,_that.title,_that.kind,_that.ranked,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HomeRow implements HomeRow {
  const _HomeRow({required this.id, required this.title, this.kind = 'standard', this.ranked = false, final  List<TitleCard> items = const <TitleCard>[]}): _items = items;
  factory _HomeRow.fromJson(Map<String, dynamic> json) => _$HomeRowFromJson(json);

@override final  String id;
@override final  String title;
@override@JsonKey() final  String kind;
@override@JsonKey() final  bool ranked;
 final  List<TitleCard> _items;
@override@JsonKey() List<TitleCard> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of HomeRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeRowCopyWith<_HomeRow> get copyWith => __$HomeRowCopyWithImpl<_HomeRow>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HomeRowToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeRow&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.ranked, ranked) || other.ranked == ranked)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,kind,ranked,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'HomeRow(id: $id, title: $title, kind: $kind, ranked: $ranked, items: $items)';
}


}

/// @nodoc
abstract mixin class _$HomeRowCopyWith<$Res> implements $HomeRowCopyWith<$Res> {
  factory _$HomeRowCopyWith(_HomeRow value, $Res Function(_HomeRow) _then) = __$HomeRowCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String kind, bool ranked, List<TitleCard> items
});




}
/// @nodoc
class __$HomeRowCopyWithImpl<$Res>
    implements _$HomeRowCopyWith<$Res> {
  __$HomeRowCopyWithImpl(this._self, this._then);

  final _HomeRow _self;
  final $Res Function(_HomeRow) _then;

/// Create a copy of HomeRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? kind = null,Object? ranked = null,Object? items = null,}) {
  return _then(_HomeRow(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,ranked: null == ranked ? _self.ranked : ranked // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<TitleCard>,
  ));
}


}


/// @nodoc
mixin _$HomeFeed {

 TitleCard? get billboard; List<HomeRow> get rows;
/// Create a copy of HomeFeed
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeFeedCopyWith<HomeFeed> get copyWith => _$HomeFeedCopyWithImpl<HomeFeed>(this as HomeFeed, _$identity);

  /// Serializes this HomeFeed to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeFeed&&(identical(other.billboard, billboard) || other.billboard == billboard)&&const DeepCollectionEquality().equals(other.rows, rows));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,billboard,const DeepCollectionEquality().hash(rows));

@override
String toString() {
  return 'HomeFeed(billboard: $billboard, rows: $rows)';
}


}

/// @nodoc
abstract mixin class $HomeFeedCopyWith<$Res>  {
  factory $HomeFeedCopyWith(HomeFeed value, $Res Function(HomeFeed) _then) = _$HomeFeedCopyWithImpl;
@useResult
$Res call({
 TitleCard? billboard, List<HomeRow> rows
});


$TitleCardCopyWith<$Res>? get billboard;

}
/// @nodoc
class _$HomeFeedCopyWithImpl<$Res>
    implements $HomeFeedCopyWith<$Res> {
  _$HomeFeedCopyWithImpl(this._self, this._then);

  final HomeFeed _self;
  final $Res Function(HomeFeed) _then;

/// Create a copy of HomeFeed
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? billboard = freezed,Object? rows = null,}) {
  return _then(_self.copyWith(
billboard: freezed == billboard ? _self.billboard : billboard // ignore: cast_nullable_to_non_nullable
as TitleCard?,rows: null == rows ? _self.rows : rows // ignore: cast_nullable_to_non_nullable
as List<HomeRow>,
  ));
}
/// Create a copy of HomeFeed
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TitleCardCopyWith<$Res>? get billboard {
    if (_self.billboard == null) {
    return null;
  }

  return $TitleCardCopyWith<$Res>(_self.billboard!, (value) {
    return _then(_self.copyWith(billboard: value));
  });
}
}


/// Adds pattern-matching-related methods to [HomeFeed].
extension HomeFeedPatterns on HomeFeed {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeFeed value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeFeed() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeFeed value)  $default,){
final _that = this;
switch (_that) {
case _HomeFeed():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeFeed value)?  $default,){
final _that = this;
switch (_that) {
case _HomeFeed() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TitleCard? billboard,  List<HomeRow> rows)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeFeed() when $default != null:
return $default(_that.billboard,_that.rows);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TitleCard? billboard,  List<HomeRow> rows)  $default,) {final _that = this;
switch (_that) {
case _HomeFeed():
return $default(_that.billboard,_that.rows);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TitleCard? billboard,  List<HomeRow> rows)?  $default,) {final _that = this;
switch (_that) {
case _HomeFeed() when $default != null:
return $default(_that.billboard,_that.rows);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HomeFeed implements HomeFeed {
  const _HomeFeed({this.billboard, final  List<HomeRow> rows = const <HomeRow>[]}): _rows = rows;
  factory _HomeFeed.fromJson(Map<String, dynamic> json) => _$HomeFeedFromJson(json);

@override final  TitleCard? billboard;
 final  List<HomeRow> _rows;
@override@JsonKey() List<HomeRow> get rows {
  if (_rows is EqualUnmodifiableListView) return _rows;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rows);
}


/// Create a copy of HomeFeed
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeFeedCopyWith<_HomeFeed> get copyWith => __$HomeFeedCopyWithImpl<_HomeFeed>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HomeFeedToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeFeed&&(identical(other.billboard, billboard) || other.billboard == billboard)&&const DeepCollectionEquality().equals(other._rows, _rows));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,billboard,const DeepCollectionEquality().hash(_rows));

@override
String toString() {
  return 'HomeFeed(billboard: $billboard, rows: $rows)';
}


}

/// @nodoc
abstract mixin class _$HomeFeedCopyWith<$Res> implements $HomeFeedCopyWith<$Res> {
  factory _$HomeFeedCopyWith(_HomeFeed value, $Res Function(_HomeFeed) _then) = __$HomeFeedCopyWithImpl;
@override @useResult
$Res call({
 TitleCard? billboard, List<HomeRow> rows
});


@override $TitleCardCopyWith<$Res>? get billboard;

}
/// @nodoc
class __$HomeFeedCopyWithImpl<$Res>
    implements _$HomeFeedCopyWith<$Res> {
  __$HomeFeedCopyWithImpl(this._self, this._then);

  final _HomeFeed _self;
  final $Res Function(_HomeFeed) _then;

/// Create a copy of HomeFeed
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? billboard = freezed,Object? rows = null,}) {
  return _then(_HomeFeed(
billboard: freezed == billboard ? _self.billboard : billboard // ignore: cast_nullable_to_non_nullable
as TitleCard?,rows: null == rows ? _self._rows : rows // ignore: cast_nullable_to_non_nullable
as List<HomeRow>,
  ));
}

/// Create a copy of HomeFeed
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TitleCardCopyWith<$Res>? get billboard {
    if (_self.billboard == null) {
    return null;
  }

  return $TitleCardCopyWith<$Res>(_self.billboard!, (value) {
    return _then(_self.copyWith(billboard: value));
  });
}
}

// dart format on
