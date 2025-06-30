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

part 'stock_adjustments_notifier.freezed.dart';
part 'stock_adjustments_notifier.g.dart';
part 'stock_adjustments_state.dart';

@Riverpod(keepAlive: false)
Future<StockAdjustments?> stockAdjustment(
  StockAdjustmentRef ref,
  String? adjustmentId,
) async =>
    adjustmentId == null ? null : ref.watch(itemRepoProvider).getStockAdjustmentWithId(adjustmentId: adjustmentId);


@Riverpod(keepAlive: false)
class StockAdjustmentsNotifier extends _$StockAdjustmentsNotifier {
  late IItemRepository _itemRepository;

  @override
  StockAdjustmentsState build() {
    _itemRepository = ref.watch(itemRepoProvider); // Watch for business changes
    ref.listen(businessNotifierProvider, (previous, next) {
      // Refresh the paging controller when business changes
      state.pagingController?.refresh();
      setFilter(pageNumber: 1);
    });

    state = StockAdjustmentsState.initial();

    // This is to set infinte scrolling in mobile devices
    return state.copyWith(
      pagingController: PagingController<int, StockAdjustments>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener(
          (pageKey) async {
            final items = await getStockAdjustments(pageNumber: pageKey);
            final isLastPage = items.data.length < state.pageSize;
            if (isLastPage) {
              state.pagingController!.appendLastPage(items.data);
            } else {
              final nextPageKey = pageKey + 1;
              state.pagingController!.appendPage(items.data, nextPageKey);
            }
          },
        ),
    );
  }

  void setFilter({
    String? query,
    int? pageSize,
    int? pageNumber,
  }) {
    state = state.copyWith(
      query: query ?? state.query,
      pageSize: pageSize ?? state.pageSize,
      pageNumber: pageNumber ?? state.pageNumber,
    );
    state.pagingController?.refresh();
    setTable();
  }

  void setStateManager({required PlutoGridStateManager stateManager}) {
    state = state.copyWith(stateManager: stateManager);
    setTable();
  }

  Future<void> adjustStock(Map<String, dynamic> adjustment) async {
    try {
      state = state.copyWith(status: StockAdjustmentsStatus.loading);
      await _itemRepository.adjustStock(adjustment);
      state = state.copyWith(status: StockAdjustmentsStatus.success);
      setFilter(pageNumber: 1);
      return;
    } catch (e) {
      state = state.copyWith(
        status: StockAdjustmentsStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<void> deleteStockAdjustment(String adjustmentId) async {
    try {
      state = state.copyWith(status: StockAdjustmentsStatus.loading);
      await _itemRepository.deleteStockAdjustment(adjustmentId);
      state = state.copyWith(status: StockAdjustmentsStatus.success);
      setFilter(pageNumber: 1);
      return;
    } catch (e) {
      state = state.copyWith(
        status: StockAdjustmentsStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  void addAdjustment(MultiStockAdjustment adjustment) {
    state = state.copyWith(multiStockAdjustments: [...state.multiStockAdjustments, adjustment]);
  }

  void removeAdjustment(MultiStockAdjustment adjustment) {
    state = state.copyWith(multiStockAdjustments: state.multiStockAdjustments.where((e) => e != adjustment).toList());
  }

  Future<PaginatedResponse<StockAdjustments>> getStockAdjustments({
    String? query,
    int? pageSize,
    int? pageNumber,
  }) async {
    try {
      final items = await _itemRepository.getStockAdjustments(
        query: query ?? state.query,
        pageSize: pageSize ?? state.pageSize,
        pageNumber: pageNumber ?? state.pageNumber,
      );
      return items;
    } catch (e) {
      state = state.copyWith(
        status: StockAdjustmentsStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<void> setTable() async {
    if (state.stateManager == null) return;

    state.stateManager?.setShowLoading(true);
    state = state.copyWith(status: StockAdjustmentsStatus.loading);
    final items = await getStockAdjustments();
    state = state.copyWith(
      status: StockAdjustmentsStatus.success,
      items: items.data,
      count: items.count,
    );

    final baseIndex = (state.pageNumber - 1) * state.pageSize + 1;
    final rows = await PlutoGridStateManager.initializeRowsAsync(
      adjustedColumns,
      [
        for (int i = 0; i < state.items.length; i++)
          PlutoRow(
            cells: {
              'sl_no': PlutoCell(value: baseIndex + i),
              'date': PlutoCell(value: state.items[i].performedAt.toFullFormat),
              'ref_no': PlutoCell(value: state.items[i].reference),
              'reason': PlutoCell(value: state.items[i].reason),
              'no_of_items': PlutoCell(value: state.items[i].adjustedItems.length),
              'created_by': PlutoCell(value: state.items[i].performedUser),
              'actions': PlutoCell(value: state.items[i]),
            },
          ),
      ],
    );
    state.stateManager?.refRows.clear();
    state.stateManager?.refRows.addAll(rows);
    state.stateManager?.setShowLoading(false);
  }

  final List<PlutoColumn> adjustedColumns = <PlutoColumn>[
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
      title: AppRouter.l10n.date,
      field: 'date',
      titleSpan: TextSpan(
        text: AppRouter.l10n.date,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.refNo,
      field: 'ref_no',
      titleSpan: TextSpan(
        text: AppRouter.l10n.refNo,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.reason,
      field: 'reason',
      titleSpan: TextSpan(
        text: AppRouter.l10n.reason,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.noOfItems,
      field: 'no_of_items',
      titleSpan: TextSpan(
        text: AppRouter.l10n.noOfItems,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.createdBy,
      field: 'created_by',
      titleSpan: TextSpan(
        text: AppRouter.l10n.createdBy,
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
        final adjustment = rendererContext.cell.value as StockAdjustments;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              icon: Assets.icons.print.svg(height: 16, width: 16),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primaryColor.withOpacity(.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () {
                PdfService.printStockAdjustment(adjustment).then(AppRouter.pop);
              },
              label: Text(AppRouter.l10n.print),
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
                    title: AppRouter.l10n.deleteStockAdjustment,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppRouter.l10n.areYouSureYouWantToDeleteThisStockAdjustment,
                        style: AppText.mediumN.copyWith(color: AppColors.primaryColor),
                      ),
                    ],
                    onPositive: (ref) {
                      ref
                          .read(stockAdjustmentsNotifierProvider.notifier)
                          .deleteStockAdjustment(adjustment.adjustmentId!)
                          .then(AppRouter.pop);
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
