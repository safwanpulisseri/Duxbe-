part of 'table_notifier.dart';

enum TableStatus {
  initial,
  loading,
  success,
  error,
}

@freezed
class TableState with _$TableState {
  const factory TableState({
    @Default(TableStatus.initial) TableStatus status,
    @Default([]) List<Table> tables,
    @Default([]) List<Floor> floors,
    @Default('') String error,
    Floor? selectedFloor,
  }) = _TableState;

  factory TableState.initial() => const TableState();
}
