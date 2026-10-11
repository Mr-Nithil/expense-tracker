// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'goal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Goal {

 String get id; String get name; Money get target;/// Date-only (local midnight); `null` without a deadline.
 DateTime? get deadlineOn;/// Icon key (`CategoryIcon` keys).
 String get icon;/// ARGB color value.
 int get color; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of Goal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoalCopyWith<Goal> get copyWith => _$GoalCopyWithImpl<Goal>(this as Goal, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Goal&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.target, target) || other.target == target)&&(identical(other.deadlineOn, deadlineOn) || other.deadlineOn == deadlineOn)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,target,deadlineOn,icon,color,createdAt,updatedAt);

@override
String toString() {
  return 'Goal(id: $id, name: $name, target: $target, deadlineOn: $deadlineOn, icon: $icon, color: $color, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $GoalCopyWith<$Res>  {
  factory $GoalCopyWith(Goal value, $Res Function(Goal) _then) = _$GoalCopyWithImpl;
@useResult
$Res call({
 String id, String name, Money target, DateTime? deadlineOn, String icon, int color, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$GoalCopyWithImpl<$Res>
    implements $GoalCopyWith<$Res> {
  _$GoalCopyWithImpl(this._self, this._then);

  final Goal _self;
  final $Res Function(Goal) _then;

/// Create a copy of Goal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? target = null,Object? deadlineOn = freezed,Object? icon = null,Object? color = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as Money,deadlineOn: freezed == deadlineOn ? _self.deadlineOn : deadlineOn // ignore: cast_nullable_to_non_nullable
as DateTime?,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Goal].
extension GoalPatterns on Goal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Goal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Goal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Goal value)  $default,){
final _that = this;
switch (_that) {
case _Goal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Goal value)?  $default,){
final _that = this;
switch (_that) {
case _Goal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  Money target,  DateTime? deadlineOn,  String icon,  int color,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Goal() when $default != null:
return $default(_that.id,_that.name,_that.target,_that.deadlineOn,_that.icon,_that.color,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  Money target,  DateTime? deadlineOn,  String icon,  int color,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Goal():
return $default(_that.id,_that.name,_that.target,_that.deadlineOn,_that.icon,_that.color,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  Money target,  DateTime? deadlineOn,  String icon,  int color,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Goal() when $default != null:
return $default(_that.id,_that.name,_that.target,_that.deadlineOn,_that.icon,_that.color,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Goal implements Goal {
  const _Goal({required this.id, required this.name, required this.target, this.deadlineOn, required this.icon, required this.color, required this.createdAt, required this.updatedAt});
  

@override final  String id;
@override final  String name;
@override final  Money target;
/// Date-only (local midnight); `null` without a deadline.
@override final  DateTime? deadlineOn;
/// Icon key (`CategoryIcon` keys).
@override final  String icon;
/// ARGB color value.
@override final  int color;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of Goal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoalCopyWith<_Goal> get copyWith => __$GoalCopyWithImpl<_Goal>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Goal&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.target, target) || other.target == target)&&(identical(other.deadlineOn, deadlineOn) || other.deadlineOn == deadlineOn)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,target,deadlineOn,icon,color,createdAt,updatedAt);

@override
String toString() {
  return 'Goal(id: $id, name: $name, target: $target, deadlineOn: $deadlineOn, icon: $icon, color: $color, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$GoalCopyWith<$Res> implements $GoalCopyWith<$Res> {
  factory _$GoalCopyWith(_Goal value, $Res Function(_Goal) _then) = __$GoalCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, Money target, DateTime? deadlineOn, String icon, int color, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$GoalCopyWithImpl<$Res>
    implements _$GoalCopyWith<$Res> {
  __$GoalCopyWithImpl(this._self, this._then);

  final _Goal _self;
  final $Res Function(_Goal) _then;

/// Create a copy of Goal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? target = null,Object? deadlineOn = freezed,Object? icon = null,Object? color = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Goal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as Money,deadlineOn: freezed == deadlineOn ? _self.deadlineOn : deadlineOn // ignore: cast_nullable_to_non_nullable
as DateTime?,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$GoalDraft {

 String get name; Money get target; DateTime? get deadlineOn; String get icon; int get color;
/// Create a copy of GoalDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoalDraftCopyWith<GoalDraft> get copyWith => _$GoalDraftCopyWithImpl<GoalDraft>(this as GoalDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoalDraft&&(identical(other.name, name) || other.name == name)&&(identical(other.target, target) || other.target == target)&&(identical(other.deadlineOn, deadlineOn) || other.deadlineOn == deadlineOn)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color));
}


@override
int get hashCode => Object.hash(runtimeType,name,target,deadlineOn,icon,color);

@override
String toString() {
  return 'GoalDraft(name: $name, target: $target, deadlineOn: $deadlineOn, icon: $icon, color: $color)';
}


}

/// @nodoc
abstract mixin class $GoalDraftCopyWith<$Res>  {
  factory $GoalDraftCopyWith(GoalDraft value, $Res Function(GoalDraft) _then) = _$GoalDraftCopyWithImpl;
@useResult
$Res call({
 String name, Money target, DateTime? deadlineOn, String icon, int color
});




}
/// @nodoc
class _$GoalDraftCopyWithImpl<$Res>
    implements $GoalDraftCopyWith<$Res> {
  _$GoalDraftCopyWithImpl(this._self, this._then);

  final GoalDraft _self;
  final $Res Function(GoalDraft) _then;

/// Create a copy of GoalDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? target = null,Object? deadlineOn = freezed,Object? icon = null,Object? color = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as Money,deadlineOn: freezed == deadlineOn ? _self.deadlineOn : deadlineOn // ignore: cast_nullable_to_non_nullable
as DateTime?,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GoalDraft].
extension GoalDraftPatterns on GoalDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoalDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoalDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoalDraft value)  $default,){
final _that = this;
switch (_that) {
case _GoalDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoalDraft value)?  $default,){
final _that = this;
switch (_that) {
case _GoalDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  Money target,  DateTime? deadlineOn,  String icon,  int color)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoalDraft() when $default != null:
return $default(_that.name,_that.target,_that.deadlineOn,_that.icon,_that.color);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  Money target,  DateTime? deadlineOn,  String icon,  int color)  $default,) {final _that = this;
switch (_that) {
case _GoalDraft():
return $default(_that.name,_that.target,_that.deadlineOn,_that.icon,_that.color);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  Money target,  DateTime? deadlineOn,  String icon,  int color)?  $default,) {final _that = this;
switch (_that) {
case _GoalDraft() when $default != null:
return $default(_that.name,_that.target,_that.deadlineOn,_that.icon,_that.color);case _:
  return null;

}
}

}

/// @nodoc


class _GoalDraft implements GoalDraft {
  const _GoalDraft({required this.name, required this.target, this.deadlineOn, required this.icon, required this.color});
  

@override final  String name;
@override final  Money target;
@override final  DateTime? deadlineOn;
@override final  String icon;
@override final  int color;

/// Create a copy of GoalDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoalDraftCopyWith<_GoalDraft> get copyWith => __$GoalDraftCopyWithImpl<_GoalDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoalDraft&&(identical(other.name, name) || other.name == name)&&(identical(other.target, target) || other.target == target)&&(identical(other.deadlineOn, deadlineOn) || other.deadlineOn == deadlineOn)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color));
}


@override
int get hashCode => Object.hash(runtimeType,name,target,deadlineOn,icon,color);

@override
String toString() {
  return 'GoalDraft(name: $name, target: $target, deadlineOn: $deadlineOn, icon: $icon, color: $color)';
}


}

/// @nodoc
abstract mixin class _$GoalDraftCopyWith<$Res> implements $GoalDraftCopyWith<$Res> {
  factory _$GoalDraftCopyWith(_GoalDraft value, $Res Function(_GoalDraft) _then) = __$GoalDraftCopyWithImpl;
@override @useResult
$Res call({
 String name, Money target, DateTime? deadlineOn, String icon, int color
});




}
/// @nodoc
class __$GoalDraftCopyWithImpl<$Res>
    implements _$GoalDraftCopyWith<$Res> {
  __$GoalDraftCopyWithImpl(this._self, this._then);

  final _GoalDraft _self;
  final $Res Function(_GoalDraft) _then;

/// Create a copy of GoalDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? target = null,Object? deadlineOn = freezed,Object? icon = null,Object? color = null,}) {
  return _then(_GoalDraft(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as Money,deadlineOn: freezed == deadlineOn ? _self.deadlineOn : deadlineOn // ignore: cast_nullable_to_non_nullable
as DateTime?,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
