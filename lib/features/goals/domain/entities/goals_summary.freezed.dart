// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'goals_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GoalsSummary {

 Money get totalSaved; Money get totalTarget; int get reachedCount;/// Unfinished goals, highest percent first.
 List<GoalProgress> get top;
/// Create a copy of GoalsSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoalsSummaryCopyWith<GoalsSummary> get copyWith => _$GoalsSummaryCopyWithImpl<GoalsSummary>(this as GoalsSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoalsSummary&&(identical(other.totalSaved, totalSaved) || other.totalSaved == totalSaved)&&(identical(other.totalTarget, totalTarget) || other.totalTarget == totalTarget)&&(identical(other.reachedCount, reachedCount) || other.reachedCount == reachedCount)&&const DeepCollectionEquality().equals(other.top, top));
}


@override
int get hashCode => Object.hash(runtimeType,totalSaved,totalTarget,reachedCount,const DeepCollectionEquality().hash(top));

@override
String toString() {
  return 'GoalsSummary(totalSaved: $totalSaved, totalTarget: $totalTarget, reachedCount: $reachedCount, top: $top)';
}


}

/// @nodoc
abstract mixin class $GoalsSummaryCopyWith<$Res>  {
  factory $GoalsSummaryCopyWith(GoalsSummary value, $Res Function(GoalsSummary) _then) = _$GoalsSummaryCopyWithImpl;
@useResult
$Res call({
 Money totalSaved, Money totalTarget, int reachedCount, List<GoalProgress> top
});




}
/// @nodoc
class _$GoalsSummaryCopyWithImpl<$Res>
    implements $GoalsSummaryCopyWith<$Res> {
  _$GoalsSummaryCopyWithImpl(this._self, this._then);

  final GoalsSummary _self;
  final $Res Function(GoalsSummary) _then;

/// Create a copy of GoalsSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalSaved = null,Object? totalTarget = null,Object? reachedCount = null,Object? top = null,}) {
  return _then(_self.copyWith(
totalSaved: null == totalSaved ? _self.totalSaved : totalSaved // ignore: cast_nullable_to_non_nullable
as Money,totalTarget: null == totalTarget ? _self.totalTarget : totalTarget // ignore: cast_nullable_to_non_nullable
as Money,reachedCount: null == reachedCount ? _self.reachedCount : reachedCount // ignore: cast_nullable_to_non_nullable
as int,top: null == top ? _self.top : top // ignore: cast_nullable_to_non_nullable
as List<GoalProgress>,
  ));
}

}


/// Adds pattern-matching-related methods to [GoalsSummary].
extension GoalsSummaryPatterns on GoalsSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoalsSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoalsSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoalsSummary value)  $default,){
final _that = this;
switch (_that) {
case _GoalsSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoalsSummary value)?  $default,){
final _that = this;
switch (_that) {
case _GoalsSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Money totalSaved,  Money totalTarget,  int reachedCount,  List<GoalProgress> top)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoalsSummary() when $default != null:
return $default(_that.totalSaved,_that.totalTarget,_that.reachedCount,_that.top);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Money totalSaved,  Money totalTarget,  int reachedCount,  List<GoalProgress> top)  $default,) {final _that = this;
switch (_that) {
case _GoalsSummary():
return $default(_that.totalSaved,_that.totalTarget,_that.reachedCount,_that.top);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Money totalSaved,  Money totalTarget,  int reachedCount,  List<GoalProgress> top)?  $default,) {final _that = this;
switch (_that) {
case _GoalsSummary() when $default != null:
return $default(_that.totalSaved,_that.totalTarget,_that.reachedCount,_that.top);case _:
  return null;

}
}

}

/// @nodoc


class _GoalsSummary extends GoalsSummary {
  const _GoalsSummary({required this.totalSaved, required this.totalTarget, required this.reachedCount, required final  List<GoalProgress> top}): _top = top,super._();
  

@override final  Money totalSaved;
@override final  Money totalTarget;
@override final  int reachedCount;
/// Unfinished goals, highest percent first.
 final  List<GoalProgress> _top;
/// Unfinished goals, highest percent first.
@override List<GoalProgress> get top {
  if (_top is EqualUnmodifiableListView) return _top;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_top);
}


/// Create a copy of GoalsSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoalsSummaryCopyWith<_GoalsSummary> get copyWith => __$GoalsSummaryCopyWithImpl<_GoalsSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoalsSummary&&(identical(other.totalSaved, totalSaved) || other.totalSaved == totalSaved)&&(identical(other.totalTarget, totalTarget) || other.totalTarget == totalTarget)&&(identical(other.reachedCount, reachedCount) || other.reachedCount == reachedCount)&&const DeepCollectionEquality().equals(other._top, _top));
}


@override
int get hashCode => Object.hash(runtimeType,totalSaved,totalTarget,reachedCount,const DeepCollectionEquality().hash(_top));

@override
String toString() {
  return 'GoalsSummary(totalSaved: $totalSaved, totalTarget: $totalTarget, reachedCount: $reachedCount, top: $top)';
}


}

/// @nodoc
abstract mixin class _$GoalsSummaryCopyWith<$Res> implements $GoalsSummaryCopyWith<$Res> {
  factory _$GoalsSummaryCopyWith(_GoalsSummary value, $Res Function(_GoalsSummary) _then) = __$GoalsSummaryCopyWithImpl;
@override @useResult
$Res call({
 Money totalSaved, Money totalTarget, int reachedCount, List<GoalProgress> top
});




}
/// @nodoc
class __$GoalsSummaryCopyWithImpl<$Res>
    implements _$GoalsSummaryCopyWith<$Res> {
  __$GoalsSummaryCopyWithImpl(this._self, this._then);

  final _GoalsSummary _self;
  final $Res Function(_GoalsSummary) _then;

/// Create a copy of GoalsSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalSaved = null,Object? totalTarget = null,Object? reachedCount = null,Object? top = null,}) {
  return _then(_GoalsSummary(
totalSaved: null == totalSaved ? _self.totalSaved : totalSaved // ignore: cast_nullable_to_non_nullable
as Money,totalTarget: null == totalTarget ? _self.totalTarget : totalTarget // ignore: cast_nullable_to_non_nullable
as Money,reachedCount: null == reachedCount ? _self.reachedCount : reachedCount // ignore: cast_nullable_to_non_nullable
as int,top: null == top ? _self._top : top // ignore: cast_nullable_to_non_nullable
as List<GoalProgress>,
  ));
}


}

// dart format on
