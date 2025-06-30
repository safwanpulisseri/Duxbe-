import 'package:freezed_annotation/freezed_annotation.dart';

part 'brand_model.freezed.dart';
part 'brand_model.g.dart';

@freezed
class Brand with _$Brand {
  const factory Brand({
    @JsonKey(name: 'brand_id', includeIfNull: false) String? brandId,
    @Default('') String name,
    String? description,
    @JsonKey(name: 'business_id', includeIfNull: false) String? businessId,
    @JsonKey(name: 'org_id', includeIfNull: false) String? orgId,
  }) = _Brand;

  factory Brand.fromJson(Map<String, dynamic> json) => _$BrandFromJson(json);
}
