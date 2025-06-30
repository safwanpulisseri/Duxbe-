import 'package:freezed_annotation/freezed_annotation.dart';

part 'unit_model.freezed.dart';
part 'unit_model.g.dart';

@freezed
class Unit with _$Unit {
  const factory Unit({
    @JsonKey(name: 'unit_id', includeIfNull: false) String? unitId,
    @Default('') String name,
    @JsonKey(name: 'short_name') String? shortName,
    @JsonKey(name: 'business_id', includeIfNull: false) String? businessId,
    @JsonKey(name: 'org_id', includeIfNull: false) String? orgId,
  }) = _Unit;

  factory Unit.fromJson(Map<String, dynamic> json) => _$UnitFromJson(json);
}
