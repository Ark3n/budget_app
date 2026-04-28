// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TransactionModel {

@HiveField(0) String get id;@HiveField(1)@JsonKey(name: 'user_id') String get userId;@HiveField(2) double get amount;@HiveField(3) TransactionType get type;@HiveField(4)@JsonKey(name: 'category_id') String? get categoryId;@HiveField(5) String? get description;@HiveField(6) DateTime get date;// 👈 дата операции
@HiveField(7)@JsonKey(name: 'created_at') DateTime get createdAt;@HiveField(8)@JsonKey(name: 'account_id') String get accountId;
/// Create a copy of TransactionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionModelCopyWith<TransactionModel> get copyWith => _$TransactionModelCopyWithImpl<TransactionModel>(this as TransactionModel, _$identity);

  /// Serializes this TransactionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.type, type) || other.type == type)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.description, description) || other.description == description)&&(identical(other.date, date) || other.date == date)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.accountId, accountId) || other.accountId == accountId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,amount,type,categoryId,description,date,createdAt,accountId);

@override
String toString() {
  return 'TransactionModel(id: $id, userId: $userId, amount: $amount, type: $type, categoryId: $categoryId, description: $description, date: $date, createdAt: $createdAt, accountId: $accountId)';
}


}

/// @nodoc
abstract mixin class $TransactionModelCopyWith<$Res>  {
  factory $TransactionModelCopyWith(TransactionModel value, $Res Function(TransactionModel) _then) = _$TransactionModelCopyWithImpl;
@useResult
$Res call({
@HiveField(0) String id,@HiveField(1)@JsonKey(name: 'user_id') String userId,@HiveField(2) double amount,@HiveField(3) TransactionType type,@HiveField(4)@JsonKey(name: 'category_id') String? categoryId,@HiveField(5) String? description,@HiveField(6) DateTime date,@HiveField(7)@JsonKey(name: 'created_at') DateTime createdAt,@HiveField(8)@JsonKey(name: 'account_id') String accountId
});




}
/// @nodoc
class _$TransactionModelCopyWithImpl<$Res>
    implements $TransactionModelCopyWith<$Res> {
  _$TransactionModelCopyWithImpl(this._self, this._then);

  final TransactionModel _self;
  final $Res Function(TransactionModel) _then;

/// Create a copy of TransactionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? amount = null,Object? type = null,Object? categoryId = freezed,Object? description = freezed,Object? date = null,Object? createdAt = null,Object? accountId = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionModel].
extension TransactionModelPatterns on TransactionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionModel value)  $default,){
final _that = this;
switch (_that) {
case _TransactionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionModel value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@HiveField(0)  String id, @HiveField(1)@JsonKey(name: 'user_id')  String userId, @HiveField(2)  double amount, @HiveField(3)  TransactionType type, @HiveField(4)@JsonKey(name: 'category_id')  String? categoryId, @HiveField(5)  String? description, @HiveField(6)  DateTime date, @HiveField(7)@JsonKey(name: 'created_at')  DateTime createdAt, @HiveField(8)@JsonKey(name: 'account_id')  String accountId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionModel() when $default != null:
return $default(_that.id,_that.userId,_that.amount,_that.type,_that.categoryId,_that.description,_that.date,_that.createdAt,_that.accountId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@HiveField(0)  String id, @HiveField(1)@JsonKey(name: 'user_id')  String userId, @HiveField(2)  double amount, @HiveField(3)  TransactionType type, @HiveField(4)@JsonKey(name: 'category_id')  String? categoryId, @HiveField(5)  String? description, @HiveField(6)  DateTime date, @HiveField(7)@JsonKey(name: 'created_at')  DateTime createdAt, @HiveField(8)@JsonKey(name: 'account_id')  String accountId)  $default,) {final _that = this;
switch (_that) {
case _TransactionModel():
return $default(_that.id,_that.userId,_that.amount,_that.type,_that.categoryId,_that.description,_that.date,_that.createdAt,_that.accountId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@HiveField(0)  String id, @HiveField(1)@JsonKey(name: 'user_id')  String userId, @HiveField(2)  double amount, @HiveField(3)  TransactionType type, @HiveField(4)@JsonKey(name: 'category_id')  String? categoryId, @HiveField(5)  String? description, @HiveField(6)  DateTime date, @HiveField(7)@JsonKey(name: 'created_at')  DateTime createdAt, @HiveField(8)@JsonKey(name: 'account_id')  String accountId)?  $default,) {final _that = this;
switch (_that) {
case _TransactionModel() when $default != null:
return $default(_that.id,_that.userId,_that.amount,_that.type,_that.categoryId,_that.description,_that.date,_that.createdAt,_that.accountId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TransactionModel extends TransactionModel {
  const _TransactionModel({@HiveField(0) required this.id, @HiveField(1)@JsonKey(name: 'user_id') required this.userId, @HiveField(2) required this.amount, @HiveField(3) required this.type, @HiveField(4)@JsonKey(name: 'category_id') this.categoryId, @HiveField(5) this.description, @HiveField(6) required this.date, @HiveField(7)@JsonKey(name: 'created_at') required this.createdAt, @HiveField(8)@JsonKey(name: 'account_id') required this.accountId}): super._();
  factory _TransactionModel.fromJson(Map<String, dynamic> json) => _$TransactionModelFromJson(json);

@override@HiveField(0) final  String id;
@override@HiveField(1)@JsonKey(name: 'user_id') final  String userId;
@override@HiveField(2) final  double amount;
@override@HiveField(3) final  TransactionType type;
@override@HiveField(4)@JsonKey(name: 'category_id') final  String? categoryId;
@override@HiveField(5) final  String? description;
@override@HiveField(6) final  DateTime date;
// 👈 дата операции
@override@HiveField(7)@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@HiveField(8)@JsonKey(name: 'account_id') final  String accountId;

/// Create a copy of TransactionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionModelCopyWith<_TransactionModel> get copyWith => __$TransactionModelCopyWithImpl<_TransactionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.type, type) || other.type == type)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.description, description) || other.description == description)&&(identical(other.date, date) || other.date == date)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.accountId, accountId) || other.accountId == accountId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,amount,type,categoryId,description,date,createdAt,accountId);

@override
String toString() {
  return 'TransactionModel(id: $id, userId: $userId, amount: $amount, type: $type, categoryId: $categoryId, description: $description, date: $date, createdAt: $createdAt, accountId: $accountId)';
}


}

/// @nodoc
abstract mixin class _$TransactionModelCopyWith<$Res> implements $TransactionModelCopyWith<$Res> {
  factory _$TransactionModelCopyWith(_TransactionModel value, $Res Function(_TransactionModel) _then) = __$TransactionModelCopyWithImpl;
@override @useResult
$Res call({
@HiveField(0) String id,@HiveField(1)@JsonKey(name: 'user_id') String userId,@HiveField(2) double amount,@HiveField(3) TransactionType type,@HiveField(4)@JsonKey(name: 'category_id') String? categoryId,@HiveField(5) String? description,@HiveField(6) DateTime date,@HiveField(7)@JsonKey(name: 'created_at') DateTime createdAt,@HiveField(8)@JsonKey(name: 'account_id') String accountId
});




}
/// @nodoc
class __$TransactionModelCopyWithImpl<$Res>
    implements _$TransactionModelCopyWith<$Res> {
  __$TransactionModelCopyWithImpl(this._self, this._then);

  final _TransactionModel _self;
  final $Res Function(_TransactionModel) _then;

/// Create a copy of TransactionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? amount = null,Object? type = null,Object? categoryId = freezed,Object? description = freezed,Object? date = null,Object? createdAt = null,Object? accountId = null,}) {
  return _then(_TransactionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
