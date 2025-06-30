part of 'stock_adjustments_notifier.dart';

enum StockAdjustmentsStatus {
  initial,
  loading,
  success,
  error,
}

@freezed
class StockAdjustmentsState with _$StockAdjustmentsState {
  const factory StockAdjustmentsState({
    @Default(StockAdjustmentsStatus.initial) StockAdjustmentsStatus status,
    @Default([]) List<StockAdjustments> items,
    @Default('') String error,
    PlutoGridStateManager? stateManager,
    @Default('') String query,
    @Default(10) int pageSize,
    @Default(1) int pageNumber,
    @Default(0) int count,
    @Default([]) List<MultiStockAdjustment> multiStockAdjustments,
    PagingController<int, StockAdjustments>? pagingController,
  }) = _StockAdjustmentsState;

  factory StockAdjustmentsState.initial() => const StockAdjustmentsState();
}
