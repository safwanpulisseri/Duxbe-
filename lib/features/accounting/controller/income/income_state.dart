part of 'income_notifier.dart';

enum IncomeStatus {
  initial,
  loading,
  success,
  error,
}

@freezed
class IncomeState with _$IncomeState {
  const factory IncomeState({
    @Default(IncomeStatus.initial) IncomeStatus status,
    @Default([]) List<Income> incomes,
    @Default('') String error,
    PlutoGridStateManager? stateManager,
    @Default('') String query,
    @Default(10) int pageSize,
    @Default(1) int pageNumber,
    @Default(0) int count,
    DateTime? fromDate,
    DateTime? toDate,
    @Default(0) double totalAmount,
    PagingController<int, Income>? pagingController,
  }) = _IncomeState;

  factory IncomeState.initial() => const IncomeState();
}
