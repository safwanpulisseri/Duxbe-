import 'dart:async';

import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'order_list_notifier.freezed.dart';
part 'order_list_notifier.g.dart';
part 'order_list_state.dart';

@Riverpod(keepAlive: false)
class OrderListNotifier extends _$OrderListNotifier {
  late ISaleRepository _saleRepository;
  @override
  OrderListState build() {
    _saleRepository = ref.watch(saleRepoProvider); // Watch for business changes
    ref.listen(businessNotifierProvider, (previous, next) {
      // Refresh the paging controller when business changes
      setFilter(pageNumber: 1);
    });

    state = OrderListState.initial();

    // This is to set infinte scrolling in mobile devices
    return state.copyWith(
      pagingController: PagingController<int, SaleView>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener(
          (pageKey) async {
            final orders = await getOrders(pageNumber: pageKey);
            final isLastPage = orders.data.length < state.pageSize;
            if (isLastPage) {
              state.pagingController!.appendLastPage(orders.data);
            } else {
              final nextPageKey = pageKey + 1;
              state.pagingController!.appendPage(orders.data, nextPageKey);
            }
          },
        ),
    );
  }

  void setStateManager({required PlutoGridStateManager stateManager}) {
    state = state.copyWith(stateManager: stateManager);
    setTable();
  }

  void setFilter({
    String? query,
    int? pageNumber,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    state = state.copyWith(
      query: query ?? state.query,
      pageNumber: pageNumber ?? state.pageNumber,
      startDate: startDate,
      endDate: endDate,
    );
    state.pagingController?.refresh();
    setTable();
  }

  Future<PaginatedResponse<SaleView>> getOrders({
    String? query,
    int? pageSize,
    int? pageNumber,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final orders = await _saleRepository.getSales(
        query: query ?? state.query,
        pageSize: pageSize ?? state.pageSize,
        pageNumber: pageNumber ?? state.pageNumber,
        orderMode: true,
        fromDate: fromDate ?? state.startDate,
        toDate: toDate ?? state.endDate,
      );
      return orders;
    } catch (e) {
      state = state.copyWith(
        status: OrderListStatus.error,
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
  }) async {
    state.stateManager?.setShowLoading(true);
    state = state.copyWith(status: OrderListStatus.loading);
    final orders = await getOrders(query: query, pageSize: pageSize, pageNumber: pageNumber);
    state = state.copyWith(
      status: OrderListStatus.success,
      orders: orders.data,
      count: orders.count,
      pageNumber: pageNumber ?? state.pageNumber,
    );
    final baseIndex = (state.pageNumber - 1) * state.pageSize + 1;
    final rows = await PlutoGridStateManager.initializeRowsAsync(
      supplierColumns,
      [
        for (int i = 0; i < state.orders.length; i++)
          PlutoRow(
            cells: {
              'sl_no': PlutoCell(value: baseIndex + i),
              'invoice': PlutoCell(value: state.orders[i].saleInvoice),
              'date': PlutoCell(value: state.orders[i].saleDate.toLocal().toFullFormat),
              'customer': PlutoCell(value: state.orders[i].customer?.name ?? AppRouter.l10n.walkInCustomer),
              'payment_type': PlutoCell(value: state.orders[i].payments.map((e) => e.paymentMethod.name.displayCase).toSet().join(', ')),
              'amount': PlutoCell(value: state.orders[i].totalAmount),
              'due_amount': PlutoCell(value: state.orders[i].dueAmount),
              'payment_status': PlutoCell(value: state.orders[i].transaction.status.name.displayCase),
              'status': PlutoCell(value: state.orders[i].status!.name.displayCase),
              'actions': PlutoCell(value: state.orders[i]),
            },
          ),
      ],
    );
    state.stateManager?.refRows.clear();
    state.stateManager?.refRows.addAll(rows);
    state.stateManager?.setShowLoading(false);
  }

  final List<PlutoColumn> supplierColumns = <PlutoColumn>[
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
      title: AppRouter.l10n.invoiceNo,
      field: 'invoice',
      titleSpan: TextSpan(
        text: AppRouter.l10n.invoice,
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
      title: AppRouter.l10n.customerName,
      field: 'customer',
      titleSpan: TextSpan(
        text: AppRouter.l10n.customerName,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.paymentType,
      field: 'payment_type',
      titleSpan: TextSpan(
        text: AppRouter.l10n.paymentType,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.amount,
      field: 'amount',
      titleSpan: TextSpan(
        text: AppRouter.l10n.amount,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.dueAmount,
      field: 'due_amount',
      titleSpan: TextSpan(
        text: AppRouter.l10n.dueAmount,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.paymentStatus,
      field: 'payment_status',
      titleSpan: TextSpan(
        text: AppRouter.l10n.paymentStatus,
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
      titleTextAlign: PlutoColumnTextAlign.center,
        title: AppRouter.l10n.actions,
      field: 'actions',
      titleSpan: TextSpan(
        text: AppRouter.l10n.actions,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      renderer: (rendererContext) {
        final value = rendererContext.cell.value as SaleView;
        return MenuAnchor(
          builder: (context, controller, child) {
            return IconButton(
              onPressed: controller.isOpen ? controller.close : controller.open,
              icon: const Icon(Icons.more_horiz),
            );
          },
          menuChildren: [
            MenuItemButton(
              leadingIcon: const Icon(
                Icons.remove_red_eye,
                color: AppColors.primaryColor,
              ),
              style: MenuItemButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
              ),
              onPressed: () {
                AppRouter.pushNamed(AppRouter.orderDetails, pathParameters: {'id': value.saleId});
              },
              child: Text(AppRouter.l10n.view),
            ),
            MenuItemButton(
              leadingIcon: const Icon(
                Icons.restore_rounded,
                color: AppColors.primaryColor,
              ),
              style: MenuItemButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
              ),
              onPressed: () {
                AppRouter.pushNamed(AppRouter.createSaleReturn, queryParameters: {'id': value.saleId});
              },
              child: Text(AppRouter.l10n.saleReturn),
            ),
            MenuItemButton(
              leadingIcon: const Icon(Icons.print, color: AppColors.primaryColor),
              onPressed: () {
                PdfService.printSaleInvoice(value);
              },
              style: MenuItemButton.styleFrom(foregroundColor: AppColors.primaryColor),
              child: Text(AppRouter.l10n.print),
            ),
          ],
        );
      },
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
  ];
}
