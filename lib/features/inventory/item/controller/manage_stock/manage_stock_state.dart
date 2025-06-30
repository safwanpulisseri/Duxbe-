part of 'manage_stock_notifier.dart';

enum ManageStockStatus {
  initial,
  loading,
  success,
  error,
}

@freezed
class ManageStockState with _$ManageStockState {
  const factory ManageStockState({
    @Default(ManageStockStatus.initial) ManageStockStatus status,
    @Default([]) List<Item> items,
    @Default('') String error,
    PlutoGridStateManager? stateManager,
    @Default('') String query,
    @Default(10) int pageSize,
    @Default(1) int pageNumber,
    @Default(0) int count,
    PagingController<int, Item>? pagingController,
  }) = _ManageStockState;

  factory ManageStockState.initial() => const ManageStockState();
}
