import 'package:freezed_annotation/freezed_annotation.dart';

part 'staff_role_model.freezed.dart';
part 'staff_role_model.g.dart';

@freezed
class StaffRole with _$StaffRole {
  const factory StaffRole({
    required String name,
    @JsonKey(name: 'employee_role_id', includeIfNull: false) String? employeeRoleId,
    @JsonKey(name: 'business_id') String? businessId,
    String? description,
    @Default(false) bool editable,
  }) = _StaffRole;

  factory StaffRole.fromJson(Map<String, dynamic> json) => _$StaffRoleFromJson(json);
}
