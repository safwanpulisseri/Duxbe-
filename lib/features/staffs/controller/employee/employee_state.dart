part of 'employee_notifier.dart';

enum EmployeeStatus {
  initial,
  loading,
  success,
  error,
}

@freezed
class EmployeeState with _$EmployeeState {

  factory EmployeeState({
    @Default(EmployeeStatus.initial) EmployeeStatus status,
    @Default([]) List<EmployeeModel> staffs,
    @Default([]) List<StaffRole> staffRoles,
    @Default('') String error,
    PlutoGridStateManager? stateManager,
    @Default('') String query,
    @Default(10) int pageSize,
    @Default(1) int pageNumber,
    @Default(0) int count,
    PagingController<int, EmployeeModel>? pagingController,
  }) = _EmployeeState;
  EmployeeState._();

  factory EmployeeState.initial() => EmployeeState();

  bool get isLoading => status == EmployeeStatus.loading;
}
