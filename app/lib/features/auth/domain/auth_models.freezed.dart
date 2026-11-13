// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$User {

 String get id; String get email; String get displayName; String get plan; String get role; DateTime? get createdAt;
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCopyWith<User> get copyWith => _$UserCopyWithImpl<User>(this as User, _$identity);

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is User&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.role, role) || other.role == role)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,displayName,plan,role,createdAt);

@override
String toString() {
  return 'User(id: $id, email: $email, displayName: $displayName, plan: $plan, role: $role, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $UserCopyWith<$Res>  {
  factory $UserCopyWith(User value, $Res Function(User) _then) = _$UserCopyWithImpl;
@useResult
$Res call({
 String id, String email, String displayName, String plan, String role, DateTime? createdAt
});




}
/// @nodoc
class _$UserCopyWithImpl<$Res>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._self, this._then);

  final User _self;
  final $Res Function(User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? displayName = null,Object? plan = null,Object? role = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [User].
extension UserPatterns on User {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _User value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _User value)  $default,){
final _that = this;
switch (_that) {
case _User():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _User value)?  $default,){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String email,  String displayName,  String plan,  String role,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.email,_that.displayName,_that.plan,_that.role,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String email,  String displayName,  String plan,  String role,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _User():
return $default(_that.id,_that.email,_that.displayName,_that.plan,_that.role,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String email,  String displayName,  String plan,  String role,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.email,_that.displayName,_that.plan,_that.role,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _User implements User {
  const _User({required this.id, required this.email, this.displayName = '', this.plan = 'standard', this.role = 'member', this.createdAt});
  factory _User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

@override final  String id;
@override final  String email;
@override@JsonKey() final  String displayName;
@override@JsonKey() final  String plan;
@override@JsonKey() final  String role;
@override final  DateTime? createdAt;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserCopyWith<_User> get copyWith => __$UserCopyWithImpl<_User>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _User&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.role, role) || other.role == role)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,displayName,plan,role,createdAt);

