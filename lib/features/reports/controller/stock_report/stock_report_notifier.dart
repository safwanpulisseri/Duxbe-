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

part 'stock_report_notifier.freezed.dart';
part 'stock_report_notifier.g.dart';
part 'stock_report_state.dart';

@Riverpod(keepAlive: true)
Future<num> totalStockValue(TotalStockValueRef ref) async => ref.watch(itemRepoProvider).getTotalStockValue();

@Riverpod(keepAlive: false)
class StockReportNotifier extends _$StockReportNotifier {
  late IItemRepository _itemRepository;
  @override
  StockReportState build() {
    _itemRepository = ref.watch(itemRepoProvider);
    ref.listen(businessNotifierProvider, (previous, next) {
      // Refresh the paging controller when business changes
      setFilter(pageNumber: 1);
    });

    state = StockReportState.initial();

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
      inStockPagingController: PagingController<int, Item>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener(
          (pageKey) async {
            final items = await getItems(pageNumber: pageKey, stockStatus: 'In Stock');
            final isLastPage = items.data.length < state.pageSize;
            if (isLastPage) {
              state.inStockPagingController!.appendLastPage(items.data);
            } else {
              final nextPageKey = pageKey + 1;
              state.inStockPagingController!.appendPage(items.data, nextPageKey);
            }
          },
        ),
      outOfStockPagingController: PagingController<int, Item>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener(
          (pageKey) async {
            final items = await getItems(pageNumber: pageKey, stockStatus: 'Out of Stock');
            final isLastPage = items.data.length < state.pageSize;
            if (isLastPage) {
              state.outOfStockPagingController!.appendLastPage(items.data);
            } else {
              final nextPageKey = pageKey + 1;
              state.outOfStockPagingController!.appendPage(items.data, nextPageKey);
            }
          },
        ),
      lowStockPagingController: PagingController<int, Item>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener(
          (pageKey) async {
            final items = await getItems(pageNumber: pageKey, stockStatus: 'Low Stock');
            final isLastPage = items.data.length < state.pageSize;
            if (isLastPage) {
              state.lowStockPagingController!.appendLastPage(items.data);
            } else {
              final nextPageKey = pageKey + 1;
              state.lowStockPagingController!.appendPage(items.data, nextPageKey);
            }
          },
        ),
    );
  }

  void setFilter({
    String? query,
    int? pageSize,
    int? pageNumber,
    String? stockStatus,
  }) {
    state = state.copyWith(
      query: query ?? state.query,
      pageSize: pageSize ?? state.pageSize,
      pageNumber: pageNumber ?? state.pageNumber,
      stockStatus: stockStatus ?? state.stockStatus,
    );
    state.pagingController?.refresh();
    state.inStockPagingController?.refresh();
    state.outOfStockPagingController?.refresh();
    state.lowStockPagingController?.refresh();
    setTable();
  }

  void setStateManager({required PlutoGridStateManager stateManager}) {
    state = state.copyWith(stateManager: stateManager);
    setTable();
  }

  Future<PaginatedResponse<Item>> getItems({
    String? query,
    int? pageSize,
    int? pageNumber,
    String? stockStatus,
  }) async {
    try {
      final items = await _itemRepository.getItems(
        query: query ?? state.query,
        pageSize: pageSize ?? state.pageSize,
        pageNumber: pageNumber ?? state.pageNumber,
        stockStatus: stockStatus ?? state.stockStatus,
      );

      return items;
    } catch (e) {
      state = state.copyWith(
        status: StockReportStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<void> setTable({
    String? query,
    int? pageSize,
    int? pageNumber,
    String? stockStatus,
  }) async {
    state.stateManager?.setShowLoading(true);
    state = state.copyWith(status: StockReportStatus.loading);
    final items = await getItems();
    state = state.copyWith(
      status: StockReportStatus.success,
      items: items.data,
      count: items.count,
      pageNumber: pageNumber ?? state.pageNumber,
    );
    final baseIndex = (state.pageNumber - 1) * state.pageSize + 1;
    final rows = await PlutoGridStateManager.initializeRowsAsync(
      stockReportColumns,
      [
        for (int i = 0; i < state.items.length; i++)
          PlutoRow(
            cells: {
              'sl_no': PlutoCell(value: baseIndex + i),
              'name': PlutoCell(value: state.items[i].name),
              'category': PlutoCell(value: state.items[i].itemCategory?.name ?? ''),
              'purchase_price': PlutoCell(value: state.items[i].purchasePrice),
              'quantity': PlutoCell(value: state.items[i].stockQuantity),
              'status': PlutoCell(value: state.items[i].inventoryEnabled? state.items[i].stockStatus:'Non-Inventory'),
              'total_stock_value': PlutoCell(value: state.items[i].stockValue),
            },
          ),
      ],
    );
    state.stateManager?.refRows.clear();
    state.stateManager?.refRows.addAll(rows);
    state.stateManager?.setShowLoading(false);
  }

  Future<void> exportStockReport() async {
    try {
      state = state.copyWith(status: StockReportStatus.loading);
      final stockReport = await _itemRepository.getItems(
        query: state.query,
        pageSize: state.pageSize,
        pageNumber: state.pageNumber,
        stockStatus: state.stockStatus,
      );
      state = state.copyWith(status: StockReportStatus.success);
      unawaited(
        exportToExcel(
          stockReport.data
              .map(
                (e) => {
                  'Name': e.name,
                  'Category': e.itemCategory?.name ?? '',
                  'Purchase Price': e.purchasePrice,
                  'Quantity': e.stockQuantity,
                  'Status':e.inventoryEnabled? e.stockStatus:'Non-Inventory',
                  'Total Stock Value': e.stockValue,
                },
              )
              .toList(),
          'Stock Report - ${state.stockStatus ?? 'All'}',
        ),
      );
    } catch (e) {
      state = state.copyWith(
        status: StockReportStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
    }
  }

  final List<PlutoColumn> stockReportColumns = <PlutoColumn>[
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
      title: AppRouter.l10n.name,
      field: 'name',
      titleSpan: TextSpan(
        text: AppRouter.l10n.name,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.category,
      field: 'category',
      titleSpan: TextSpan(
        text: AppRouter.l10n.category,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.purchasePrice,
      field: 'purchase_price',
      titleSpan: TextSpan(
        text: AppRouter.l10n.purchasePrice,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.quantity,
      field: 'quantity',
      titleSpan: TextSpan(
        text: AppRouter.l10n.quantity,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.status,
      field: 'status',
      titleSpan: TextSpan(
        text: AppRouter.l10n.status,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.totalStockValue,
      field: 'total_stock_value',
      titleSpan: TextSpan(
        text: AppRouter.l10n.totalStockValue,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
  ];
}
