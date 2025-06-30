part of 'unit_notifier.dart';

enum UnitStatus {
  initial,
  loading,
  success,
  error,
}

@freezed
class UnitState with _$UnitState {
  factory UnitState({
    @Default(UnitStatus.initial) UnitStatus status,
    @Default([]) List<Unit> itemUnits,
    @Default('') String error,
    PlutoGridStateManager? stateManager,
    @Default('') String query,
    @Default(10) int pageSize,
    @Default(1) int pageNumber,
    @Default(0) int count,
    PagingController<int, Unit>? pagingController,
  }) = _UnitState;

  factory UnitState.initial() => UnitState();
  UnitState._();

  bool get isLoading => status == UnitStatus.loading;
}
