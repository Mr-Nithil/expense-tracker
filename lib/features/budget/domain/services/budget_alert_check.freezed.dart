// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget_alert_check.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BudgetAlert {

 BudgetProgress get progress; BudgetStatus get status;
/// Create a copy of BudgetAlert
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetAlertCopyWith<BudgetAlert> get copyWith => _$BudgetAlertCopyWithImpl<BudgetAlert>(this as BudgetAlert, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetAlert&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,progress,status);

@override
String toString() {
  return 'BudgetAlert(progress: $progress, status: $status)';
}


}

/// @nodoc
abstract mixin class $BudgetAlertCopyWith<$Res>  {
  factory $BudgetAlertCopyWith(BudgetAlert value, $Res Function(BudgetAlert) _then) = _$BudgetAlertCopyWithImpl;
@useResult
$Res call({
 BudgetProgress progress, BudgetStatus status
});


$BudgetProgressCopyWith<$Res> get progress;

}
/// @nodoc
class _$BudgetAlertCopyWithImpl<$Res>
    implements $BudgetAlertCopyWith<$Res> {
  _$BudgetAlertCopyWithImpl(this._self, this._then);

  final BudgetAlert _self;
  final $Res Function(BudgetAlert) _then;

/// Create a copy of BudgetAlert
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? progress = null,Object? status = null,}) {
  return _then(_self.copyWith(
progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as BudgetProgress,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BudgetStatus,
  ));
}
/// Create a copy of BudgetAlert
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BudgetProgressCopyWith<$Res> get progress {
  
  return $BudgetProgressCopyWith<$Res>(_self.progress, (value) {
    return _then(_self.copyWith(progress: value));
  });
}
}


/// Adds pattern-matching-related methods to [BudgetAlert].
extension BudgetAlertPatterns on BudgetAlert {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetAlert value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetAlert() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetAlert value)  $default,){
final _that = this;
switch (_that) {
case _BudgetAlert():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetAlert value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetAlert() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BudgetProgress progress,  BudgetStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetAlert() when $default != null:
return $default(_that.progress,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BudgetProgress progress,  BudgetStatus status)  $default,) {final _that = this;
switch (_that) {
case _BudgetAlert():
return $default(_that.progress,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BudgetProgress progress,  BudgetStatus status)?  $default,) {final _that = this;
switch (_that) {
case _BudgetAlert() when $default != null:
return $default(_that.progress,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _BudgetAlert implements BudgetAlert {
  const _BudgetAlert({required this.progress, required this.status});
  

@override final  BudgetProgress progress;
@override final  BudgetStatus status;

/// Create a copy of BudgetAlert
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetAlertCopyWith<_BudgetAlert> get copyWith => __$BudgetAlertCopyWithImpl<_BudgetAlert>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetAlert&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,progress,status);

@override
String toString() {
  return 'BudgetAlert(progress: $progress, status: $status)';
}


}

/// @nodoc
abstract mixin class _$BudgetAlertCopyWith<$Res> implements $BudgetAlertCopyWith<$Res> {
  factory _$BudgetAlertCopyWith(_BudgetAlert value, $Res Function(_BudgetAlert) _then) = __$BudgetAlertCopyWithImpl;
@override @useResult
$Res call({
 BudgetProgress progress, BudgetStatus status
});


@override $BudgetProgressCopyWith<$Res> get progress;

}
/// @nodoc
class __$BudgetAlertCopyWithImpl<$Res>
    implements _$BudgetAlertCopyWith<$Res> {
  __$BudgetAlertCopyWithImpl(this._self, this._then);

  final _BudgetAlert _self;
  final $Res Function(_BudgetAlert) _then;

/// Create a copy of BudgetAlert
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? progress = null,Object? status = null,}) {
  return _then(_BudgetAlert(
progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as BudgetProgress,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BudgetStatus,
  ));
}

/// Create a copy of BudgetAlert
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BudgetProgressCopyWith<$Res> get progress {
  
  return $BudgetProgressCopyWith<$Res>(_self.progress, (value) {
    return _then(_self.copyWith(progress: value));
  });
}
}

// dart format on
