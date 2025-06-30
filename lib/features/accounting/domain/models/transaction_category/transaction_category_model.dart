import 'package:duxbe/shared/shared.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_category_model.freezed.dart';
part 'transaction_category_model.g.dart';

@freezed
class TransactionCategory with _$TransactionCategory {
  const factory TransactionCategory({
    required String name,
    String? description,
    @JsonKey(name: 'category_id', includeIfNull: false) String? categoryId,
    @JsonKey(name: 'icon_info') IconInfo? iconInfo,
    @JsonKey(name: 'business_id', includeIfNull: false) String? businessId,
  }) = _TransactionCategory;

  factory TransactionCategory.fromJson(Map<String, dynamic> json) => _$TransactionCategoryFromJson(json);
}
