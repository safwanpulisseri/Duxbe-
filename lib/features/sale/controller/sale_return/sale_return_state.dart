part of 'sale_return_notifier.dart';

enum SaleReturnStatus {
  initial,
  loading,
  success,
  error,
}

@freezed
class SaleReturnState with _$SaleReturnState {
  const factory SaleReturnState({
    @Default(SaleReturnStatus.initial) SaleReturnStatus status,
    @Default([]) List<SaleReturn> returns,
    @Default('') String error,
    PlutoGridStateManager? stateManager,
    @Default('') String query,
    @Default(10) int pageSize,
    @Default(1) int pageNumber,
    @Default(0) int count,
    PagingController<int, SaleReturn>? pagingController,
  }) = _SaleReturnState;

  factory SaleReturnState.initial() => const SaleReturnState();
}
