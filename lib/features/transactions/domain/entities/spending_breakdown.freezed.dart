// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'spending_breakdown.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SpendingShare {

 String? get categoryId; Money get amount;/// Whole percent of the total, rounded half up (shares may not add up to exactly 100).
 int get percent;/// [amount] over the total, for bar lengths (a display ratio, not money).
 double get fraction;/// How many categories "Other" groups (0 for a category's own share).
 int get foldedCategories;
/// Create a copy of SpendingShare
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpendingShareCopyWith<SpendingShare> get copyWith => _$SpendingShareCopyWithImpl<SpendingShare>(this as SpendingShare, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpendingShare&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.percent, percent) || other.percent == percent)&&(identical(other.fraction, fraction) || other.fraction == fraction)&&(identical(other.foldedCategories, foldedCategories) || other.foldedCategories == foldedCategories));
}


@override
int get hashCode => Object.hash(runtimeType,categoryId,amount,percent,fraction,foldedCategories);

@override
String toString() {
  return 'SpendingShare(categoryId: $categoryId, amount: $amount, percent: $percent, fraction: $fraction, foldedCategories: $foldedCategories)';
}


}

/// @nodoc
abstract mixin class $SpendingShareCopyWith<$Res>  {
  factory $SpendingShareCopyWith(SpendingShare value, $Res Function(SpendingShare) _then) = _$SpendingShareCopyWithImpl;
@useResult
$Res call({
 String? categoryId, Money amount, int percent, double fraction, int foldedCategories
});




}
/// @nodoc
class _$SpendingShareCopyWithImpl<$Res>
    implements $SpendingShareCopyWith<$Res> {
  _$SpendingShareCopyWithImpl(this._self, this._then);

  final SpendingShare _self;
  final $Res Function(SpendingShare) _then;

/// Create a copy of SpendingShare
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categoryId = freezed,Object? amount = null,Object? percent = null,Object? fraction = null,Object? foldedCategories = null,}) {
  return _then(_self.copyWith(
categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Money,percent: null == percent ? _self.percent : percent // ignore: cast_nullable_to_non_nullable
as int,fraction: null == fraction ? _self.fraction : fraction // ignore: cast_nullable_to_non_nullable
as double,foldedCategories: null == foldedCategories ? _self.foldedCategories : foldedCategories // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SpendingShare].
extension SpendingSharePatterns on SpendingShare {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpendingShare value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpendingShare() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpendingShare value)  $default,){
final _that = this;
switch (_that) {
case _SpendingShare():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpendingShare value)?  $default,){
final _that = this;
switch (_that) {
case _SpendingShare() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? categoryId,  Money amount,  int percent,  double fraction,  int foldedCategories)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpendingShare() when $default != null:
return $default(_that.categoryId,_that.amount,_that.percent,_that.fraction,_that.foldedCategories);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? categoryId,  Money amount,  int percent,  double fraction,  int foldedCategories)  $default,) {final _that = this;
switch (_that) {
case _SpendingShare():
return $default(_that.categoryId,_that.amount,_that.percent,_that.fraction,_that.foldedCategories);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? categoryId,  Money amount,  int percent,  double fraction,  int foldedCategories)?  $default,) {final _that = this;
switch (_that) {
case _SpendingShare() when $default != null:
return $default(_that.categoryId,_that.amount,_that.percent,_that.fraction,_that.foldedCategories);case _:
  return null;

}
}

}

/// @nodoc


class _SpendingShare extends SpendingShare {
  const _SpendingShare({this.categoryId, required this.amount, required this.percent, required this.fraction, this.foldedCategories = 0}): super._();
  

@override final  String? categoryId;
@override final  Money amount;
/// Whole percent of the total, rounded half up (shares may not add up to exactly 100).
@override final  int percent;
/// [amount] over the total, for bar lengths (a display ratio, not money).
@override final  double fraction;
/// How many categories "Other" groups (0 for a category's own share).
@override@JsonKey() final  int foldedCategories;

/// Create a copy of SpendingShare
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpendingShareCopyWith<_SpendingShare> get copyWith => __$SpendingShareCopyWithImpl<_SpendingShare>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpendingShare&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.percent, percent) || other.percent == percent)&&(identical(other.fraction, fraction) || other.fraction == fraction)&&(identical(other.foldedCategories, foldedCategories) || other.foldedCategories == foldedCategories));
}


@override
int get hashCode => Object.hash(runtimeType,categoryId,amount,percent,fraction,foldedCategories);

@override
String toString() {
  return 'SpendingShare(categoryId: $categoryId, amount: $amount, percent: $percent, fraction: $fraction, foldedCategories: $foldedCategories)';
}


}

