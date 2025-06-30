import 'package:freezed_annotation/freezed_annotation.dart';

part 'chartofaccounts_model.freezed.dart';
part 'chartofaccounts_model.g.dart';

@freezed
class ChartOfAccounts with _$ChartOfAccounts {
  const factory ChartOfAccounts({
    @JsonKey(name: 'code') required String code,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'category_id') required String categoryId,
    @JsonKey(name: 'description') required String description,
    @JsonKey(name: 'children') @Default([]) List<Accounts> children,
  }) = _ChartOfAccounts;

  factory ChartOfAccounts.fromJson(Map<String, Object?> json) => _$ChartOfAccountsFromJson(json);
}

@freezed
class Accounts with _$Accounts {
  const factory Accounts({
    @JsonKey(name: 'code') required String code,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'balance') required int balance,
    @JsonKey(name: 'is_group') required bool isGroup,
    @JsonKey(name: 'account_id') required String accountId,
    @JsonKey(name: 'category_id') required String categoryId,
    @JsonKey(name: 'children') @Default([]) List<Accounts> children,
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'parent_account_id') String? parentAccountId,
  }) = _Accounts;

  factory Accounts.fromJson(Map<String, Object?> json) => _$AccountsFromJson(json);
}
