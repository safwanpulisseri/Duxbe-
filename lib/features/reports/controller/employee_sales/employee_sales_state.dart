part of 'employee_sales_notifier.dart';

enum EmployeeSalesStatus {
  initial,
  loading,
  success,
  error,
}

extension EmployeeSalesStatusExtension on EmployeeSalesStatus {
  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function() success,
    required R Function() error,
  }) {
    switch (this) {
      case EmployeeSalesStatus.initial:
        return initial();
      case EmployeeSalesStatus.loading:
        return loading();
      case EmployeeSalesStatus.success:
        return success();
      case EmployeeSalesStatus.error:
        return error();
    }
  }
}

@freezed
class EmployeeSalesState with _$EmployeeSalesState {
  const factory EmployeeSalesState({
    @Default(EmployeeSalesStatus.initial) EmployeeSalesStatus status,
    @Default([]) List<EmployeeSales> employeeSales,
    @Default('') String error,
    PlutoGridStateManager? stateManager,
    @Default('') String query,
    @Default(10) int pageSize,
    @Default(1) int pageNumber,
    @Default(0) int count,
    PagingController<int, EmployeeSales>? pagingController,
    DateTime? fromDate,
    DateTime? toDate,
  }) = _EmployeeSalesState;

  factory EmployeeSalesState.initial() => const EmployeeSalesState();
}
