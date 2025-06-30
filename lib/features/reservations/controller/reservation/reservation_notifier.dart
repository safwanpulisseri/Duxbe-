import 'dart:async';

import 'package:duxbe/features/reservations/reservations.dart';
import 'package:duxbe/shared/shared.dart';

import 'package:flutter/material.dart' hide Table;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reservation_notifier.freezed.dart';
part 'reservation_notifier.g.dart';
part 'reservation_state.dart';

// provider for recent 5 reservations
@riverpod
Future<List<TableReservation>> recentReservations(
  RecentReservationsRef ref,
  String? businessId,
) async =>
    businessId == null
        ? Future.value([])
        : ref.watch(reservationRepoProvider).getTableReservations(
              date: DateTime.now(),
              status: 'reserved',
            );

@Riverpod(keepAlive: false)
class ReservationNotifier extends _$ReservationNotifier {
  late IReservationRepository _reservationRepository;

  @override
  ReservationState build() {
    _reservationRepository = ref.watch(reservationRepoProvider);
    Future.microtask(() => getTableReservations(date: DateTime.now()));
    return ReservationState.initial();
  }

  void toggleTable(Table table) {
    final newSelectedTables = Set<Table>.from(state.selectedTables);
    if (newSelectedTables.contains(table)) {
      newSelectedTables.remove(table);
    } else {
      newSelectedTables.add(table);
    }
    state = state.copyWith(selectedTables: newSelectedTables);
  }

