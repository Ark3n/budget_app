import 'package:budget_app/features/budget/domain/entities/account.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce/hive_ce.dart';
part 'account_model.freezed.dart';
part 'account_model.g.dart';

@freezed
@HiveType(typeId: 2)
abstract class AccountModel with _$AccountModel {
  const AccountModel._();
  const factory AccountModel({
    @HiveField(0) required String id,
    @HiveField(1) required String userId,
    @HiveField(2) required String name,
    @HiveField(3) required double balance,
    @HiveField(4) String? icon,
    @HiveField(5) String? color,
    @HiveField(6) required DateTime createdAt,
  }) = _AccountModel;

  factory AccountModel.fromJson(Map<String, dynamic> json) =>
      _$AccountModelFromJson(json);

  Account toEntity() {
    return Account(
      id: id,
      userId: userId,
      name: name,
      balance: balance,
      icon: icon,
      color: color,
      createdAt: createdAt,
    );
  }

  factory AccountModel.fromEntity(Account account) {
    return AccountModel(
      id: account.id,
      userId: account.userId,
      name: account.name,
      balance: account.balance,
      createdAt: account.createdAt,
    );
  }
}
