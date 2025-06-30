part of 'sales_report_notifier.dart';

enum SalesReportStatus {
  initial,
  loading,
  success,
  error,
}

@freezed
class SalesReportState with _$SalesReportState {
  const factory SalesReportState({
    @Default(SalesReportStatus.initial) SalesReportStatus status,
    @Default([]) List<SaleView> sales,
    @Default('') String error,
    PlutoGridStateManager? stateManager,
    @Default('') String query,
    @Default(10) int pageSize,
    @Default(1) int pageNumber,
    @Default(0) int count,
    PagingController<int, SaleView>? pagingController,
    PagingController<int, SaleView>? paidPagingController,
    PagingController<int, SaleView>? duePagingController,
    DateTime? fromDate,
    DateTime? toDate,
    bool? paidOrDueList,
  }) = _SalesReportState;

  factory SalesReportState.initial() => const SalesReportState();
}
