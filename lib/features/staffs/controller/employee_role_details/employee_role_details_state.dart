part of 'employee_role_details_notifier.dart';

enum EmployeeRoleDetailsStatus {
  initial,
  loading,
  success,
  error,
}

@freezed
class EmployeeRoleDetailsState with _$EmployeeRoleDetailsState {
  const factory EmployeeRoleDetailsState({
    @Default(EmployeeRoleDetailsStatus.initial) EmployeeRoleDetailsStatus status,
    @Default([]) List<Module> modules,
    @Default('') String error,
  }) = _EmployeeRoleDetailsState;

  factory EmployeeRoleDetailsState.initial() => const EmployeeRoleDetailsState();
}
