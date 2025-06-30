part of 'due_report_notifier.dart';

enum DueReportStatus {
  initial,
  loading,
  success,
  error,
}

@freezed
class DueReportState with _$DueReportState {
  const factory DueReportState({
    @Default(DueReportStatus.initial) DueReportStatus status,
    @Default([]) List<Due> due,
    @Default('') String error,
    PlutoGridStateManager? stateManager,
    @Default('') String query,
    @Default(10) int pageSize,
    @Default(1) int pageNumber,
    @Default(0) int count,
    PagingController<int, Due>? pagingController,
    PagingController<int, Due>? salesDuePagingController,
    PagingController<int, Due>? purchaseDuePagingController,
    bool? salesOrPurchase,
    DateTime? fromDate,
    DateTime? toDate,
  }) = _DueReportState;

  factory DueReportState.initial() => const DueReportState();
}