@override
String toString() {
  return 'User(id: $id, email: $email, displayName: $displayName, plan: $plan, role: $role, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$UserCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$UserCopyWith(_User value, $Res Function(_User) _then) = __$UserCopyWithImpl;
@override @useResult
$Res call({
 String id, String email, String displayName, String plan, String role, DateTime? createdAt
});




}
/// @nodoc
class __$UserCopyWithImpl<$Res>
    implements _$UserCopyWith<$Res> {
  __$UserCopyWithImpl(this._self, this._then);

  final _User _self;
  final $Res Function(_User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? displayName = null,Object? plan = null,Object? role = null,Object? createdAt = freezed,}) {
  return _then(_User(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$Profile {

 String get id; String get name; String get avatarColor; bool get isKids; String get language; bool get autoplayNext; bool get autoplayPreviews; String get maturityRating; DateTime? get createdAt;
/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileCopyWith<Profile> get copyWith => _$ProfileCopyWithImpl<Profile>(this as Profile, _$identity);

  /// Serializes this Profile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Profile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarColor, avatarColor) || other.avatarColor == avatarColor)&&(identical(other.isKids, isKids) || other.isKids == isKids)&&(identical(other.language, language) || other.language == language)&&(identical(other.autoplayNext, autoplayNext) || other.autoplayNext == autoplayNext)&&(identical(other.autoplayPreviews, autoplayPreviews) || other.autoplayPreviews == autoplayPreviews)&&(identical(other.maturityRating, maturityRating) || other.maturityRating == maturityRating)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,avatarColor,isKids,language,autoplayNext,autoplayPreviews,maturityRating,createdAt);

@override
String toString() {
  return 'Profile(id: $id, name: $name, avatarColor: $avatarColor, isKids: $isKids, language: $language, autoplayNext: $autoplayNext, autoplayPreviews: $autoplayPreviews, maturityRating: $maturityRating, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ProfileCopyWith<$Res>  {
  factory $ProfileCopyWith(Profile value, $Res Function(Profile) _then) = _$ProfileCopyWithImpl;
@useResult
$Res call({
 String id, String name, String avatarColor, bool isKids, String language, bool autoplayNext, bool autoplayPreviews, String maturityRating, DateTime? createdAt
});




}
/// @nodoc
class _$ProfileCopyWithImpl<$Res>
    implements $ProfileCopyWith<$Res> {
  _$ProfileCopyWithImpl(this._self, this._then);

  final Profile _self;
  final $Res Function(Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? avatarColor = null,Object? isKids = null,Object? language = null,Object? autoplayNext = null,Object? autoplayPreviews = null,Object? maturityRating = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarColor: null == avatarColor ? _self.avatarColor : avatarColor // ignore: cast_nullable_to_non_nullable
as String,isKids: null == isKids ? _self.isKids : isKids // ignore: cast_nullable_to_non_nullable
as bool,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,autoplayNext: null == autoplayNext ? _self.autoplayNext : autoplayNext // ignore: cast_nullable_to_non_nullable
as bool,autoplayPreviews: null == autoplayPreviews ? _self.autoplayPreviews : autoplayPreviews // ignore: cast_nullable_to_non_nullable
as bool,maturityRating: null == maturityRating ? _self.maturityRating : maturityRating // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Profile].
extension ProfilePatterns on Profile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Profile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Profile value)  $default,){
final _that = this;
switch (_that) {
case _Profile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Profile value)?  $default,){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String avatarColor,  bool isKids,  String language,  bool autoplayNext,  bool autoplayPreviews,  String maturityRating,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.name,_that.avatarColor,_that.isKids,_that.language,_that.autoplayNext,_that.autoplayPreviews,_that.maturityRating,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String avatarColor,  bool isKids,  String language,  bool autoplayNext,  bool autoplayPreviews,  String maturityRating,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _Profile():
return $default(_that.id,_that.name,_that.avatarColor,_that.isKids,_that.language,_that.autoplayNext,_that.autoplayPreviews,_that.maturityRating,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String avatarColor,  bool isKids,  String language,  bool autoplayNext,  bool autoplayPreviews,  String maturityRating,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.name,_that.avatarColor,_that.isKids,_that.language,_that.autoplayNext,_that.autoplayPreviews,_that.maturityRating,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Profile implements Profile {
  const _Profile({required this.id, required this.name, this.avatarColor = '#E50914', this.isKids = false, this.language = 'en', this.autoplayNext = true, this.autoplayPreviews = true, this.maturityRating = '18+', this.createdAt});
  factory _Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey() final  String avatarColor;
@override@JsonKey() final  bool isKids;
@override@JsonKey() final  String language;
@override@JsonKey() final  bool autoplayNext;
@override@JsonKey() final  bool autoplayPreviews;
@override@JsonKey() final  String maturityRating;
@override final  DateTime? createdAt;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileCopyWith<_Profile> get copyWith => __$ProfileCopyWithImpl<_Profile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Profile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarColor, avatarColor) || other.avatarColor == avatarColor)&&(identical(other.isKids, isKids) || other.isKids == isKids)&&(identical(other.language, language) || other.language == language)&&(identical(other.autoplayNext, autoplayNext) || other.autoplayNext == autoplayNext)&&(identical(other.autoplayPreviews, autoplayPreviews) || other.autoplayPreviews == autoplayPreviews)&&(identical(other.maturityRating, maturityRating) || other.maturityRating == maturityRating)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,avatarColor,isKids,language,autoplayNext,autoplayPreviews,maturityRating,createdAt);

@override
String toString() {
  return 'Profile(id: $id, name: $name, avatarColor: $avatarColor, isKids: $isKids, language: $language, autoplayNext: $autoplayNext, autoplayPreviews: $autoplayPreviews, maturityRating: $maturityRating, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ProfileCopyWith<$Res> implements $ProfileCopyWith<$Res> {
  factory _$ProfileCopyWith(_Profile value, $Res Function(_Profile) _then) = __$ProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String avatarColor, bool isKids, String language, bool autoplayNext, bool autoplayPreviews, String maturityRating, DateTime? createdAt
});




}
/// @nodoc
class __$ProfileCopyWithImpl<$Res>
    implements _$ProfileCopyWith<$Res> {
  __$ProfileCopyWithImpl(this._self, this._then);

  final _Profile _self;
  final $Res Function(_Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? avatarColor = null,Object? isKids = null,Object? language = null,Object? autoplayNext = null,Object? autoplayPreviews = null,Object? maturityRating = null,Object? createdAt = freezed,}) {
  return _then(_Profile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarColor: null == avatarColor ? _self.avatarColor : avatarColor // ignore: cast_nullable_to_non_nullable
as String,isKids: null == isKids ? _self.isKids : isKids // ignore: cast_nullable_to_non_nullable
as bool,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,autoplayNext: null == autoplayNext ? _self.autoplayNext : autoplayNext // ignore: cast_nullable_to_non_nullable
as bool,autoplayPreviews: null == autoplayPreviews ? _self.autoplayPreviews : autoplayPreviews // ignore: cast_nullable_to_non_nullable
as bool,maturityRating: null == maturityRating ? _self.maturityRating : maturityRating // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$AuthSession {

 String get accessToken; String get refreshToken; String get tokenType; int get expiresIn; DateTime? get expiresAt; User get user; List<Profile> get profiles; String? get activeProfileId;
/// Create a copy of AuthSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthSessionCopyWith<AuthSession> get copyWith => _$AuthSessionCopyWithImpl<AuthSession>(this as AuthSession, _$identity);

  /// Serializes this AuthSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthSession&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.tokenType, tokenType) || other.tokenType == tokenType)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.user, user) || other.user == user)&&const DeepCollectionEquality().equals(other.profiles, profiles)&&(identical(other.activeProfileId, activeProfileId) || other.activeProfileId == activeProfileId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accessToken,refreshToken,tokenType,expiresIn,expiresAt,user,const DeepCollectionEquality().hash(profiles),activeProfileId);

@override
String toString() {
  return 'AuthSession(accessToken: $accessToken, refreshToken: $refreshToken, tokenType: $tokenType, expiresIn: $expiresIn, expiresAt: $expiresAt, user: $user, profiles: $profiles, activeProfileId: $activeProfileId)';
}


}

/// @nodoc
abstract mixin class $AuthSessionCopyWith<$Res>  {
  factory $AuthSessionCopyWith(AuthSession value, $Res Function(AuthSession) _then) = _$AuthSessionCopyWithImpl;
@useResult
$Res call({
 String accessToken, String refreshToken, String tokenType, int expiresIn, DateTime? expiresAt, User user, List<Profile> profiles, String? activeProfileId
});


$UserCopyWith<$Res> get user;

}
/// @nodoc
class _$AuthSessionCopyWithImpl<$Res>
    implements $AuthSessionCopyWith<$Res> {
  _$AuthSessionCopyWithImpl(this._self, this._then);

  final AuthSession _self;
  final $Res Function(AuthSession) _then;

/// Create a copy of AuthSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accessToken = null,Object? refreshToken = null,Object? tokenType = null,Object? expiresIn = null,Object? expiresAt = freezed,Object? user = null,Object? profiles = null,Object? activeProfileId = freezed,}) {
  return _then(_self.copyWith(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,tokenType: null == tokenType ? _self.tokenType : tokenType // ignore: cast_nullable_to_non_nullable
as String,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,profiles: null == profiles ? _self.profiles : profiles // ignore: cast_nullable_to_non_nullable
as List<Profile>,activeProfileId: freezed == activeProfileId ? _self.activeProfileId : activeProfileId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of AuthSession
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get user {
  
  return $UserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [AuthSession].
extension AuthSessionPatterns on AuthSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthSession value)  $default,){
final _that = this;
switch (_that) {
case _AuthSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthSession value)?  $default,){
final _that = this;
switch (_that) {
case _AuthSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String accessToken,  String refreshToken,  String tokenType,  int expiresIn,  DateTime? expiresAt,  User user,  List<Profile> profiles,  String? activeProfileId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthSession() when $default != null:
return $default(_that.accessToken,_that.refreshToken,_that.tokenType,_that.expiresIn,_that.expiresAt,_that.user,_that.profiles,_that.activeProfileId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String accessToken,  String refreshToken,  String tokenType,  int expiresIn,  DateTime? expiresAt,  User user,  List<Profile> profiles,  String? activeProfileId)  $default,) {final _that = this;
switch (_that) {
case _AuthSession():
return $default(_that.accessToken,_that.refreshToken,_that.tokenType,_that.expiresIn,_that.expiresAt,_that.user,_that.profiles,_that.activeProfileId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String accessToken,  String refreshToken,  String tokenType,  int expiresIn,  DateTime? expiresAt,  User user,  List<Profile> profiles,  String? activeProfileId)?  $default,) {final _that = this;
switch (_that) {
case _AuthSession() when $default != null:
return $default(_that.accessToken,_that.refreshToken,_that.tokenType,_that.expiresIn,_that.expiresAt,_that.user,_that.profiles,_that.activeProfileId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthSession implements AuthSession {
  const _AuthSession({required this.accessToken, required this.refreshToken, this.tokenType = 'Bearer', this.expiresIn = 0, this.expiresAt, required this.user, final  List<Profile> profiles = const <Profile>[], this.activeProfileId}): _profiles = profiles;
  factory _AuthSession.fromJson(Map<String, dynamic> json) => _$AuthSessionFromJson(json);

@override final  String accessToken;
@override final  String refreshToken;
@override@JsonKey() final  String tokenType;
@override@JsonKey() final  int expiresIn;
@override final  DateTime? expiresAt;
@override final  User user;
 final  List<Profile> _profiles;
@override@JsonKey() List<Profile> get profiles {
  if (_profiles is EqualUnmodifiableListView) return _profiles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_profiles);
}

@override final  String? activeProfileId;

/// Create a copy of AuthSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthSessionCopyWith<_AuthSession> get copyWith => __$AuthSessionCopyWithImpl<_AuthSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthSessionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthSession&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.tokenType, tokenType) || other.tokenType == tokenType)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.user, user) || other.user == user)&&const DeepCollectionEquality().equals(other._profiles, _profiles)&&(identical(other.activeProfileId, activeProfileId) || other.activeProfileId == activeProfileId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accessToken,refreshToken,tokenType,expiresIn,expiresAt,user,const DeepCollectionEquality().hash(_profiles),activeProfileId);

@override
String toString() {
  return 'AuthSession(accessToken: $accessToken, refreshToken: $refreshToken, tokenType: $tokenType, expiresIn: $expiresIn, expiresAt: $expiresAt, user: $user, profiles: $profiles, activeProfileId: $activeProfileId)';
}


}

/// @nodoc
abstract mixin class _$AuthSessionCopyWith<$Res> implements $AuthSessionCopyWith<$Res> {
  factory _$AuthSessionCopyWith(_AuthSession value, $Res Function(_AuthSession) _then) = __$AuthSessionCopyWithImpl;
@override @useResult
$Res call({
 String accessToken, String refreshToken, String tokenType, int expiresIn, DateTime? expiresAt, User user, List<Profile> profiles, String? activeProfileId
});


@override $UserCopyWith<$Res> get user;

}
/// @nodoc
class __$AuthSessionCopyWithImpl<$Res>
    implements _$AuthSessionCopyWith<$Res> {
  __$AuthSessionCopyWithImpl(this._self, this._then);

  final _AuthSession _self;
  final $Res Function(_AuthSession) _then;

/// Create a copy of AuthSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accessToken = null,Object? refreshToken = null,Object? tokenType = null,Object? expiresIn = null,Object? expiresAt = freezed,Object? user = null,Object? profiles = null,Object? activeProfileId = freezed,}) {
  return _then(_AuthSession(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,tokenType: null == tokenType ? _self.tokenType : tokenType // ignore: cast_nullable_to_non_nullable
as String,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,profiles: null == profiles ? _self._profiles : profiles // ignore: cast_nullable_to_non_nullable
as List<Profile>,activeProfileId: freezed == activeProfileId ? _self.activeProfileId : activeProfileId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of AuthSession
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get user {
  
  return $UserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// @nodoc
mixin _$AccountSnapshot {

 User get user; List<Profile> get profiles; String? get activeProfileId;
/// Create a copy of AccountSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountSnapshotCopyWith<AccountSnapshot> get copyWith => _$AccountSnapshotCopyWithImpl<AccountSnapshot>(this as AccountSnapshot, _$identity);

  /// Serializes this AccountSnapshot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountSnapshot&&(identical(other.user, user) || other.user == user)&&const DeepCollectionEquality().equals(other.profiles, profiles)&&(identical(other.activeProfileId, activeProfileId) || other.activeProfileId == activeProfileId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,user,const DeepCollectionEquality().hash(profiles),activeProfileId);

@override
String toString() {
  return 'AccountSnapshot(user: $user, profiles: $profiles, activeProfileId: $activeProfileId)';
}


}

/// @nodoc
abstract mixin class $AccountSnapshotCopyWith<$Res>  {
  factory $AccountSnapshotCopyWith(AccountSnapshot value, $Res Function(AccountSnapshot) _then) = _$AccountSnapshotCopyWithImpl;
@useResult
$Res call({
 User user, List<Profile> profiles, String? activeProfileId
});


$UserCopyWith<$Res> get user;

}
/// @nodoc
class _$AccountSnapshotCopyWithImpl<$Res>
    implements $AccountSnapshotCopyWith<$Res> {
  _$AccountSnapshotCopyWithImpl(this._self, this._then);

  final AccountSnapshot _self;
  final $Res Function(AccountSnapshot) _then;

/// Create a copy of AccountSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? user = null,Object? profiles = null,Object? activeProfileId = freezed,}) {
  return _then(_self.copyWith(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,profiles: null == profiles ? _self.profiles : profiles // ignore: cast_nullable_to_non_nullable
as List<Profile>,activeProfileId: freezed == activeProfileId ? _self.activeProfileId : activeProfileId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of AccountSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get user {
  
  return $UserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [AccountSnapshot].
extension AccountSnapshotPatterns on AccountSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccountSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccountSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccountSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _AccountSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccountSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _AccountSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( User user,  List<Profile> profiles,  String? activeProfileId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountSnapshot() when $default != null:
return $default(_that.user,_that.profiles,_that.activeProfileId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( User user,  List<Profile> profiles,  String? activeProfileId)  $default,) {final _that = this;
switch (_that) {
case _AccountSnapshot():
return $default(_that.user,_that.profiles,_that.activeProfileId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( User user,  List<Profile> profiles,  String? activeProfileId)?  $default,) {final _that = this;
switch (_that) {
case _AccountSnapshot() when $default != null:
return $default(_that.user,_that.profiles,_that.activeProfileId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AccountSnapshot implements AccountSnapshot {
  const _AccountSnapshot({required this.user, final  List<Profile> profiles = const <Profile>[], this.activeProfileId}): _profiles = profiles;
  factory _AccountSnapshot.fromJson(Map<String, dynamic> json) => _$AccountSnapshotFromJson(json);

@override final  User user;
 final  List<Profile> _profiles;
@override@JsonKey() List<Profile> get profiles {
  if (_profiles is EqualUnmodifiableListView) return _profiles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_profiles);
}

@override final  String? activeProfileId;

/// Create a copy of AccountSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountSnapshotCopyWith<_AccountSnapshot> get copyWith => __$AccountSnapshotCopyWithImpl<_AccountSnapshot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccountSnapshotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountSnapshot&&(identical(other.user, user) || other.user == user)&&const DeepCollectionEquality().equals(other._profiles, _profiles)&&(identical(other.activeProfileId, activeProfileId) || other.activeProfileId == activeProfileId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,user,const DeepCollectionEquality().hash(_profiles),activeProfileId);

@override
String toString() {
  return 'AccountSnapshot(user: $user, profiles: $profiles, activeProfileId: $activeProfileId)';
}


}

/// @nodoc
abstract mixin class _$AccountSnapshotCopyWith<$Res> implements $AccountSnapshotCopyWith<$Res> {
  factory _$AccountSnapshotCopyWith(_AccountSnapshot value, $Res Function(_AccountSnapshot) _then) = __$AccountSnapshotCopyWithImpl;
@override @useResult
$Res call({
 User user, List<Profile> profiles, String? activeProfileId
});


@override $UserCopyWith<$Res> get user;

}
/// @nodoc
class __$AccountSnapshotCopyWithImpl<$Res>
    implements _$AccountSnapshotCopyWith<$Res> {
  __$AccountSnapshotCopyWithImpl(this._self, this._then);

  final _AccountSnapshot _self;
  final $Res Function(_AccountSnapshot) _then;

/// Create a copy of AccountSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? user = null,Object? profiles = null,Object? activeProfileId = freezed,}) {
  return _then(_AccountSnapshot(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,profiles: null == profiles ? _self._profiles : profiles // ignore: cast_nullable_to_non_nullable
as List<Profile>,activeProfileId: freezed == activeProfileId ? _self.activeProfileId : activeProfileId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of AccountSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get user {
  
  return $UserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

// dart format on
