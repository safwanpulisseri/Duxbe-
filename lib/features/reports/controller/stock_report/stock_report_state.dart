part of 'stock_report_notifier.dart';

enum StockReportStatus {
  initial,
  loading,
  success,
  error,
}

@freezed
class StockReportState with _$StockReportState {
  const factory StockReportState({
    @Default(StockReportStatus.initial) StockReportStatus status,
    @Default([]) List<Item> items,
    @Default('') String error,
    PlutoGridStateManager? stateManager,
    @Default('') String query,
    @Default(10) int pageSize,
    @Default(1) int pageNumber,
    @Default(0) int count,
    PagingController<int, Item>? pagingController,
    PagingController<int, Item>? inStockPagingController,
    PagingController<int, Item>? outOfStockPagingController,
    PagingController<int, Item>? lowStockPagingController,
    @Default(null) String? stockStatus,
  }) = _StockReportState;

  factory StockReportState.initial() => const StockReportState();
}
