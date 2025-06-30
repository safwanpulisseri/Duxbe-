part of 'purchase_report_notifier.dart';

enum PurchaseReportStatus {
  initial,
  loading,
  success,
  error,
}

@freezed
class PurchaseReportState with _$PurchaseReportState {
  const factory PurchaseReportState({
    @Default(PurchaseReportStatus.initial) PurchaseReportStatus status,
    @Default([]) List<PurchaseView> purchases,
    @Default('') String error,
    PlutoGridStateManager? stateManager,
    @Default('') String query,
    @Default(10) int pageSize,
    @Default(1) int pageNumber,
    @Default(0) int count,
    PagingController<int, PurchaseView>? pagingController,
    PagingController<int, PurchaseView>? paidPagingController,
    PagingController<int, PurchaseView>? duePagingController,
    DateTime? fromDate,
    DateTime? toDate,
    bool? paidOrDueList,
  }) = _PurchaseReportState;

  factory PurchaseReportState.initial() => const PurchaseReportState();
}
