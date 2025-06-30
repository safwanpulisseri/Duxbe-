import 'dart:async';

import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'unit_notifier.freezed.dart';
part 'unit_notifier.g.dart';
part 'unit_state.dart';

@Riverpod(keepAlive: false)
Future<Unit?> unit(
  UnitRef ref,
  String? unitId,
) async =>
    unitId == null ? null : ref.watch(unitRepoProvider).getUnitWithId(unitId: unitId);

@Riverpod(keepAlive: false)
class UnitNotifier extends _$UnitNotifier {
  late IUnitRepository _unitRepository;

  @override
  UnitState build() {
    _unitRepository = ref.watch(unitRepoProvider); // Watch for business changes
    ref.listen(businessNotifierProvider, (previous, next) {
      // Refresh the paging controller when business changes
      setFilter(pageNumber: 1);
    });

    state = UnitState.initial();

    // This is to set infinte scrolling in mobile devices
    return state.copyWith(
      pagingController: PagingController<int, Unit>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener(
          (pageKey) async {
            final units = await getUnits(pageNumber: pageKey);
            final isLastPage = units.data.length < state.pageSize;
            if (isLastPage) {
              state.pagingController!.appendLastPage(units.data);
            } else {
              final nextPageKey = pageKey + 1;
              state.pagingController!.appendPage(units.data, nextPageKey);
            }
          },
        ),
    );
  }

  void setStateManager({required PlutoGridStateManager stateManager}) {
    state = state.copyWith(stateManager: stateManager);
    setTable();
  }

  Future<PaginatedResponse<Unit>> getUnits({
    String? query,
    int? pageSize,
    int? pageNumber,
  }) async {
    try {
      final units = await _unitRepository.getUnits(
        query: query ?? state.query,
        pageSize: pageSize ?? state.pageSize,
        pageNumber: pageNumber ?? state.pageNumber,
      );
      return units;
    } catch (e) {
      state = state.copyWith(
        status: UnitStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  void setFilter({
    String? query,
    int? pageSize,
    int? pageNumber,
  }) {
    state = state.copyWith(query: query ?? state.query, pageSize: pageSize ?? state.pageSize, pageNumber: pageNumber ?? state.pageNumber);
    state.pagingController?.refresh();
    setTable();
  }

  Future<Unit> upsertUnit(Unit unit) async {
    try {
      state = state.copyWith(status: UnitStatus.loading);
      final updatedUnit = await _unitRepository.upsertUnit(unit);
      state = state.copyWith(status: UnitStatus.success);
      setFilter(pageNumber: 1);
      // show success snackbar if unitId is null, it is an insert, otherwise an update
      Alert.showSnackBar(updatedUnit.unitId == null ? AppRouter.l10n.unitAdded : AppRouter.l10n.unitUpdated, type: SnackBarType.success);
      return updatedUnit;
    } catch (e) {
      state = state.copyWith(
        status: UnitStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<void> deleteUnit(Unit unit) async {
    try {
      state = state.copyWith(status: UnitStatus.loading);
      await _unitRepository.deleteUnit(unit.unitId!);
      state = state.copyWith(status: UnitStatus.success);
      setFilter(pageNumber: 1);
      // show success snackbar
      Alert.showSnackBar(AppRouter.l10n.unitDeletedSuccessfully, type: SnackBarType.success);
    } catch (e) {
      state = state.copyWith(
        status: UnitStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
    }
  }

  Future<void> setTable() async {
    if (state.stateManager == null) return;
    state.stateManager?.setShowLoading(true);
    state = state.copyWith(status: UnitStatus.loading);
    final units = await getUnits();
    state = state.copyWith(
      status: UnitStatus.success,
      itemUnits: units.data,
      count: units.count,
    );
    final baseIndex = (state.pageNumber - 1) * state.pageSize + 1;
    final rows = await PlutoGridStateManager.initializeRowsAsync(
      unitColumns,
      [
        for (int i = 0; i < state.itemUnits.length; i++)
          PlutoRow(
            cells: {
              'sl_no': PlutoCell(value: baseIndex + i),
              'unit': PlutoCell(value: state.itemUnits[i].name),
              'short_name': PlutoCell(value: state.itemUnits[i].shortName ?? ''),
              'actions': PlutoCell(value: state.itemUnits[i]),
            },
          ),
      ],
    );
    state.stateManager?.refRows.clear();
    state.stateManager?.refRows.addAll(rows);
    state.stateManager?.setShowLoading(false);
  }

  final List<PlutoColumn> unitColumns = <PlutoColumn>[
    PlutoColumn(
      title: AppRouter.l10n.slNo,
      field: 'sl_no',
      width: 24,
      titleSpan: TextSpan(
        text: AppRouter.l10n.slNo,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.unit,
      field: 'unit',
      titleSpan: TextSpan(
        text: AppRouter.l10n.unit,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.shortName,
      field: 'short_name',
      titleSpan: TextSpan(
        text: AppRouter.l10n.shortName,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      titleTextAlign: PlutoColumnTextAlign.center,
      title: AppRouter.l10n.actions,
      field: 'actions',
      titleSpan: TextSpan(
        text: AppRouter.l10n.actions,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      renderer: (rendererContext) {
        final unit = rendererContext.cell.value as Unit;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              icon: Assets.icons.edit.svg(),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primaryColor.withOpacity(.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () {
                showDialog<void>(
                  context: AppRouter.rootContext,
                  builder: (context) => AddUnitDialog(
                    unit: unit,
                  ),
                );
              },
              label: Text(AppRouter.l10n.edit),
            ),
            const SizedBox(width: 20),
            TextButton.icon(
              icon: Assets.icons.delete.svg(),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.red.withOpacity(.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () {
                showDialog<void>(
                  context: AppRouter.rootContext,
                  builder: (context) => ConfirmationDialog(
                    title: AppRouter.l10n.deleteUnit,
                    positiveText: AppRouter.l10n.delete,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppRouter.l10n.deleteUnitSub,
                        style: AppText.mediumN.copyWith(color: AppColors.primaryColor),
                      ),
                    ],
                    onPositive: (ref) {
                      ref.read(unitNotifierProvider.notifier).deleteUnit(unit).then(AppRouter.pop);
                    },
                  ),
                );
              },
              label: Text(
                AppRouter.l10n.delete,
                style: AppText.mediumN.copyWith(color: AppColors.red),
              ),
            ),
          ],
        );
      },
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
  ];
}
