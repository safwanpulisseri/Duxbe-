part of 'reservation_notifier.dart';

enum ReservationStatus {
  initial,
  loading,
  success,
  error,
}

@freezed
class ReservationState with _$ReservationState {
  const factory ReservationState({
    @Default(ReservationStatus.initial) ReservationStatus status,
    @Default({}) Set<Table> selectedTables,
    @Default([]) List<TableReservation> tables,
    @Default('') String error,
    DateTime? date,
    PlutoGridStateManager? stateManager,
    @Default('') String query,
    String? tableStatus,
  }) = _ReservationState;

  factory ReservationState.initial() => const ReservationState();
}
