part of 'purchase_list_notifier.dart';

enum PurchaseListStatus {
  initial,
  loading,
  success,
  error,
}

@freezed
class PurchaseListState with _$PurchaseListState {
  const factory PurchaseListState({
    @Default(PurchaseListStatus.initial) PurchaseListStatus status,
    @Default([]) List<PurchaseView> purchases,
    @Default('') String error,
    PlutoGridStateManager? stateManager,
    @Default('') String query,
    @Default(10) int pageSize,
    @Default(1) int pageNumber,
    @Default(0) int count,
    PagingController<int, PurchaseView>? pagingController,
  }) = _PurchaseListState;

  factory PurchaseListState.initial() => const PurchaseListState();
}
