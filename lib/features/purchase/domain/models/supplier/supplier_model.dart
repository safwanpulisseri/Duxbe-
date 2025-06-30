import 'package:freezed_annotation/freezed_annotation.dart';

part 'supplier_model.freezed.dart';
part 'supplier_model.g.dart';

@freezed
class Supplier with _$Supplier {
  const factory Supplier({
    required String name,
    required String phone,
    @JsonKey(name: 'supplier_id', includeIfNull: false) String? supplierId,
    String? email,
    String? address,
    String? image,
    @Default(0) @JsonKey(name: 'supplier_balance') double supplierBalance,
    @JsonKey(name: 'gst_number') String? gstNumber,
    @JsonKey(name: 'business_id', includeIfNull: false) String? businessId,
    @JsonKey(name: 'org_id', includeIfNull: false) String? orgId,
  }) = _Supplier;

  factory Supplier.fromJson(Map<String, dynamic> json) => _$SupplierFromJson(json);
}