/// @nodoc
abstract mixin class _$SpendingShareCopyWith<$Res> implements $SpendingShareCopyWith<$Res> {
  factory _$SpendingShareCopyWith(_SpendingShare value, $Res Function(_SpendingShare) _then) = __$SpendingShareCopyWithImpl;
@override @useResult
$Res call({
 String? categoryId, Money amount, int percent, double fraction, int foldedCategories
});




}
/// @nodoc
class __$SpendingShareCopyWithImpl<$Res>
    implements _$SpendingShareCopyWith<$Res> {
  __$SpendingShareCopyWithImpl(this._self, this._then);

  final _SpendingShare _self;
  final $Res Function(_SpendingShare) _then;

/// Create a copy of SpendingShare
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categoryId = freezed,Object? amount = null,Object? percent = null,Object? fraction = null,Object? foldedCategories = null,}) {
  return _then(_SpendingShare(
categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Money,percent: null == percent ? _self.percent : percent // ignore: cast_nullable_to_non_nullable
as int,fraction: null == fraction ? _self.fraction : fraction // ignore: cast_nullable_to_non_nullable
as double,foldedCategories: null == foldedCategories ? _self.foldedCategories : foldedCategories // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$SpendingBreakdown {

 List<SpendingShare> get shares; Money get total;
/// Create a copy of SpendingBreakdown
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpendingBreakdownCopyWith<SpendingBreakdown> get copyWith => _$SpendingBreakdownCopyWithImpl<SpendingBreakdown>(this as SpendingBreakdown, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpendingBreakdown&&const DeepCollectionEquality().equals(other.shares, shares)&&(identical(other.total, total) || other.total == total));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(shares),total);

@override
String toString() {
  return 'SpendingBreakdown(shares: $shares, total: $total)';
}


}

/// @nodoc
abstract mixin class $SpendingBreakdownCopyWith<$Res>  {
  factory $SpendingBreakdownCopyWith(SpendingBreakdown value, $Res Function(SpendingBreakdown) _then) = _$SpendingBreakdownCopyWithImpl;
@useResult
$Res call({
 List<SpendingShare> shares, Money total
});




}
/// @nodoc
class _$SpendingBreakdownCopyWithImpl<$Res>
    implements $SpendingBreakdownCopyWith<$Res> {
  _$SpendingBreakdownCopyWithImpl(this._self, this._then);

  final SpendingBreakdown _self;
  final $Res Function(SpendingBreakdown) _then;

/// Create a copy of SpendingBreakdown
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? shares = null,Object? total = null,}) {
  return _then(_self.copyWith(
shares: null == shares ? _self.shares : shares // ignore: cast_nullable_to_non_nullable
as List<SpendingShare>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}

}


/// Adds pattern-matching-related methods to [SpendingBreakdown].
extension SpendingBreakdownPatterns on SpendingBreakdown {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpendingBreakdown value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpendingBreakdown() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpendingBreakdown value)  $default,){
final _that = this;
switch (_that) {
case _SpendingBreakdown():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpendingBreakdown value)?  $default,){
final _that = this;
switch (_that) {
case _SpendingBreakdown() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<SpendingShare> shares,  Money total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpendingBreakdown() when $default != null:
return $default(_that.shares,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<SpendingShare> shares,  Money total)  $default,) {final _that = this;
switch (_that) {
case _SpendingBreakdown():
return $default(_that.shares,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<SpendingShare> shares,  Money total)?  $default,) {final _that = this;
switch (_that) {
case _SpendingBreakdown() when $default != null:
return $default(_that.shares,_that.total);case _:
  return null;

}
}

}

/// @nodoc


class _SpendingBreakdown extends SpendingBreakdown {
  const _SpendingBreakdown({required final  List<SpendingShare> shares, required this.total}): _shares = shares,super._();
  

 final  List<SpendingShare> _shares;
@override List<SpendingShare> get shares {
  if (_shares is EqualUnmodifiableListView) return _shares;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_shares);
}

@override final  Money total;

/// Create a copy of SpendingBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpendingBreakdownCopyWith<_SpendingBreakdown> get copyWith => __$SpendingBreakdownCopyWithImpl<_SpendingBreakdown>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpendingBreakdown&&const DeepCollectionEquality().equals(other._shares, _shares)&&(identical(other.total, total) || other.total == total));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_shares),total);

@override
String toString() {
  return 'SpendingBreakdown(shares: $shares, total: $total)';
}


}

/// @nodoc
abstract mixin class _$SpendingBreakdownCopyWith<$Res> implements $SpendingBreakdownCopyWith<$Res> {
  factory _$SpendingBreakdownCopyWith(_SpendingBreakdown value, $Res Function(_SpendingBreakdown) _then) = __$SpendingBreakdownCopyWithImpl;
@override @useResult
$Res call({
 List<SpendingShare> shares, Money total
});




}
/// @nodoc
class __$SpendingBreakdownCopyWithImpl<$Res>
    implements _$SpendingBreakdownCopyWith<$Res> {
  __$SpendingBreakdownCopyWithImpl(this._self, this._then);

  final _SpendingBreakdown _self;
  final $Res Function(_SpendingBreakdown) _then;

/// Create a copy of SpendingBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? shares = null,Object? total = null,}) {
  return _then(_SpendingBreakdown(
shares: null == shares ? _self._shares : shares // ignore: cast_nullable_to_non_nullable
as List<SpendingShare>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}


}

// dart format on
