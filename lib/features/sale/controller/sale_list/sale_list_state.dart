part of 'sale_list_notifier.dart';

enum SaleListStatus {
  initial,
  loading,
  success,
  error,
}

@freezed
class SaleListState with _$SaleListState {
  const factory SaleListState({
    @Default(SaleListStatus.initial) SaleListStatus status,
    @Default([]) List<SaleView> sales,
    @Default('') String error,
    PlutoGridStateManager? stateManager,
    @Default('') String query,
    @Default(10) int pageSize,
    @Default(1) int pageNumber,
    @Default(0) int count,
    PagingController<int, SaleView>? pagingController,
    DateTime? startDate,
    DateTime? endDate,
  }) = _SaleListState;

  factory SaleListState.initial() => const SaleListState();
}
