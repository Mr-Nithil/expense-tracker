// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Transaction {

 String get id; TransactionType get type; Money get amount; String get categoryId;/// Date-only (local midnight).
 DateTime get occurredOn; String? get note;/// Soft-deleted (only visible by id, e.g. for undo).
 bool get isDeleted; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionCopyWith<Transaction> get copyWith => _$TransactionCopyWithImpl<Transaction>(this as Transaction, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Transaction&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.occurredOn, occurredOn) || other.occurredOn == occurredOn)&&(identical(other.note, note) || other.note == note)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,type,amount,categoryId,occurredOn,note,isDeleted,createdAt,updatedAt);

@override
String toString() {
  return 'Transaction(id: $id, type: $type, amount: $amount, categoryId: $categoryId, occurredOn: $occurredOn, note: $note, isDeleted: $isDeleted, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $TransactionCopyWith<$Res>  {
  factory $TransactionCopyWith(Transaction value, $Res Function(Transaction) _then) = _$TransactionCopyWithImpl;
@useResult
$Res call({
 String id, TransactionType type, Money amount, String categoryId, DateTime occurredOn, String? note, bool isDeleted, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$TransactionCopyWithImpl<$Res>
    implements $TransactionCopyWith<$Res> {
  _$TransactionCopyWithImpl(this._self, this._then);

  final Transaction _self;
  final $Res Function(Transaction) _then;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? amount = null,Object? categoryId = null,Object? occurredOn = null,Object? note = freezed,Object? isDeleted = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Money,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,occurredOn: null == occurredOn ? _self.occurredOn : occurredOn // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Transaction].
extension TransactionPatterns on Transaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Transaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Transaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Transaction value)  $default,){
final _that = this;
switch (_that) {
case _Transaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Transaction value)?  $default,){
final _that = this;
switch (_that) {
case _Transaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  TransactionType type,  Money amount,  String categoryId,  DateTime occurredOn,  String? note,  bool isDeleted,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Transaction() when $default != null:
return $default(_that.id,_that.type,_that.amount,_that.categoryId,_that.occurredOn,_that.note,_that.isDeleted,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  TransactionType type,  Money amount,  String categoryId,  DateTime occurredOn,  String? note,  bool isDeleted,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Transaction():
return $default(_that.id,_that.type,_that.amount,_that.categoryId,_that.occurredOn,_that.note,_that.isDeleted,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  TransactionType type,  Money amount,  String categoryId,  DateTime occurredOn,  String? note,  bool isDeleted,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Transaction() when $default != null:
return $default(_that.id,_that.type,_that.amount,_that.categoryId,_that.occurredOn,_that.note,_that.isDeleted,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Transaction implements Transaction {
  const _Transaction({required this.id, required this.type, required this.amount, required this.categoryId, required this.occurredOn, this.note, required this.isDeleted, required this.createdAt, required this.updatedAt});
  

@override final  String id;
@override final  TransactionType type;
@override final  Money amount;
@override final  String categoryId;
/// Date-only (local midnight).
@override final  DateTime occurredOn;
@override final  String? note;
/// Soft-deleted (only visible by id, e.g. for undo).
@override final  bool isDeleted;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionCopyWith<_Transaction> get copyWith => __$TransactionCopyWithImpl<_Transaction>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Transaction&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.occurredOn, occurredOn) || other.occurredOn == occurredOn)&&(identical(other.note, note) || other.note == note)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,type,amount,categoryId,occurredOn,note,isDeleted,createdAt,updatedAt);

@override
String toString() {
  return 'Transaction(id: $id, type: $type, amount: $amount, categoryId: $categoryId, occurredOn: $occurredOn, note: $note, isDeleted: $isDeleted, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$TransactionCopyWith<$Res> implements $TransactionCopyWith<$Res> {
  factory _$TransactionCopyWith(_Transaction value, $Res Function(_Transaction) _then) = __$TransactionCopyWithImpl;
@override @useResult
$Res call({
 String id, TransactionType type, Money amount, String categoryId, DateTime occurredOn, String? note, bool isDeleted, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$TransactionCopyWithImpl<$Res>
    implements _$TransactionCopyWith<$Res> {
  __$TransactionCopyWithImpl(this._self, this._then);

  final _Transaction _self;
  final $Res Function(_Transaction) _then;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? amount = null,Object? categoryId = null,Object? occurredOn = null,Object? note = freezed,Object? isDeleted = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Transaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Money,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,occurredOn: null == occurredOn ? _self.occurredOn : occurredOn // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$TransactionDraft {

 TransactionType get type; Money get amount; String get categoryId; DateTime get occurredOn; String? get note;
/// Create a copy of TransactionDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionDraftCopyWith<TransactionDraft> get copyWith => _$TransactionDraftCopyWithImpl<TransactionDraft>(this as TransactionDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionDraft&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.occurredOn, occurredOn) || other.occurredOn == occurredOn)&&(identical(other.note, note) || other.note == note));
}


@override
int get hashCode => Object.hash(runtimeType,type,amount,categoryId,occurredOn,note);

@override
String toString() {
  return 'TransactionDraft(type: $type, amount: $amount, categoryId: $categoryId, occurredOn: $occurredOn, note: $note)';
}


}

/// @nodoc
abstract mixin class $TransactionDraftCopyWith<$Res>  {
  factory $TransactionDraftCopyWith(TransactionDraft value, $Res Function(TransactionDraft) _then) = _$TransactionDraftCopyWithImpl;
@useResult
$Res call({
 TransactionType type, Money amount, String categoryId, DateTime occurredOn, String? note
});




}
/// @nodoc
class _$TransactionDraftCopyWithImpl<$Res>
    implements $TransactionDraftCopyWith<$Res> {
  _$TransactionDraftCopyWithImpl(this._self, this._then);

  final TransactionDraft _self;
  final $Res Function(TransactionDraft) _then;

/// Create a copy of TransactionDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? amount = null,Object? categoryId = null,Object? occurredOn = null,Object? note = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Money,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,occurredOn: null == occurredOn ? _self.occurredOn : occurredOn // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionDraft].
extension TransactionDraftPatterns on TransactionDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionDraft value)  $default,){
final _that = this;
switch (_that) {
case _TransactionDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionDraft value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TransactionType type,  Money amount,  String categoryId,  DateTime occurredOn,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionDraft() when $default != null:
return $default(_that.type,_that.amount,_that.categoryId,_that.occurredOn,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TransactionType type,  Money amount,  String categoryId,  DateTime occurredOn,  String? note)  $default,) {final _that = this;
switch (_that) {
case _TransactionDraft():
return $default(_that.type,_that.amount,_that.categoryId,_that.occurredOn,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TransactionType type,  Money amount,  String categoryId,  DateTime occurredOn,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _TransactionDraft() when $default != null:
return $default(_that.type,_that.amount,_that.categoryId,_that.occurredOn,_that.note);case _:
  return null;

}
}

}

/// @nodoc


class _TransactionDraft implements TransactionDraft {
  const _TransactionDraft({required this.type, required this.amount, required this.categoryId, required this.occurredOn, this.note});
  

@override final  TransactionType type;
@override final  Money amount;
@override final  String categoryId;
@override final  DateTime occurredOn;
@override final  String? note;

/// Create a copy of TransactionDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionDraftCopyWith<_TransactionDraft> get copyWith => __$TransactionDraftCopyWithImpl<_TransactionDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionDraft&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.occurredOn, occurredOn) || other.occurredOn == occurredOn)&&(identical(other.note, note) || other.note == note));
}


@override
int get hashCode => Object.hash(runtimeType,type,amount,categoryId,occurredOn,note);

@override
String toString() {
  return 'TransactionDraft(type: $type, amount: $amount, categoryId: $categoryId, occurredOn: $occurredOn, note: $note)';
}


}

/// @nodoc
abstract mixin class _$TransactionDraftCopyWith<$Res> implements $TransactionDraftCopyWith<$Res> {
  factory _$TransactionDraftCopyWith(_TransactionDraft value, $Res Function(_TransactionDraft) _then) = __$TransactionDraftCopyWithImpl;
@override @useResult
$Res call({
 TransactionType type, Money amount, String categoryId, DateTime occurredOn, String? note
});




}
/// @nodoc
class __$TransactionDraftCopyWithImpl<$Res>
    implements _$TransactionDraftCopyWith<$Res> {
  __$TransactionDraftCopyWithImpl(this._self, this._then);

  final _TransactionDraft _self;
  final $Res Function(_TransactionDraft) _then;

/// Create a copy of TransactionDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? amount = null,Object? categoryId = null,Object? occurredOn = null,Object? note = freezed,}) {
  return _then(_TransactionDraft(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Money,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,occurredOn: null == occurredOn ? _self.occurredOn : occurredOn // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$TransactionFilter {

/// Any day in the month; only year and month are used.
 DateTime get month; TransactionType? get type; String? get categoryId;
/// Create a copy of TransactionFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionFilterCopyWith<TransactionFilter> get copyWith => _$TransactionFilterCopyWithImpl<TransactionFilter>(this as TransactionFilter, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionFilter&&(identical(other.month, month) || other.month == month)&&(identical(other.type, type) || other.type == type)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId));
}


@override
int get hashCode => Object.hash(runtimeType,month,type,categoryId);

@override
String toString() {
  return 'TransactionFilter(month: $month, type: $type, categoryId: $categoryId)';
}


}

/// @nodoc
abstract mixin class $TransactionFilterCopyWith<$Res>  {
  factory $TransactionFilterCopyWith(TransactionFilter value, $Res Function(TransactionFilter) _then) = _$TransactionFilterCopyWithImpl;
@useResult
$Res call({
 DateTime month, TransactionType? type, String? categoryId
});




}
/// @nodoc
class _$TransactionFilterCopyWithImpl<$Res>
    implements $TransactionFilterCopyWith<$Res> {
  _$TransactionFilterCopyWithImpl(this._self, this._then);

  final TransactionFilter _self;
  final $Res Function(TransactionFilter) _then;

/// Create a copy of TransactionFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? month = null,Object? type = freezed,Object? categoryId = freezed,}) {
  return _then(_self.copyWith(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as DateTime,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionFilter].
extension TransactionFilterPatterns on TransactionFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionFilter value)  $default,){
final _that = this;
switch (_that) {
case _TransactionFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionFilter value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime month,  TransactionType? type,  String? categoryId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionFilter() when $default != null:
return $default(_that.month,_that.type,_that.categoryId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime month,  TransactionType? type,  String? categoryId)  $default,) {final _that = this;
switch (_that) {
case _TransactionFilter():
return $default(_that.month,_that.type,_that.categoryId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime month,  TransactionType? type,  String? categoryId)?  $default,) {final _that = this;
switch (_that) {
case _TransactionFilter() when $default != null:
return $default(_that.month,_that.type,_that.categoryId);case _:
  return null;

}
}

}

/// @nodoc


class _TransactionFilter extends TransactionFilter {
  const _TransactionFilter({required this.month, this.type, this.categoryId}): super._();
  

/// Any day in the month; only year and month are used.
@override final  DateTime month;
@override final  TransactionType? type;
@override final  String? categoryId;

/// Create a copy of TransactionFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionFilterCopyWith<_TransactionFilter> get copyWith => __$TransactionFilterCopyWithImpl<_TransactionFilter>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionFilter&&(identical(other.month, month) || other.month == month)&&(identical(other.type, type) || other.type == type)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId));
}


@override
int get hashCode => Object.hash(runtimeType,month,type,categoryId);

@override
String toString() {
  return 'TransactionFilter(month: $month, type: $type, categoryId: $categoryId)';
}


}

/// @nodoc
abstract mixin class _$TransactionFilterCopyWith<$Res> implements $TransactionFilterCopyWith<$Res> {
  factory _$TransactionFilterCopyWith(_TransactionFilter value, $Res Function(_TransactionFilter) _then) = __$TransactionFilterCopyWithImpl;
@override @useResult
$Res call({
 DateTime month, TransactionType? type, String? categoryId
});




}
/// @nodoc
class __$TransactionFilterCopyWithImpl<$Res>
    implements _$TransactionFilterCopyWith<$Res> {
  __$TransactionFilterCopyWithImpl(this._self, this._then);

  final _TransactionFilter _self;
  final $Res Function(_TransactionFilter) _then;

/// Create a copy of TransactionFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? month = null,Object? type = freezed,Object? categoryId = freezed,}) {
  return _then(_TransactionFilter(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as DateTime,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
