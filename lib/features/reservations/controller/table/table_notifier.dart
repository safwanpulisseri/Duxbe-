import 'dart:async';

import 'package:duxbe/features/reservations/reservations.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'table_notifier.freezed.dart';
part 'table_notifier.g.dart';
part 'table_state.dart';

@Riverpod(keepAlive: false)
class TableNotifier extends _$TableNotifier {
  late IReservationRepository _reservationRepository;
  @override
  TableState build() {
    _reservationRepository = ref.watch(reservationRepoProvider);
    Future(getTables);
    return TableState.initial();
  }

  Future<void> getTables() async {
    final tables = await _reservationRepository.getTables();
    final floors = await _reservationRepository.getFloors();
    state = state.copyWith(
      tables: tables,
      floors: floors,
      selectedFloor: floors.firstOrNull,
    );
  }

  Future<void> upsertFloor(Floor floor) async {
    try {
      state = state.copyWith(status: TableStatus.loading);
      await _reservationRepository.upsertFloor(floor);
      state = state.copyWith(status: TableStatus.success);
      unawaited(getTables());
      Alert.showSnackBar(
        'Area ${floor.floorId == null ? 'created' : 'updated'} successfully',
        type: SnackBarType.success,
      );
    } catch (e) {
      state = state.copyWith(status: TableStatus.error, error: e.toString());
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
    }
  }

  Future<void> deleteFloor(Floor floor) async {
    try {
      state = state.copyWith(status: TableStatus.loading);
      await _reservationRepository.deleteFloor(floor.floorId!);
      state = state.copyWith(status: TableStatus.success);
      Alert.showSnackBar('Area deleted successfully', type: SnackBarType.success);
      unawaited(getTables());
    } catch (e) {
      state = state.copyWith(status: TableStatus.error, error: e.toString());
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
    }
  }

  Future<void> upsertTable(Table table) async {
    try {
      state = state.copyWith(status: TableStatus.loading);
      await _reservationRepository.upsertTable(table);
      Alert.showSnackBar(
        'Table ${table.tableId == null ? 'created' : 'updated'} successfully',
        type: SnackBarType.success,
      );
      state = state.copyWith(status: TableStatus.success);
      unawaited(getTables());
    } catch (e) {
      state = state.copyWith(status: TableStatus.error, error: e.toString());
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
    }
  }

  Future<void> deleteTable(Table table) async {
    try {
      state = state.copyWith(status: TableStatus.loading);
      await _reservationRepository.deleteTable(table.tableId!);
      state = state.copyWith(status: TableStatus.success);
      Alert.showSnackBar('Table deleted successfully', type: SnackBarType.success);
      unawaited(getTables());
    } catch (e) {
      state = state.copyWith(status: TableStatus.error, error: e.toString());
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
    }
  }

  Future<void> updateTablePosition(Table table) async {
    try {
      await _reservationRepository.updateTablePosition(table);
    } catch (e) {
      state = state.copyWith(status: TableStatus.error, error: e.toString());
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
    }
  }

  void changeCurrentFloor(Floor? floor) {
    state = state.copyWith(selectedFloor: floor);
  }
}
