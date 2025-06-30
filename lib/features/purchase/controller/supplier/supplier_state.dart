part of 'supplier_notifier.dart';

enum SupplierStatus {
  initial,
  loading,
  success,
  error,
}

@freezed
class SupplierState with _$SupplierState {
  const factory SupplierState({
    @Default(SupplierStatus.initial) SupplierStatus status,
    @Default([]) List<Supplier> suppliers,
    @Default('') String error,
    PlutoGridStateManager? stateManager,
    @Default('') String query,
    @Default(10) int pageSize,
    @Default(1) int pageNumber,
    @Default(0) int count,
    PagingController<int, Supplier>? pagingController,
  }) = _SupplierState;

  factory SupplierState.initial() => const SupplierState();
}
