// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget_overview.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BudgetOverview {

 BudgetProgress? get overall; List<BudgetProgress> get categories;
/// Create a copy of BudgetOverview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetOverviewCopyWith<BudgetOverview> get copyWith => _$BudgetOverviewCopyWithImpl<BudgetOverview>(this as BudgetOverview, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetOverview&&(identical(other.overall, overall) || other.overall == overall)&&const DeepCollectionEquality().equals(other.categories, categories));
}


@override
int get hashCode => Object.hash(runtimeType,overall,const DeepCollectionEquality().hash(categories));

@override
String toString() {
  return 'BudgetOverview(overall: $overall, categories: $categories)';
}


}

/// @nodoc
abstract mixin class $BudgetOverviewCopyWith<$Res>  {
  factory $BudgetOverviewCopyWith(BudgetOverview value, $Res Function(BudgetOverview) _then) = _$BudgetOverviewCopyWithImpl;
@useResult
$Res call({
 BudgetProgress? overall, List<BudgetProgress> categories
});


$BudgetProgressCopyWith<$Res>? get overall;

}
/// @nodoc
class _$BudgetOverviewCopyWithImpl<$Res>
    implements $BudgetOverviewCopyWith<$Res> {
  _$BudgetOverviewCopyWithImpl(this._self, this._then);

  final BudgetOverview _self;
  final $Res Function(BudgetOverview) _then;

/// Create a copy of BudgetOverview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? overall = freezed,Object? categories = null,}) {
  return _then(_self.copyWith(
overall: freezed == overall ? _self.overall : overall // ignore: cast_nullable_to_non_nullable
as BudgetProgress?,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<BudgetProgress>,
  ));
}
/// Create a copy of BudgetOverview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BudgetProgressCopyWith<$Res>? get overall {
    if (_self.overall == null) {
    return null;
  }

  return $BudgetProgressCopyWith<$Res>(_self.overall!, (value) {
    return _then(_self.copyWith(overall: value));
  });
}
}


/// Adds pattern-matching-related methods to [BudgetOverview].
extension BudgetOverviewPatterns on BudgetOverview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetOverview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetOverview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetOverview value)  $default,){
final _that = this;
switch (_that) {
case _BudgetOverview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetOverview value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetOverview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BudgetProgress? overall,  List<BudgetProgress> categories)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetOverview() when $default != null:
return $default(_that.overall,_that.categories);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BudgetProgress? overall,  List<BudgetProgress> categories)  $default,) {final _that = this;
switch (_that) {
case _BudgetOverview():
return $default(_that.overall,_that.categories);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BudgetProgress? overall,  List<BudgetProgress> categories)?  $default,) {final _that = this;
switch (_that) {
case _BudgetOverview() when $default != null:
return $default(_that.overall,_that.categories);case _:
  return null;

}
}

}

/// @nodoc


class _BudgetOverview extends BudgetOverview {
  const _BudgetOverview({this.overall, final  List<BudgetProgress> categories = const <BudgetProgress>[]}): _categories = categories,super._();
  

@override final  BudgetProgress? overall;
 final  List<BudgetProgress> _categories;
@override@JsonKey() List<BudgetProgress> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}


/// Create a copy of BudgetOverview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetOverviewCopyWith<_BudgetOverview> get copyWith => __$BudgetOverviewCopyWithImpl<_BudgetOverview>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetOverview&&(identical(other.overall, overall) || other.overall == overall)&&const DeepCollectionEquality().equals(other._categories, _categories));
}


@override
int get hashCode => Object.hash(runtimeType,overall,const DeepCollectionEquality().hash(_categories));

@override
String toString() {
  return 'BudgetOverview(overall: $overall, categories: $categories)';
}


}

/// @nodoc
abstract mixin class _$BudgetOverviewCopyWith<$Res> implements $BudgetOverviewCopyWith<$Res> {
  factory _$BudgetOverviewCopyWith(_BudgetOverview value, $Res Function(_BudgetOverview) _then) = __$BudgetOverviewCopyWithImpl;
@override @useResult
$Res call({
 BudgetProgress? overall, List<BudgetProgress> categories
});


@override $BudgetProgressCopyWith<$Res>? get overall;

}
/// @nodoc
class __$BudgetOverviewCopyWithImpl<$Res>
    implements _$BudgetOverviewCopyWith<$Res> {
  __$BudgetOverviewCopyWithImpl(this._self, this._then);

  final _BudgetOverview _self;
  final $Res Function(_BudgetOverview) _then;

/// Create a copy of BudgetOverview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? overall = freezed,Object? categories = null,}) {
  return _then(_BudgetOverview(
overall: freezed == overall ? _self.overall : overall // ignore: cast_nullable_to_non_nullable
as BudgetProgress?,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<BudgetProgress>,
  ));
}

/// Create a copy of BudgetOverview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BudgetProgressCopyWith<$Res>? get overall {
    if (_self.overall == null) {
    return null;
  }

  return $BudgetProgressCopyWith<$Res>(_self.overall!, (value) {
    return _then(_self.copyWith(overall: value));
  });
}
}

// dart format on
