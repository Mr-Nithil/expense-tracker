// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reminder_notification_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlannedNotification {

 int get id; String get reminderId; String get title;/// First time it shows (local wall-clock time), always after "now".
 DateTime get at; PlannedRepeat get repeat;
/// Create a copy of PlannedNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlannedNotificationCopyWith<PlannedNotification> get copyWith => _$PlannedNotificationCopyWithImpl<PlannedNotification>(this as PlannedNotification, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlannedNotification&&(identical(other.id, id) || other.id == id)&&(identical(other.reminderId, reminderId) || other.reminderId == reminderId)&&(identical(other.title, title) || other.title == title)&&(identical(other.at, at) || other.at == at)&&(identical(other.repeat, repeat) || other.repeat == repeat));
}


@override
int get hashCode => Object.hash(runtimeType,id,reminderId,title,at,repeat);

@override
String toString() {
  return 'PlannedNotification(id: $id, reminderId: $reminderId, title: $title, at: $at, repeat: $repeat)';
}


}

/// @nodoc
abstract mixin class $PlannedNotificationCopyWith<$Res>  {
  factory $PlannedNotificationCopyWith(PlannedNotification value, $Res Function(PlannedNotification) _then) = _$PlannedNotificationCopyWithImpl;
@useResult
$Res call({
 int id, String reminderId, String title, DateTime at, PlannedRepeat repeat
});




}
/// @nodoc
class _$PlannedNotificationCopyWithImpl<$Res>
    implements $PlannedNotificationCopyWith<$Res> {
  _$PlannedNotificationCopyWithImpl(this._self, this._then);

  final PlannedNotification _self;
  final $Res Function(PlannedNotification) _then;

/// Create a copy of PlannedNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reminderId = null,Object? title = null,Object? at = null,Object? repeat = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,reminderId: null == reminderId ? _self.reminderId : reminderId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,repeat: null == repeat ? _self.repeat : repeat // ignore: cast_nullable_to_non_nullable
as PlannedRepeat,
  ));
}

}


/// Adds pattern-matching-related methods to [PlannedNotification].
extension PlannedNotificationPatterns on PlannedNotification {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlannedNotification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlannedNotification() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlannedNotification value)  $default,){
final _that = this;
switch (_that) {
case _PlannedNotification():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlannedNotification value)?  $default,){
final _that = this;
switch (_that) {
case _PlannedNotification() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String reminderId,  String title,  DateTime at,  PlannedRepeat repeat)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlannedNotification() when $default != null:
return $default(_that.id,_that.reminderId,_that.title,_that.at,_that.repeat);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String reminderId,  String title,  DateTime at,  PlannedRepeat repeat)  $default,) {final _that = this;
switch (_that) {
case _PlannedNotification():
return $default(_that.id,_that.reminderId,_that.title,_that.at,_that.repeat);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String reminderId,  String title,  DateTime at,  PlannedRepeat repeat)?  $default,) {final _that = this;
switch (_that) {
case _PlannedNotification() when $default != null:
return $default(_that.id,_that.reminderId,_that.title,_that.at,_that.repeat);case _:
  return null;

}
}

}

/// @nodoc


class _PlannedNotification implements PlannedNotification {
  const _PlannedNotification({required this.id, required this.reminderId, required this.title, required this.at, required this.repeat});
  

@override final  int id;
@override final  String reminderId;
@override final  String title;
/// First time it shows (local wall-clock time), always after "now".
@override final  DateTime at;
@override final  PlannedRepeat repeat;

/// Create a copy of PlannedNotification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlannedNotificationCopyWith<_PlannedNotification> get copyWith => __$PlannedNotificationCopyWithImpl<_PlannedNotification>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlannedNotification&&(identical(other.id, id) || other.id == id)&&(identical(other.reminderId, reminderId) || other.reminderId == reminderId)&&(identical(other.title, title) || other.title == title)&&(identical(other.at, at) || other.at == at)&&(identical(other.repeat, repeat) || other.repeat == repeat));
}


@override
int get hashCode => Object.hash(runtimeType,id,reminderId,title,at,repeat);

@override
String toString() {
  return 'PlannedNotification(id: $id, reminderId: $reminderId, title: $title, at: $at, repeat: $repeat)';
}


}

/// @nodoc
abstract mixin class _$PlannedNotificationCopyWith<$Res> implements $PlannedNotificationCopyWith<$Res> {
  factory _$PlannedNotificationCopyWith(_PlannedNotification value, $Res Function(_PlannedNotification) _then) = __$PlannedNotificationCopyWithImpl;
@override @useResult
$Res call({
 int id, String reminderId, String title, DateTime at, PlannedRepeat repeat
});




}
/// @nodoc
class __$PlannedNotificationCopyWithImpl<$Res>
    implements _$PlannedNotificationCopyWith<$Res> {
  __$PlannedNotificationCopyWithImpl(this._self, this._then);

  final _PlannedNotification _self;
  final $Res Function(_PlannedNotification) _then;

/// Create a copy of PlannedNotification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reminderId = null,Object? title = null,Object? at = null,Object? repeat = null,}) {
  return _then(_PlannedNotification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,reminderId: null == reminderId ? _self.reminderId : reminderId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,repeat: null == repeat ? _self.repeat : repeat // ignore: cast_nullable_to_non_nullable
as PlannedRepeat,
  ));
}


}

// dart format on
