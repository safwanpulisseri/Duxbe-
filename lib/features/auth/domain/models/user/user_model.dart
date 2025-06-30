import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

enum Role { admin, staff, customer }

@freezed
class EmployeeModel with _$EmployeeModel {
  @JsonSerializable(explicitToJson: true) 
  const factory EmployeeModel({
    @JsonKey(name: 'employee_id') required String employeeId,
    required String email,
    required String name,
    @JsonKey(name: 'org_id') required String orgId,
    String? phone,
    String? code,
    String? image,
    Role? role,
    @Default([]) @JsonKey(name: 'employee_roles', includeToJson: false) List<EmployeeRoleModel> employeeRoles,
    @Default([]) @JsonKey(name: 'business_ids', includeToJson: false) List<String> businessIds,
    @Default([]) @JsonKey(name: 'employee_branches_view', includeToJson: false) List<EmployeeAccessModel> accessedBrances,
  }) = _EmployeeModel;

  factory EmployeeModel.fromJson(Map<String, dynamic> json) => _$EmployeeModelFromJson(json);
}

@freezed
class EmployeeAccessModel with _$EmployeeAccessModel {
  @JsonSerializable(explicitToJson: true) 
  const factory EmployeeAccessModel({
    @JsonKey(name: 'employee_id') required String employeeId,
    @JsonKey(name: 'business_id') required String businessId,
    @JsonKey(name: 'name') required String name,
  }) = _EmployeeAccessModel;

  factory EmployeeAccessModel.fromJson(Map<String, dynamic> json) => _$EmployeeAccessModelFromJson(json);
}

@freezed
class EmployeeRoleModel with _$EmployeeRoleModel {
  @JsonSerializable(explicitToJson: true) 
  const factory EmployeeRoleModel({
    @JsonKey(name: 'role_id') required String roleId,
    @JsonKey(name: 'role_name') required String name,
    @JsonKey(name: 'business_id') String? businessId,
  }) = _EmployeeRoleModel;

  factory EmployeeRoleModel.fromJson(Map<String, dynamic> json) => _$EmployeeRoleModelFromJson(json);
}
