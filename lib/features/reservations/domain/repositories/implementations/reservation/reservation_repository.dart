import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/reservations/reservations.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'reservation_repository.g.dart';

@Riverpod(keepAlive: true)
IReservationRepository reservationRepo(ReservationRepoRef ref) => ReservationRepository(ref);

class ReservationRepository implements IReservationRepository {
  ReservationRepository(this.ref) : _supabaseClient = ref.watch(supabaseProvider);

  final ReservationRepoRef ref;
  final SupabaseClient _supabaseClient;

  @override
  Future<List<Table>> getTables() async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      final response = await _supabaseClient.from(DbConstants.tables).select().eq('business_id', businessId);

      ///TODO:Review this logic
      return response.map(Table.fromJson).toList();
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<List<Floor>> getFloors() async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      final response = await _supabaseClient.from(DbConstants.floors).select().eq('business_id', businessId);
      return response.map(Floor.fromJson).toList();
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<void> deleteFloor(String floorId) async {
    try {
      return await _supabaseClient.from(DbConstants.floors).delete().eq('floor_id', floorId);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<void> deleteTable(String tableId) async {
    try {
      return await _supabaseClient.from(DbConstants.tables).delete().eq('table_id', tableId);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<Floor?> getFloorWithId({required String floorId}) async {
    try {
      return await _supabaseClient
          .from(DbConstants.floors)
          .select()
          .eq('floor_id', floorId)
          .single()
          .withConverter(Floor.fromJson);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<Table?> getTableWithId({required String tableId}) async {
    try {
      return await _supabaseClient
          .from(DbConstants.tables)
          .select()
          .eq('table_id', tableId)
          .single()
          .withConverter(Table.fromJson);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<Floor> upsertFloor(Floor floor) async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;

      final user = ref.read(authNotifierProvider).user!;
      return await _supabaseClient
          .from(DbConstants.floors)
          .upsert(floor.copyWith(businessId: businessId).toJson())
          .select()
          .single()
          .withConverter(Floor.fromJson);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<Table> upsertTable(Table table) async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      return await _supabaseClient
          .from(DbConstants.tables)
          .upsert(table.copyWith(businessId: businessId).toJson())
          .select()
          .single()
          .withConverter(Table.fromJson);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<void> updateTablePosition(Table table) async {
    try {
      await _supabaseClient.from(DbConstants.tables).update({
        'x': table.x,
        'y': table.y,
        'turns': table.turns,
      }).eq('table_id', table.tableId!);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<AvailableSpots> getReservations({
    required DateTime date,
    int? partySize,
  }) async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      final response = await _supabaseClient.rpc<PostgrestMap>(
        RPCConstants.getTimeSlots,
        params: {
          'p_business_id': businessId,
          'p_date': date.toIso8601String(),
          if (partySize != null) 'p_party_size': partySize,
        },
      ).withConverter(AvailableSpots.fromJson);
      return response;
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<String> createReservation(Map<String, dynamic> reservation) async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;

      return await _supabaseClient.rpc<String>(
        RPCConstants.createReservation,
        params: {
          'p_data': {
            'business_id': businessId,
            ...reservation,
          },
        },
      );
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
      );
    }
  }

  @override
  Future<List<TableReservation>> getTableReservations({
    required DateTime date,
    String? status,
    String? search,
    bool? isWalkIn,
  }) async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      var queryBuilder = _supabaseClient
          .from(DbConstants.reservationsView)
          .select()
          .eq('business_id', businessId)
          .eq('reservation_date', date.toApiDateFormat);
      if (status != null) queryBuilder = queryBuilder.eq('status', status);
      if (search != null) {
        queryBuilder = queryBuilder.or('customer->>name.ilike.%$search%');
      }
      if (isWalkIn != null) {
        if (isWalkIn) {
          queryBuilder = queryBuilder.isFilter('customer_id', null);
        } else {
          queryBuilder = queryBuilder.not('customer_id', 'is', null).isFilter('order_id', null);
        }
      }

      final response = await queryBuilder;
      return response.map(TableReservation.fromJson).toList();
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  //cancel reservation
  @override
  Future<void> cancelReservation(String reservationId) async {
    try {
      await _supabaseClient
          .from(DbConstants.reservations)
          .update({'status': 'cancelled'}).eq('reservation_id', reservationId);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  // mark attendance
  @override
  Future<void> markStatus(String reservationId, String status) async {
    try {
      await _supabaseClient
          .from(DbConstants.reservations)
          .update({'status': status}).eq('reservation_id', reservationId);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<void> assignTable(
    TableReservation reservation,
    List<String> tableIds,
    List<String> newTableNames, {
    bool? shouldMarkAttendance = true,
  }) async {
    try {
      await _supabaseClient
          .from(DbConstants.reservationTables)
          .delete()
          .eq('reservation_id', reservation.reservationId);
      for (final tableId in tableIds) {
        await _supabaseClient.from(DbConstants.reservationTables).upsert({
          'reservation_id': reservation.reservationId,
          'table_id': tableId,
        });
      }
      if (shouldMarkAttendance ?? false) {
        await markStatus(reservation.reservationId, 'reserved');
      }
      if (reservation.customerId != null) {
        await _supabaseClient.from(DbConstants.customerNotifications).insert({
          'content': reservation.tables.isEmpty
              ? "You have been assigned tables for your reservation, Table(s): ${newTableNames.join(', ')}"
              : 'Your tables have been changed from ${reservation.tables.map((e) => e.name).join(', ')} to ${newTableNames.join(', ')}',
          'type': 'TABLES_ASSIGNED',
          'customer_id': reservation.customerId,
        });
      }
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<AvailableSpots> getCurrentTimeSlot({
    required DateTime date,
    int? partySize,
  }) async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      final response = await _supabaseClient.rpc<PostgrestMap>(
        RPCConstants.getCurrentTimeSlot,
        params: {
          'p_business_id': businessId,
          'p_date': date.toIso8601String(),
          if (partySize != null) 'p_party_size': partySize,
        },
      ).withConverter(AvailableSpots.fromJson);
      return response;
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
      );
    }
  }
}
