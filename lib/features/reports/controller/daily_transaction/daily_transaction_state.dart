part of 'daily_transaction_notifier.dart';

enum DailyTransactionStatus {
  initial,
  loading,
  success,
  error,
}

@freezed
class DailyTransactionState with _$DailyTransactionState {
  const factory DailyTransactionState({
    @Default(DailyTransactionStatus.initial) DailyTransactionStatus status,
    @Default([]) List<DailyTransaction> dailyTransactions,
    @Default('') String error,
    PlutoGridStateManager? stateManager,
    @Default('') String query,
    @Default(10) int pageSize,
    @Default(1) int pageNumber,
    @Default(0) int count,
    DateTime? fromDate,
    DateTime? toDate,
    PagingController<int, DailyTransaction>? pagingController,
    PagingController<int, DailyTransaction>? payInPagingController,
    PagingController<int, DailyTransaction>? payOutPagingController,
  }) = _DailyTransactionState;

  factory DailyTransactionState.initial() => const DailyTransactionState();
}
