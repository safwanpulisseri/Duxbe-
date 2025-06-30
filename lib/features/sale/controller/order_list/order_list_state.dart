part of 'order_list_notifier.dart';

enum OrderListStatus {
  initial,
  loading,
  success,
  error,
}

@freezed
class OrderListState with _$OrderListState {
  const factory OrderListState({
    @Default(OrderListStatus.initial) OrderListStatus status,
    @Default([]) List<SaleView> orders,
    @Default('') String error,
    PlutoGridStateManager? stateManager,
    @Default('') String query,
    @Default(10) int pageSize,
    @Default(1) int pageNumber,
    @Default(0) int count,
    PagingController<int, SaleView>? pagingController,
    DateTime? startDate,
    DateTime? endDate,
  }) = _OrderListState;

  factory OrderListState.initial() => const OrderListState();
}
