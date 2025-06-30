import 'package:duxbe/features/reservations/reservations.dart';
import 'package:duxbe/features/sale/domain/models/customer/customer_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'available_spots_model.freezed.dart';
part 'available_spots_model.g.dart';

@freezed
class AvailableSpots with _$AvailableSpots {
  const factory AvailableSpots({
    @JsonKey(name: 'date') required DateTime date,
    required String status,
    @Default([]) List<Slot> slots,
    @JsonKey(name: 'current_slot') Slot? currentSlot,
    @JsonKey(name: 'operating_hours') OperatingHours? operatingHours,
  }) = _AvailableSpots;

  factory AvailableSpots.fromJson(Map<String, dynamic> json) => _$AvailableSpotsFromJson(json);
}

@freezed
class OperatingHours with _$OperatingHours {
  const factory OperatingHours({
    @JsonKey(name: 'opening_time') required String openingTime,
    @JsonKey(name: 'closing_time') required String closingTime,
  }) = _OperatingHours;

  factory OperatingHours.fromJson(Map<String, dynamic> json) => _$OperatingHoursFromJson(json);
}

@freezed
class Slot with _$Slot {
  const factory Slot({
    required String time,
    required List<Table> tables,
    @JsonKey(name: 'end_time') required String endTime,
  }) = _Slot;

  factory Slot.fromJson(Map<String, dynamic> json) => _$SlotFromJson(json);
}

@freezed
class Reservation with _$Reservation {
  const factory Reservation({
    @JsonKey(name: 'reservation_id') required String reservationId,
    @JsonKey(name: 'party_size') required int partySize,
    @JsonKey(name: 'customer_name') String? customerName,
    @JsonKey(name: 'customer_id') String? customerId,
  }) = _Reservation;

  factory Reservation.fromJson(Map<String, dynamic> json) => _$ReservationFromJson(json);
}

class ReservationPageData {
  const ReservationPageData({
    required this.customer,
    required this.notes,
    required this.tags,
    required this.partySize,
    required this.date,
    required this.selectedSpot,
  });
  final Customer customer;
  final String notes;
  final List<String> tags;
  final int partySize;
  final DateTime date;
  final Slot selectedSpot;
}

// CREATE OR REPLACE VIEW public.reservations_view AS
// SELECT
//     r.reservation_id,
//     r.customer_id,
//     r.business_id,
//     r.reservation_date,
//     r.start_time,
//     r.end_time,
//     r.status,
//     r.created_at,
//     r.priority,
//     r.party_size,
//     r.notes,
//     row_to_json(c.*)::jsonb AS customer,
//     COALESCE(
//         (
//             SELECT json_agg(row_to_json(t.*))
//             FROM (
//                 SELECT
//                     tb.*,
//                     f.name as floor_name
//                 FROM tables tb
//                 LEFT JOIN floors f ON tb.floor_id = f.floor_id
//                 WHERE tb.table_id IN (
//                     SELECT rt.table_id
//                     FROM reservation_tables rt
//                     WHERE rt.reservation_id = r.reservation_id
//                 )
//             ) t
//         ),
//         '[]'::json
//     )::jsonb AS tables
// FROM reservations r
@freezed
class TableReservation with _$TableReservation {
  const factory TableReservation({
    @JsonKey(name: 'reservation_id') required String reservationId,
    @JsonKey(name: 'business_id') required String businessId,
    @JsonKey(name: 'reservation_date') required DateTime reservationDate,
    @JsonKey(name: 'start_time') required String startTime,
    @JsonKey(name: 'end_time') required String endTime,
    @JsonKey(name: 'status') required String status,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'priority') required int priority,
    @JsonKey(name: 'reservation_code') required String reservationCode,
    @JsonKey(name: 'party_size') required int partySize,
    @JsonKey(name: 'tables') required List<Table> tables,
    @JsonKey(name: 'order_code') String? orderCode,
    @JsonKey(name: 'customer_id') String? customerId,
    @JsonKey(name: 'customer') Customer? customer,
    @JsonKey(name: 'notes') String? notes,
  }) = _TableReservation;

  factory TableReservation.fromJson(Map<String, dynamic> json) => _$TableReservationFromJson(json);
}
