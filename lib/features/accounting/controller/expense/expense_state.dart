part of 'expense_notifier.dart';

enum ExpenseStatus {
  initial,
  loading,
  success,
  error,
}

@freezed
class ExpenseState with _$ExpenseState {
  const factory ExpenseState({
    @Default(ExpenseStatus.initial) ExpenseStatus status,
    @Default([]) List<Expense> expenses,
    @Default('') String error,
    PlutoGridStateManager? stateManager,
    @Default('') String query,
    @Default(10) int pageSize,
    @Default(1) int pageNumber,
    @Default(0) int count,
    PagingController<int, Expense>? pagingController,
    DateTime? fromDate,
    DateTime? toDate,
    @Default(0) num totalAmount,
  }) = _ExpenseState;

  factory ExpenseState.initial() => const ExpenseState();
}
