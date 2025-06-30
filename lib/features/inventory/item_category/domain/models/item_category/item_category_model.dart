import 'package:duxbe/shared/shared.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'item_category_model.freezed.dart';
part 'item_category_model.g.dart';

@freezed
class ItemCategory with _$ItemCategory {
  @JsonSerializable(explicitToJson: true) 
  const factory ItemCategory({
    required String name,
    @JsonKey(name: 'item_category_id', includeIfNull: false) String? itemCategoryId,
    String? description,
    @JsonKey(name: 'icon_info') IconInfo? iconInfo,
    @JsonKey(name: 'business_id', includeIfNull: false) String? businessId,
    @JsonKey(name: 'org_id', includeIfNull: false) String? orgId,
  }) = _ItemCategory;

  factory ItemCategory.fromJson(Map<String, dynamic> json) => _$ItemCategoryFromJson(json);
}
