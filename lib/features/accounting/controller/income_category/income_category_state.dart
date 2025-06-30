part of 'income_category_notifier.dart';

enum IncomeCategoryStatus {
  initial,
  loading,
  success,
  error,
}

@freezed
class IncomeCategoryState with _$IncomeCategoryState {
  const factory IncomeCategoryState({
    @Default(IncomeCategoryStatus.initial) IncomeCategoryStatus status,
    @Default([]) List<TransactionCategory> incomeCategories,
    @Default('') String error,
    PlutoGridStateManager? stateManager,
    @Default('') String query,
    @Default(10) int pageSize,
    @Default(1) int pageNumber,
    @Default(0) int count,
    PagingController<int, TransactionCategory>? pagingController,
  }) = _IncomeCategoryState;

  factory IncomeCategoryState.initial() => const IncomeCategoryState();
}
