// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'goal_progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GoalProgress {

 Goal get goal; Money get saved;
/// Create a copy of GoalProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoalProgressCopyWith<GoalProgress> get copyWith => _$GoalProgressCopyWithImpl<GoalProgress>(this as GoalProgress, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoalProgress&&(identical(other.goal, goal) || other.goal == goal)&&(identical(other.saved, saved) || other.saved == saved));
}


@override
int get hashCode => Object.hash(runtimeType,goal,saved);

@override
String toString() {
  return 'GoalProgress(goal: $goal, saved: $saved)';
}


}

/// @nodoc
abstract mixin class $GoalProgressCopyWith<$Res>  {
  factory $GoalProgressCopyWith(GoalProgress value, $Res Function(GoalProgress) _then) = _$GoalProgressCopyWithImpl;
@useResult
$Res call({
 Goal goal, Money saved
});


$GoalCopyWith<$Res> get goal;

}
/// @nodoc
class _$GoalProgressCopyWithImpl<$Res>
    implements $GoalProgressCopyWith<$Res> {
  _$GoalProgressCopyWithImpl(this._self, this._then);

  final GoalProgress _self;
  final $Res Function(GoalProgress) _then;

/// Create a copy of GoalProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? goal = null,Object? saved = null,}) {
  return _then(_self.copyWith(
goal: null == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as Goal,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}
/// Create a copy of GoalProgress
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GoalCopyWith<$Res> get goal {
  
  return $GoalCopyWith<$Res>(_self.goal, (value) {
    return _then(_self.copyWith(goal: value));
  });
}
}


/// Adds pattern-matching-related methods to [GoalProgress].
extension GoalProgressPatterns on GoalProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoalProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoalProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoalProgress value)  $default,){
final _that = this;
switch (_that) {
case _GoalProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoalProgress value)?  $default,){
final _that = this;
switch (_that) {
case _GoalProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Goal goal,  Money saved)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoalProgress() when $default != null:
return $default(_that.goal,_that.saved);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Goal goal,  Money saved)  $default,) {final _that = this;
switch (_that) {
case _GoalProgress():
return $default(_that.goal,_that.saved);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Goal goal,  Money saved)?  $default,) {final _that = this;
switch (_that) {
case _GoalProgress() when $default != null:
return $default(_that.goal,_that.saved);case _:
  return null;

}
}

}

/// @nodoc


class _GoalProgress extends GoalProgress {
  const _GoalProgress({required this.goal, required this.saved}): super._();
  

@override final  Goal goal;
@override final  Money saved;

/// Create a copy of GoalProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoalProgressCopyWith<_GoalProgress> get copyWith => __$GoalProgressCopyWithImpl<_GoalProgress>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoalProgress&&(identical(other.goal, goal) || other.goal == goal)&&(identical(other.saved, saved) || other.saved == saved));
}


@override
int get hashCode => Object.hash(runtimeType,goal,saved);

@override
String toString() {
  return 'GoalProgress(goal: $goal, saved: $saved)';
}


}

/// @nodoc
abstract mixin class _$GoalProgressCopyWith<$Res> implements $GoalProgressCopyWith<$Res> {
  factory _$GoalProgressCopyWith(_GoalProgress value, $Res Function(_GoalProgress) _then) = __$GoalProgressCopyWithImpl;
@override @useResult
$Res call({
 Goal goal, Money saved
});


@override $GoalCopyWith<$Res> get goal;

}
/// @nodoc
class __$GoalProgressCopyWithImpl<$Res>
    implements _$GoalProgressCopyWith<$Res> {
  __$GoalProgressCopyWithImpl(this._self, this._then);

  final _GoalProgress _self;
  final $Res Function(_GoalProgress) _then;

/// Create a copy of GoalProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? goal = null,Object? saved = null,}) {
  return _then(_GoalProgress(
goal: null == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as Goal,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}

/// Create a copy of GoalProgress
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GoalCopyWith<$Res> get goal {
  
  return $GoalCopyWith<$Res>(_self.goal, (value) {
    return _then(_self.copyWith(goal: value));
  });
}
}

// dart format on
