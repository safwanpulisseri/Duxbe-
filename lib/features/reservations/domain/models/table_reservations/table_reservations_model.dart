import 'package:duxbe/features/reservations/reservations.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'table_reservations_model.freezed.dart';
part 'table_reservations_model.g.dart';

// {
//   "date": "2024-12-13",
//   "status": "open",
//   "tables": [
//     {
//       "seats": 6,
//       "status": "available",
//       "floor_id": "8a6a0606-501d-4b56-8bdc-467e1830a51a",
//       "position": {
//         "x": 137.25,
//         "y": 251.25
//       },
//       "table_id": "c06c6c6c-a504-400d-b9db-0866c3290fea",
//       "table_name": "1",
//       "reservation": null
//     },
//     {
//       "seats": 6,
//       "status": "available",
//       "floor_id": "8a6a0606-501d-4b56-8bdc-467e1830a51a",
//       "position": {
//         "x": 424.5,
//         "y": 263.25
//       },
//       "table_id": "8ed8b892-efa9-4f7e-9442-9d6a1d345f33",
//       "table_name": "2",
//       "reservation": null
//     }
//   ],
//   "time_slot": {
//     "end_time": "11:00",
//     "start_time": "10:00"
//   }
// }
@freezed
class TableReservations with _$TableReservations {
  const factory TableReservations({
    @JsonKey(name: 'date') required DateTime? date,
    @JsonKey(name: 'status') required String status,
    @JsonKey(name: 'time_slot') required TimeSlot timeSlot,
    @JsonKey(name: 'tables') required List<Table> tables,
  }) = _TableReservations;

  factory TableReservations.fromJson(Map<String, dynamic> json) => _$TableReservationsFromJson(json);
}

@freezed
class TimeSlot with _$TimeSlot {
  const factory TimeSlot({
    @JsonKey(name: 'end_time') required String endTime,
    @JsonKey(name: 'start_time') required String startTime,
  }) = _TimeSlot;

  factory TimeSlot.fromJson(Map<String, dynamic> json) => _$TimeSlotFromJson(json);
}
