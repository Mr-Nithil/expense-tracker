// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'day_totals.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DayTotals {

/// The day (local midnight).
 DateTime get date; Money get income; Money get expense;
/// Create a copy of DayTotals
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DayTotalsCopyWith<DayTotals> get copyWith => _$DayTotalsCopyWithImpl<DayTotals>(this as DayTotals, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DayTotals&&(identical(other.date, date) || other.date == date)&&(identical(other.income, income) || other.income == income)&&(identical(other.expense, expense) || other.expense == expense));
}


@override
int get hashCode => Object.hash(runtimeType,date,income,expense);

@override
String toString() {
  return 'DayTotals(date: $date, income: $income, expense: $expense)';
}


}

/// @nodoc
abstract mixin class $DayTotalsCopyWith<$Res>  {
  factory $DayTotalsCopyWith(DayTotals value, $Res Function(DayTotals) _then) = _$DayTotalsCopyWithImpl;
@useResult
$Res call({
 DateTime date, Money income, Money expense
});




}
/// @nodoc
class _$DayTotalsCopyWithImpl<$Res>
    implements $DayTotalsCopyWith<$Res> {
  _$DayTotalsCopyWithImpl(this._self, this._then);

  final DayTotals _self;
  final $Res Function(DayTotals) _then;

/// Create a copy of DayTotals
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? income = null,Object? expense = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as Money,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}

}


/// Adds pattern-matching-related methods to [DayTotals].
extension DayTotalsPatterns on DayTotals {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DayTotals value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DayTotals() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DayTotals value)  $default,){
final _that = this;
switch (_that) {
case _DayTotals():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DayTotals value)?  $default,){
final _that = this;
switch (_that) {
case _DayTotals() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  Money income,  Money expense)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DayTotals() when $default != null:
return $default(_that.date,_that.income,_that.expense);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  Money income,  Money expense)  $default,) {final _that = this;
switch (_that) {
case _DayTotals():
return $default(_that.date,_that.income,_that.expense);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  Money income,  Money expense)?  $default,) {final _that = this;
switch (_that) {
case _DayTotals() when $default != null:
return $default(_that.date,_that.income,_that.expense);case _:
  return null;

}
}

}

/// @nodoc


class _DayTotals extends DayTotals {
  const _DayTotals({required this.date, required this.income, required this.expense}): super._();
  

/// The day (local midnight).
@override final  DateTime date;
@override final  Money income;
@override final  Money expense;

/// Create a copy of DayTotals
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DayTotalsCopyWith<_DayTotals> get copyWith => __$DayTotalsCopyWithImpl<_DayTotals>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DayTotals&&(identical(other.date, date) || other.date == date)&&(identical(other.income, income) || other.income == income)&&(identical(other.expense, expense) || other.expense == expense));
}


@override
int get hashCode => Object.hash(runtimeType,date,income,expense);

@override
String toString() {
  return 'DayTotals(date: $date, income: $income, expense: $expense)';
}


}

/// @nodoc
abstract mixin class _$DayTotalsCopyWith<$Res> implements $DayTotalsCopyWith<$Res> {
  factory _$DayTotalsCopyWith(_DayTotals value, $Res Function(_DayTotals) _then) = __$DayTotalsCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, Money income, Money expense
});




}
/// @nodoc
class __$DayTotalsCopyWithImpl<$Res>
    implements _$DayTotalsCopyWith<$Res> {
  __$DayTotalsCopyWithImpl(this._self, this._then);

  final _DayTotals _self;
  final $Res Function(_DayTotals) _then;

/// Create a copy of DayTotals
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? income = null,Object? expense = null,}) {
  return _then(_DayTotals(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as Money,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}


}

// dart format on
