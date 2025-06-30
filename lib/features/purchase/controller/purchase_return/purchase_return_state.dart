part of 'purchase_return_notifier.dart';

enum PurchaseReturnStatus {
  initial,
  loading,
  success,
  error,
}

@freezed
class PurchaseReturnState with _$PurchaseReturnState {
  const factory PurchaseReturnState({
    @Default(PurchaseReturnStatus.initial) PurchaseReturnStatus status,
    @Default([]) List<PurchaseReturn> returns,
    @Default('') String error,
    PlutoGridStateManager? stateManager,
    @Default('') String query,
    @Default(10) int pageSize,
    @Default(1) int pageNumber,
    @Default(0) int count,
    PagingController<int, PurchaseReturn>? pagingController,
  }) = _PurchaseReturnState;

  factory PurchaseReturnState.initial() => const PurchaseReturnState();
}
