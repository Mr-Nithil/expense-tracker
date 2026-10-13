// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lock_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LockSettings {

 bool get pinEnabled;/// Number of digits of the PIN (the lock screen checks it once that many are entered).
 int get pinLength; bool get biometricsEnabled; LockTimeout get timeout;
/// Create a copy of LockSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LockSettingsCopyWith<LockSettings> get copyWith => _$LockSettingsCopyWithImpl<LockSettings>(this as LockSettings, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LockSettings&&(identical(other.pinEnabled, pinEnabled) || other.pinEnabled == pinEnabled)&&(identical(other.pinLength, pinLength) || other.pinLength == pinLength)&&(identical(other.biometricsEnabled, biometricsEnabled) || other.biometricsEnabled == biometricsEnabled)&&(identical(other.timeout, timeout) || other.timeout == timeout));
}


@override
int get hashCode => Object.hash(runtimeType,pinEnabled,pinLength,biometricsEnabled,timeout);

@override
String toString() {
  return 'LockSettings(pinEnabled: $pinEnabled, pinLength: $pinLength, biometricsEnabled: $biometricsEnabled, timeout: $timeout)';
}


}

/// @nodoc
abstract mixin class $LockSettingsCopyWith<$Res>  {
  factory $LockSettingsCopyWith(LockSettings value, $Res Function(LockSettings) _then) = _$LockSettingsCopyWithImpl;
@useResult
$Res call({
 bool pinEnabled, int pinLength, bool biometricsEnabled, LockTimeout timeout
});




}
/// @nodoc
class _$LockSettingsCopyWithImpl<$Res>
    implements $LockSettingsCopyWith<$Res> {
  _$LockSettingsCopyWithImpl(this._self, this._then);

  final LockSettings _self;
  final $Res Function(LockSettings) _then;

/// Create a copy of LockSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pinEnabled = null,Object? pinLength = null,Object? biometricsEnabled = null,Object? timeout = null,}) {
  return _then(_self.copyWith(
pinEnabled: null == pinEnabled ? _self.pinEnabled : pinEnabled // ignore: cast_nullable_to_non_nullable
as bool,pinLength: null == pinLength ? _self.pinLength : pinLength // ignore: cast_nullable_to_non_nullable
as int,biometricsEnabled: null == biometricsEnabled ? _self.biometricsEnabled : biometricsEnabled // ignore: cast_nullable_to_non_nullable
as bool,timeout: null == timeout ? _self.timeout : timeout // ignore: cast_nullable_to_non_nullable
as LockTimeout,
  ));
}

}


/// Adds pattern-matching-related methods to [LockSettings].
extension LockSettingsPatterns on LockSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LockSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LockSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LockSettings value)  $default,){
final _that = this;
switch (_that) {
case _LockSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LockSettings value)?  $default,){
final _that = this;
switch (_that) {
case _LockSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool pinEnabled,  int pinLength,  bool biometricsEnabled,  LockTimeout timeout)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LockSettings() when $default != null:
return $default(_that.pinEnabled,_that.pinLength,_that.biometricsEnabled,_that.timeout);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool pinEnabled,  int pinLength,  bool biometricsEnabled,  LockTimeout timeout)  $default,) {final _that = this;
switch (_that) {
case _LockSettings():
return $default(_that.pinEnabled,_that.pinLength,_that.biometricsEnabled,_that.timeout);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool pinEnabled,  int pinLength,  bool biometricsEnabled,  LockTimeout timeout)?  $default,) {final _that = this;
switch (_that) {
case _LockSettings() when $default != null:
return $default(_that.pinEnabled,_that.pinLength,_that.biometricsEnabled,_that.timeout);case _:
  return null;

}
}

}

/// @nodoc


class _LockSettings implements LockSettings {
  const _LockSettings({this.pinEnabled = false, this.pinLength = 0, this.biometricsEnabled = false, this.timeout = LockTimeout.fallback});
  

@override@JsonKey() final  bool pinEnabled;
/// Number of digits of the PIN (the lock screen checks it once that many are entered).
@override@JsonKey() final  int pinLength;
@override@JsonKey() final  bool biometricsEnabled;
@override@JsonKey() final  LockTimeout timeout;

/// Create a copy of LockSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LockSettingsCopyWith<_LockSettings> get copyWith => __$LockSettingsCopyWithImpl<_LockSettings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LockSettings&&(identical(other.pinEnabled, pinEnabled) || other.pinEnabled == pinEnabled)&&(identical(other.pinLength, pinLength) || other.pinLength == pinLength)&&(identical(other.biometricsEnabled, biometricsEnabled) || other.biometricsEnabled == biometricsEnabled)&&(identical(other.timeout, timeout) || other.timeout == timeout));
}


@override
int get hashCode => Object.hash(runtimeType,pinEnabled,pinLength,biometricsEnabled,timeout);

@override
String toString() {
  return 'LockSettings(pinEnabled: $pinEnabled, pinLength: $pinLength, biometricsEnabled: $biometricsEnabled, timeout: $timeout)';
}


}

/// @nodoc
abstract mixin class _$LockSettingsCopyWith<$Res> implements $LockSettingsCopyWith<$Res> {
  factory _$LockSettingsCopyWith(_LockSettings value, $Res Function(_LockSettings) _then) = __$LockSettingsCopyWithImpl;
@override @useResult
$Res call({
 bool pinEnabled, int pinLength, bool biometricsEnabled, LockTimeout timeout
});




}
/// @nodoc
class __$LockSettingsCopyWithImpl<$Res>
    implements _$LockSettingsCopyWith<$Res> {
  __$LockSettingsCopyWithImpl(this._self, this._then);

  final _LockSettings _self;
  final $Res Function(_LockSettings) _then;

/// Create a copy of LockSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pinEnabled = null,Object? pinLength = null,Object? biometricsEnabled = null,Object? timeout = null,}) {
  return _then(_LockSettings(
pinEnabled: null == pinEnabled ? _self.pinEnabled : pinEnabled // ignore: cast_nullable_to_non_nullable
as bool,pinLength: null == pinLength ? _self.pinLength : pinLength // ignore: cast_nullable_to_non_nullable
as int,biometricsEnabled: null == biometricsEnabled ? _self.biometricsEnabled : biometricsEnabled // ignore: cast_nullable_to_non_nullable
as bool,timeout: null == timeout ? _self.timeout : timeout // ignore: cast_nullable_to_non_nullable
as LockTimeout,
  ));
}


}

// dart format on
