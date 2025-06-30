import 'package:duxbe/features/reservations/reservations.dart';

abstract class IReservationRepository {
  Future<List<Table>> getTables();
  Future<List<Floor>> getFloors();
  Future<Floor?> getFloorWithId({required String floorId});
  Future<void> deleteFloor(String floorId);
  Future<Floor> upsertFloor(Floor floor);
  Future<Table?> getTableWithId({required String tableId});
  Future<void> deleteTable(String tableId);
  Future<Table> upsertTable(Table table);
  Future<void> updateTablePosition(Table table);
  Future<AvailableSpots> getReservations({
    required DateTime date,
    int? partySize,
  });
  Future<AvailableSpots> getCurrentTimeSlot({
    required DateTime date,
    int? partySize,
  });
  Future<String> createReservation(Map<String, dynamic> reservation);
  Future<List<TableReservation>> getTableReservations({
    required DateTime date,
    String? status,
    String? search,
    bool? isWalkIn,
  });
  Future<void> cancelReservation(String reservationId);
  Future<void> markStatus(String reservationId, String status);
  Future<void> assignTable(
    TableReservation reservationId,
    List<String> tableIds,
    List<String> newTableNames, {
    bool? shouldMarkAttendance,
  });
}
