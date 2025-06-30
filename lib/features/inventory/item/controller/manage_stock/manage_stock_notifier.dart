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

part 'manage_stock_notifier.freezed.dart';
part 'manage_stock_notifier.g.dart';
part 'manage_stock_state.dart';

@Riverpod(keepAlive: false)
class ManageStockNotifier extends _$ManageStockNotifier {
  late IItemRepository _itemRepository;

  @override
  ManageStockState build() {
    _itemRepository = ref.watch(itemRepoProvider); // Watch for business changes
    ref.listen(businessNotifierProvider, (previous, next) {
      // Refresh the paging controller when business changes
      setFilter(pageNumber: 1);
    });

    state = ManageStockState.initial();

    // This is to set infinte scrolling in mobile devices
    return state.copyWith(
      pagingController: PagingController<int, Item>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener(
          (pageKey) async {
            final items = await getItems(pageNumber: pageKey);
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
    state = state.copyWith(query: query ?? state.query, pageSize: pageSize ?? state.pageSize, pageNumber: pageNumber ?? state.pageNumber);
    state.pagingController?.refresh();
    setTable();
  }

  void setStateManager({required PlutoGridStateManager stateManager}) {
    state = state.copyWith(stateManager: stateManager);
    setTable();
  }

  Future<void> adjustStock(Map<String, dynamic> adjustment) async {
    try {
      state = state.copyWith(status: ManageStockStatus.loading);
      await _itemRepository.adjustStock(adjustment);
      state = state.copyWith(status: ManageStockStatus.success);
      setFilter(pageNumber: 1);
      return;
    } catch (e) {
      state = state.copyWith(
        status: ManageStockStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<PaginatedResponse<Item>> getItems({
    String? query,
    int? pageSize,
    int? pageNumber,
  }) async {
    try {
      final items = await _itemRepository.getItems(
        query: query ?? state.query,
        pageSize: pageSize ?? state.pageSize,
        pageNumber: pageNumber ?? state.pageNumber,
        itemType: ItemType.goods.name,
      );
      return items;
    } catch (e) {
      state = state.copyWith(
        status: ManageStockStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<void> setTable() async {
    if (state.stateManager == null) return;
    state.stateManager?.setShowLoading(true);
    state = state.copyWith(status: ManageStockStatus.loading);

    final items = await getItems();

    state = state.copyWith(
      status: ManageStockStatus.success,
      items: items.data,
      count: items.count,
    );

    final baseIndex = (state.pageNumber - 1) * state.pageSize + 1;
    final rows = await PlutoGridStateManager.initializeRowsAsync(
      itemColumns,
      [
        for (int i = 0; i < state.items.length; i++)
          PlutoRow(
            
            cells: {
              'sl_no': PlutoCell(value: baseIndex + i),
              'code': PlutoCell(value: state.items[i].itemCode),
              'item_name': PlutoCell(value: state.items[i].name,),
              'category': PlutoCell(value: state.items[i].itemCategory?.name ?? ''),
              'current_stock':
                  PlutoCell(value: '${state.items[i].stockQuantity} ${state.items[i].unit?.shortName ?? state.items[i].unit?.name ?? ''}'),
              'actions': PlutoCell(value: state.items[i]),
            },
          ),
      ],
    );
    state.stateManager?.refRows.clear();
    state.stateManager?.refRows.addAll(rows);
    state.stateManager?.setShowLoading(false);
  }

  final List<PlutoColumn> itemColumns = <PlutoColumn>[
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
      renderer: (rendererContext) {
        final text = rendererContext.cell.value as dynamic;
        final item = rendererContext.row.cells['actions']?.value as Item;
        return Text(
          text.toString(),
          style: AppText.mediumN.copyWith(color: item.alertQuantity > item.stockQuantity ? AppColors.red : null),
        );
      },
    ),
    PlutoColumn(
      title: AppRouter.l10n.code,
      field: 'code',
      titleSpan: TextSpan(
        text: AppRouter.l10n.itemCode,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
      renderer: (rendererContext) {
        final text = rendererContext.cell.value as dynamic;
        final item = rendererContext.row.cells['actions']?.value as Item;
        return Text(
          text.toString(),
          style: AppText.mediumN.copyWith(color: item.alertQuantity > item.stockQuantity ? AppColors.red : null),
        );
      },
    ),
    PlutoColumn(
      title: AppRouter.l10n.itemName,
      field: 'item_name',
      titleSpan: TextSpan(
        text: AppRouter.l10n.itemName,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
      renderer: (rendererContext) {
        final text = rendererContext.cell.value as dynamic;
        final item = rendererContext.row.cells['actions']?.value as Item;
        return Text(
          text.toString(),
          style: AppText.mediumN.copyWith(color: item.alertQuantity > item.stockQuantity ? AppColors.red : null),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    ),
    PlutoColumn(
      title: AppRouter.l10n.category,
      field: 'category',
      titleSpan: TextSpan(
        text: AppRouter.l10n.itemCategory,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
      renderer: (rendererContext) {
        final text = rendererContext.cell.value as dynamic;
        final item = rendererContext.row.cells['actions']?.value as Item;
        return Text(
          text.toString(),
          style: AppText.mediumN.copyWith(color: item.alertQuantity > item.stockQuantity ? AppColors.red : null),
        );
      },
    ),
    PlutoColumn(
      title: AppRouter.l10n.currentStock,
      field: 'current_stock',
      titleSpan: TextSpan(
        text: AppRouter.l10n.currentStock,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
      renderer: (rendererContext) {
        final text = rendererContext.cell.value as dynamic;
        final item = rendererContext.row.cells['actions']?.value as Item;
        return Text(
          text.toString(),
          style: AppText.mediumN.copyWith(color: item.alertQuantity > item.stockQuantity ? AppColors.red : null),
        );
      },
    ),
    PlutoColumn(
      titleTextAlign: PlutoColumnTextAlign.center,
        title: AppRouter.l10n.actions,
      field: 'actions',
      titleSpan: TextSpan(
        text: AppRouter.l10n.action,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      renderer: (rendererContext) {
        final item = rendererContext.cell.value as Item;
        return TextButton(
          onPressed: () {
            AppRouter.pushNamed(
              AppRouter.singleStockAdjust,
              pathParameters: {'id': item.itemId!},
            );
          },
          child: Text(AppRouter.l10n.stockAdjustment),
        );
      },
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
  ];
}
