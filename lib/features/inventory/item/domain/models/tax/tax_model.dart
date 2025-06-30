import 'package:freezed_annotation/freezed_annotation.dart';

part 'tax_model.freezed.dart';
part 'tax_model.g.dart';

@freezed
class Tax with _$Tax {
  factory Tax({
    required String name,
    required double rate,
    @JsonKey(name: 'tax_id', includeIfNull: false) String? taxId,
    @JsonKey(name: 'business_id', includeIfNull: false) String? businessId,
    String? type,
    @JsonKey(name: 'org_id', includeIfNull: false) String? orgId,
  }) = _Tax;

  Tax._();

  factory Tax.fromJson(Map<String, dynamic> json) => _$TaxFromJson(json);

  // @override
  // String toString() {
  //   final encoder = JsonEncoder.withIndent(' ' * 2);
  //   return encoder.convert(toJson());
  // }
}
