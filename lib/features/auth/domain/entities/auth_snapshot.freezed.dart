// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthSnapshot {

/// The signed-in user, or `null` when signed out.
 AuthUser? get user;/// Signed in through a password-reset link: the user must set a new password before entering
/// the app. Stays true across token refreshes until the password is updated or the user signs
/// out. In memory only, so it does not survive an app restart.
 bool get isPasswordRecovery;
/// Create a copy of AuthSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthSnapshotCopyWith<AuthSnapshot> get copyWith => _$AuthSnapshotCopyWithImpl<AuthSnapshot>(this as AuthSnapshot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthSnapshot&&(identical(other.user, user) || other.user == user)&&(identical(other.isPasswordRecovery, isPasswordRecovery) || other.isPasswordRecovery == isPasswordRecovery));
}


@override
int get hashCode => Object.hash(runtimeType,user,isPasswordRecovery);

@override
String toString() {
  return 'AuthSnapshot(user: $user, isPasswordRecovery: $isPasswordRecovery)';
}


}

/// @nodoc
abstract mixin class $AuthSnapshotCopyWith<$Res>  {
  factory $AuthSnapshotCopyWith(AuthSnapshot value, $Res Function(AuthSnapshot) _then) = _$AuthSnapshotCopyWithImpl;
@useResult
$Res call({
 AuthUser? user, bool isPasswordRecovery
});


$AuthUserCopyWith<$Res>? get user;

}
/// @nodoc
class _$AuthSnapshotCopyWithImpl<$Res>
    implements $AuthSnapshotCopyWith<$Res> {
  _$AuthSnapshotCopyWithImpl(this._self, this._then);

  final AuthSnapshot _self;
  final $Res Function(AuthSnapshot) _then;

/// Create a copy of AuthSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? user = freezed,Object? isPasswordRecovery = null,}) {
  return _then(_self.copyWith(
user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as AuthUser?,isPasswordRecovery: null == isPasswordRecovery ? _self.isPasswordRecovery : isPasswordRecovery // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of AuthSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthUserCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $AuthUserCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [AuthSnapshot].
extension AuthSnapshotPatterns on AuthSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _AuthSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _AuthSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AuthUser? user,  bool isPasswordRecovery)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthSnapshot() when $default != null:
return $default(_that.user,_that.isPasswordRecovery);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AuthUser? user,  bool isPasswordRecovery)  $default,) {final _that = this;
switch (_that) {
case _AuthSnapshot():
return $default(_that.user,_that.isPasswordRecovery);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AuthUser? user,  bool isPasswordRecovery)?  $default,) {final _that = this;
switch (_that) {
case _AuthSnapshot() when $default != null:
return $default(_that.user,_that.isPasswordRecovery);case _:
  return null;

}
}

}

/// @nodoc


class _AuthSnapshot implements AuthSnapshot {
  const _AuthSnapshot({this.user, this.isPasswordRecovery = false});
  

/// The signed-in user, or `null` when signed out.
@override final  AuthUser? user;
/// Signed in through a password-reset link: the user must set a new password before entering
/// the app. Stays true across token refreshes until the password is updated or the user signs
/// out. In memory only, so it does not survive an app restart.
@override@JsonKey() final  bool isPasswordRecovery;

/// Create a copy of AuthSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthSnapshotCopyWith<_AuthSnapshot> get copyWith => __$AuthSnapshotCopyWithImpl<_AuthSnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthSnapshot&&(identical(other.user, user) || other.user == user)&&(identical(other.isPasswordRecovery, isPasswordRecovery) || other.isPasswordRecovery == isPasswordRecovery));
}


@override
int get hashCode => Object.hash(runtimeType,user,isPasswordRecovery);

@override
String toString() {
  return 'AuthSnapshot(user: $user, isPasswordRecovery: $isPasswordRecovery)';
}


}

/// @nodoc
abstract mixin class _$AuthSnapshotCopyWith<$Res> implements $AuthSnapshotCopyWith<$Res> {
  factory _$AuthSnapshotCopyWith(_AuthSnapshot value, $Res Function(_AuthSnapshot) _then) = __$AuthSnapshotCopyWithImpl;
@override @useResult
$Res call({
 AuthUser? user, bool isPasswordRecovery
});


@override $AuthUserCopyWith<$Res>? get user;

}
/// @nodoc
class __$AuthSnapshotCopyWithImpl<$Res>
    implements _$AuthSnapshotCopyWith<$Res> {
  __$AuthSnapshotCopyWithImpl(this._self, this._then);

  final _AuthSnapshot _self;
  final $Res Function(_AuthSnapshot) _then;

/// Create a copy of AuthSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? user = freezed,Object? isPasswordRecovery = null,}) {
  return _then(_AuthSnapshot(
user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as AuthUser?,isPasswordRecovery: null == isPasswordRecovery ? _self.isPasswordRecovery : isPasswordRecovery // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of AuthSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthUserCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $AuthUserCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

// dart format on
