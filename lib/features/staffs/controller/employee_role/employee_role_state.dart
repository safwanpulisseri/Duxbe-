part of 'employee_role_notifier.dart';

enum EmployeeRoleStatus {
  initial,
  loading,
  success,
  error,
}

@freezed
class EmployeeRoleState with _$EmployeeRoleState {
  const factory EmployeeRoleState({
    @Default(EmployeeRoleStatus.initial) EmployeeRoleStatus status,
    @Default([]) List<StaffRole> staffRoles,
    @Default('') String error,
    PlutoGridStateManager? stateManager,
    @Default('') String query,
    @Default(10) int pageSize,
    @Default(1) int pageNumber,
    @Default(0) int count,
    PagingController<int, StaffRole>? pagingController,
  }) = _EmployeeRoleState;

  factory EmployeeRoleState.initial() => const EmployeeRoleState();
}
