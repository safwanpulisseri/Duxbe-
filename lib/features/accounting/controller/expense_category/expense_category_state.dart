part of 'expense_category_notifier.dart';

enum ExpenseCategoryStatus {
  initial,
  loading,
  success,
  error,
}

@freezed
class ExpenseCategoryState with _$ExpenseCategoryState {
  const factory ExpenseCategoryState({
    @Default(ExpenseCategoryStatus.initial) ExpenseCategoryStatus status,
    @Default([]) List<TransactionCategory> expenseCategories,
    @Default('') String error,
    PlutoGridStateManager? stateManager,
    @Default('') String query,
    @Default(10) int pageSize,
    @Default(1) int pageNumber,
    @Default(0) int count,
    PagingController<int, TransactionCategory>? pagingController,
  }) = _ExpenseCategoryState;

  factory ExpenseCategoryState.initial() => const ExpenseCategoryState();
}