  Future<String> createReservation(Map<String, dynamic> reservation) async {
    try {
      state = state.copyWith(status: ReservationStatus.loading);
      final reservationId = await _reservationRepository.createReservation(reservation);
      state = state.copyWith(status: ReservationStatus.success);
      return reservationId;
    } catch (e) {
      state = state.copyWith(status: ReservationStatus.error, error: e.toString());
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<void> assignTable(
    TableReservation reservation,
    List<String> tableIds,
    List<String> newTableNames, {
    bool? shouldMarkAttendance,
  }) async {
    try {
      state = state.copyWith(status: ReservationStatus.loading);
      await _reservationRepository.assignTable(
        reservation,
        tableIds,
        newTableNames,
        shouldMarkAttendance: shouldMarkAttendance,
      );
      state = state.copyWith(status: ReservationStatus.success);
      unawaited(getTableReservations(date: DateTime.now()));
    } catch (e) {
      state = state.copyWith(status: ReservationStatus.error, error: e.toString());
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
    }
  }

  Future<void> getTableReservations({
    DateTime? date,
    Object? status = freezed,
    String? search,
  }) async {
    try {
      state = state.copyWith(
        status: ReservationStatus.loading,
        date: date ?? state.date ?? DateTime.now(),
        query: search ?? state.query,
        tableStatus: status == freezed ? state.tableStatus : status as String?,
      );
      state.stateManager?.setShowLoading(true);
      final tables = await _reservationRepository.getTableReservations(
        date: state.date ?? DateTime.now(),
        status: state.tableStatus,
        search: state.query,
      );
      final rows = await PlutoGridStateManager.initializeRowsAsync(
        columns,
        tables
            .map(
              (table) => PlutoRow<TableReservation>(
                cells: {
                  'reservation_code': PlutoCell(value: table.reservationCode),
                  'order_code': PlutoCell(value: table.orderCode ?? ''),
                  'customer_name': PlutoCell(
                    value: table.customer?.name ?? AppRouter.l10n.walkInCustomer,
                  ),
                  'time': PlutoCell(value: table.startTime),
                  'table': PlutoCell(
                    value: table.tables.map((table) => table.name).join(', '),
                  ),
                  'party_size': PlutoCell(value: table.partySize),
                  'status': PlutoCell(value: table.status.displayCase),
                  'actions': PlutoCell(value: table),
                },
              ),
            )
            .toList(),
      );
      state.stateManager?.refRows.clear();
      state.stateManager?.refRows.addAll(rows);
      state.stateManager?.setShowLoading(false);
      state = state.copyWith(
        status: ReservationStatus.success,
        tables: tables,
      );
    } catch (e) {
      state = state.copyWith(status: ReservationStatus.error, error: e.toString());
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
    }
  }

  void resetTables() {
    state = state.copyWith(selectedTables: <Table>{});
  }

  void setStateManager(PlutoGridStateManager stateManager) {
    state = state.copyWith(stateManager: stateManager);
  }

  Future<void> cancelReservation(String reservationId) async {
    try {
      state = state.copyWith(status: ReservationStatus.loading);
      await _reservationRepository.cancelReservation(reservationId);
      state = state.copyWith(status: ReservationStatus.success);
      unawaited(getTableReservations());
    } catch (e) {
      state = state.copyWith(status: ReservationStatus.error, error: e.toString());
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
    }
  }

  Future<void> markAttendance(String reservationId) async {
    try {
      await _reservationRepository.markStatus(reservationId, 'completed');
      state = state.copyWith(status: ReservationStatus.success);
      unawaited(getTableReservations());
    } catch (e) {
      state = state.copyWith(status: ReservationStatus.error, error: e.toString());
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
    }
  }

  final List<PlutoColumn> columns = [
    PlutoColumn(
      title: 'Reservation Code',
      field: 'reservation_code',
      width: 120,
      type: PlutoColumnType.text(),
      titleSpan: TextSpan(
        text: AppRouter.l10n.reservationCode,
        style: AppText.mediumB.copyWith(color: AppColors.black),
      ),
      backgroundColor: AppColors.greyish2,
    ),
    PlutoColumn(
      title: 'Order Code',
      field: 'order_code',
      width: 100,
      type: PlutoColumnType.text(),
      titleSpan: TextSpan(
        text: AppRouter.l10n.orderCode,
        style: AppText.mediumB.copyWith(color: AppColors.black),
      ),
      backgroundColor: AppColors.greyish2,
    ),
    PlutoColumn(
      title: 'Customer Name',
      field: 'customer_name',
      type: PlutoColumnType.text(),
      titleSpan: TextSpan(
        text: AppRouter.l10n.customerName,
        style: AppText.mediumB.copyWith(color: AppColors.black),
      ),
      backgroundColor: AppColors.greyish2,
    ),
    PlutoColumn(
      title: 'Time',
      field: 'time',
      width: 90,
      type: PlutoColumnType.text(),
      titleSpan: TextSpan(
        text: AppRouter.l10n.time,
        style: AppText.mediumB.copyWith(color: AppColors.black),
      ),
      backgroundColor: AppColors.greyish2,
    ),
    PlutoColumn(
      title: 'Table',
      field: 'table',
      type: PlutoColumnType.text(),
      titleSpan: TextSpan(
        text: AppRouter.l10n.table,
        style: AppText.mediumB.copyWith(color: AppColors.black),
      ),
      backgroundColor: AppColors.greyish2,
    ),
    PlutoColumn(
      title: 'Party Size',
      field: 'party_size',
      width: 80,
      type: PlutoColumnType.number(),
      titleSpan: TextSpan(
        text: AppRouter.l10n.partySize,
        style: AppText.mediumB.copyWith(color: AppColors.black),
      ),
      backgroundColor: AppColors.greyish2,
    ),
    PlutoColumn(
      title: 'Status',
      field: 'status',
      width: 100,
      type: PlutoColumnType.text(),
      titleSpan: TextSpan(
        text: AppRouter.l10n.status,
        style: AppText.mediumB.copyWith(color: AppColors.black),
      ),
      backgroundColor: AppColors.greyish2,
    ),
    PlutoColumn(
      title: 'Actions',
      field: 'actions',
      width: 300,
      titleSpan: TextSpan(
        text: AppRouter.l10n.actions,
        style: AppText.mediumB.copyWith(color: AppColors.black),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.greyish2,
      renderer: (rendererContext) {
        final reservation = rendererContext.cell.value as TableReservation;
        return Consumer(
          builder: (context, ref, child) => Row(
            children: [
              if (reservation.status == 'reserved') ...[
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    showDialog<void>(
                      context: AppRouter.rootContext,
                      useRootNavigator: false,
                      builder: (context) => CommonDialog(
                        title: AppRouter.l10n.cancelReservation,
                        children: [
                          Text(AppRouter.l10n.cancelThisReservation),
                        ],
                        onPositive: (ref) {
                          ref
                              .read(reservationNotifierProvider.notifier)
                              .cancelReservation(reservation.reservationId)
                              .then((value) {
                            if (context.mounted) context.pop();
                          });
                        },
                      ),
                    );
                  },
                  child: Text(AppRouter.l10n.cancel),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    final tables = await AppRouter.pushNamed<List<Table>>(
                      AppRouter.chooseReservationTable,
                      queryParameters: {
                        'date': reservation.reservationDate.toApiDateFormat,
                        'time': reservation.startTime,
                        'party_size': reservation.partySize.toString(),
                        'tables': reservation.tables.map((e) => e.tableId).join(','),
                        'return': 'true',
                        'view_only': 'false',
                        'customer_id': reservation.customer?.customerId,
                      },
                    );
                    if (tables != null) {
                      await ref.read(reservationNotifierProvider.notifier).assignTable(
                            reservation,
                            tables.map((e) => e.tableId!).toList(),
                            tables.map((e) => e.name).toList(),
                            shouldMarkAttendance: false,
                          );
                    }
                  },
                  child: Text(AppRouter.l10n.changeTableS),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(AppRouter.l10n.markAttendance),
                  onPressed: () {
                    ref.read(reservationNotifierProvider.notifier).markAttendance(reservation.reservationId);
                  },
                ),
              ],
              if (reservation.status == 'waiting')
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(AppRouter.l10n.assignTable),
                  onPressed: () async {
                    final tables = await AppRouter.pushNamed<List<Table>>(
                      AppRouter.l10n.chooseReservationTable,
                      queryParameters: {
                        'date': reservation.reservationDate.toApiDateFormat,
                        'time': reservation.startTime,
                        'party_size': reservation.partySize.toString(),
                        'return': 'true',
                        'view_only': 'false',
                      },
                    );
                    if (tables != null) {
                      await ref.read(reservationNotifierProvider.notifier).assignTable(
                            reservation,
                            tables.map((e) => e.tableId!).toList(),
                            tables.map((e) => e.name).toList(),
                            shouldMarkAttendance: true,
                          );
                    }
                  },
                ),
            ],
          ),
        );
      },
    ),
  ];
}
