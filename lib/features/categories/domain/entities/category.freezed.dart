// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Category {

 String get id; String get name;/// Icon key resolved by the UI (M2.6), not a code point.
 String get icon;/// ARGB color value.
 int get color; CategoryType get type; bool get isDefault; int get sortOrder; bool get isArchived; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryCopyWith<Category> get copyWith => _$CategoryCopyWithImpl<Category>(this as Category, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Category&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.type, type) || other.type == type)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,icon,color,type,isDefault,sortOrder,isArchived,createdAt,updatedAt);

@override
String toString() {
  return 'Category(id: $id, name: $name, icon: $icon, color: $color, type: $type, isDefault: $isDefault, sortOrder: $sortOrder, isArchived: $isArchived, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CategoryCopyWith<$Res>  {
  factory $CategoryCopyWith(Category value, $Res Function(Category) _then) = _$CategoryCopyWithImpl;
@useResult
$Res call({
 String id, String name, String icon, int color, CategoryType type, bool isDefault, int sortOrder, bool isArchived, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$CategoryCopyWithImpl<$Res>
    implements $CategoryCopyWith<$Res> {
  _$CategoryCopyWithImpl(this._self, this._then);

  final Category _self;
  final $Res Function(Category) _then;

/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? icon = null,Object? color = null,Object? type = null,Object? isDefault = null,Object? sortOrder = null,Object? isArchived = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CategoryType,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Category].
extension CategoryPatterns on Category {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Category value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Category() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Category value)  $default,){
final _that = this;
switch (_that) {
case _Category():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Category value)?  $default,){
final _that = this;
switch (_that) {
case _Category() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String icon,  int color,  CategoryType type,  bool isDefault,  int sortOrder,  bool isArchived,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Category() when $default != null:
return $default(_that.id,_that.name,_that.icon,_that.color,_that.type,_that.isDefault,_that.sortOrder,_that.isArchived,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String icon,  int color,  CategoryType type,  bool isDefault,  int sortOrder,  bool isArchived,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Category():
return $default(_that.id,_that.name,_that.icon,_that.color,_that.type,_that.isDefault,_that.sortOrder,_that.isArchived,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String icon,  int color,  CategoryType type,  bool isDefault,  int sortOrder,  bool isArchived,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Category() when $default != null:
return $default(_that.id,_that.name,_that.icon,_that.color,_that.type,_that.isDefault,_that.sortOrder,_that.isArchived,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Category implements Category {
  const _Category({required this.id, required this.name, required this.icon, required this.color, required this.type, required this.isDefault, required this.sortOrder, required this.isArchived, required this.createdAt, required this.updatedAt});
  

@override final  String id;
@override final  String name;
/// Icon key resolved by the UI (M2.6), not a code point.
@override final  String icon;
/// ARGB color value.
@override final  int color;
@override final  CategoryType type;
@override final  bool isDefault;
@override final  int sortOrder;
@override final  bool isArchived;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryCopyWith<_Category> get copyWith => __$CategoryCopyWithImpl<_Category>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Category&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.type, type) || other.type == type)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,icon,color,type,isDefault,sortOrder,isArchived,createdAt,updatedAt);

@override
String toString() {
  return 'Category(id: $id, name: $name, icon: $icon, color: $color, type: $type, isDefault: $isDefault, sortOrder: $sortOrder, isArchived: $isArchived, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CategoryCopyWith<$Res> implements $CategoryCopyWith<$Res> {
  factory _$CategoryCopyWith(_Category value, $Res Function(_Category) _then) = __$CategoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String icon, int color, CategoryType type, bool isDefault, int sortOrder, bool isArchived, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$CategoryCopyWithImpl<$Res>
    implements _$CategoryCopyWith<$Res> {
  __$CategoryCopyWithImpl(this._self, this._then);

  final _Category _self;
  final $Res Function(_Category) _then;

/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? icon = null,Object? color = null,Object? type = null,Object? isDefault = null,Object? sortOrder = null,Object? isArchived = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Category(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CategoryType,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$CategoryDraft {

 String get name; String get icon; int get color; CategoryType get type;
/// Create a copy of CategoryDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryDraftCopyWith<CategoryDraft> get copyWith => _$CategoryDraftCopyWithImpl<CategoryDraft>(this as CategoryDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryDraft&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode => Object.hash(runtimeType,name,icon,color,type);

@override
String toString() {
  return 'CategoryDraft(name: $name, icon: $icon, color: $color, type: $type)';
}


}

/// @nodoc
abstract mixin class $CategoryDraftCopyWith<$Res>  {
  factory $CategoryDraftCopyWith(CategoryDraft value, $Res Function(CategoryDraft) _then) = _$CategoryDraftCopyWithImpl;
@useResult
$Res call({
 String name, String icon, int color, CategoryType type
});




}
/// @nodoc
class _$CategoryDraftCopyWithImpl<$Res>
    implements $CategoryDraftCopyWith<$Res> {
  _$CategoryDraftCopyWithImpl(this._self, this._then);

  final CategoryDraft _self;
  final $Res Function(CategoryDraft) _then;

/// Create a copy of CategoryDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? icon = null,Object? color = null,Object? type = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CategoryType,
  ));
}

}


/// Adds pattern-matching-related methods to [CategoryDraft].
extension CategoryDraftPatterns on CategoryDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryDraft value)  $default,){
final _that = this;
switch (_that) {
case _CategoryDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryDraft value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String icon,  int color,  CategoryType type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryDraft() when $default != null:
return $default(_that.name,_that.icon,_that.color,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String icon,  int color,  CategoryType type)  $default,) {final _that = this;
switch (_that) {
case _CategoryDraft():
return $default(_that.name,_that.icon,_that.color,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String icon,  int color,  CategoryType type)?  $default,) {final _that = this;
switch (_that) {
case _CategoryDraft() when $default != null:
return $default(_that.name,_that.icon,_that.color,_that.type);case _:
  return null;

}
}

}

/// @nodoc


class _CategoryDraft implements CategoryDraft {
  const _CategoryDraft({required this.name, required this.icon, required this.color, required this.type});
  

@override final  String name;
@override final  String icon;
@override final  int color;
@override final  CategoryType type;

/// Create a copy of CategoryDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryDraftCopyWith<_CategoryDraft> get copyWith => __$CategoryDraftCopyWithImpl<_CategoryDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryDraft&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode => Object.hash(runtimeType,name,icon,color,type);

@override
String toString() {
  return 'CategoryDraft(name: $name, icon: $icon, color: $color, type: $type)';
}


}

/// @nodoc
abstract mixin class _$CategoryDraftCopyWith<$Res> implements $CategoryDraftCopyWith<$Res> {
  factory _$CategoryDraftCopyWith(_CategoryDraft value, $Res Function(_CategoryDraft) _then) = __$CategoryDraftCopyWithImpl;
@override @useResult
$Res call({
 String name, String icon, int color, CategoryType type
});




}
/// @nodoc
class __$CategoryDraftCopyWithImpl<$Res>
    implements _$CategoryDraftCopyWith<$Res> {
  __$CategoryDraftCopyWithImpl(this._self, this._then);

  final _CategoryDraft _self;
  final $Res Function(_CategoryDraft) _then;

/// Create a copy of CategoryDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? icon = null,Object? color = null,Object? type = null,}) {
  return _then(_CategoryDraft(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CategoryType,
  ));
}


}

// dart format on
