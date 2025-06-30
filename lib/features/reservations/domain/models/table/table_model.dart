import 'dart:ui';

import 'package:duxbe/features/reservations/reservations.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'table_model.freezed.dart';
part 'table_model.g.dart';

@unfreezed
class Table with _$Table {
  factory Table({
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'no_of_seats') required int noOfSeats,
    @JsonKey(name: 'floor_id') required String floorId,
    @JsonKey(name: 'floor_name', includeToJson: false) String? floorName,
    @JsonKey(name: 'table_id', includeIfNull: false) String? tableId,
    @JsonKey(name: 'status', includeToJson: false) String? status,
    @JsonKey(name: 'business_id') String? businessId,
    @Default(0) @JsonKey(name: 'x') double x,
    @Default(0) @JsonKey(name: 'y') double y,
    @Default(0) @JsonKey(name: 'turns') int turns,
    @JsonKey(name: 'reservation', includeToJson: false) Reservation? reservation,
  }) = _Table;

  factory Table.fromJson(Map<String, dynamic> json) => _$TableFromJson(json);

  const Table._();

  Offset get position => Offset(x, y);
}

@freezed
class Floor with _$Floor {
  const factory Floor({
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'floor_id', includeIfNull: false) String? floorId,
    @JsonKey(name: 'business_id') String? businessId,
  }) = _Floor;

  factory Floor.fromJson(Map<String, dynamic> json) => _$FloorFromJson(json);
}
