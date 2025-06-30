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

part 'sale_list_notifier.freezed.dart';
part 'sale_list_notifier.g.dart';
part 'sale_list_state.dart';

@Riverpod(keepAlive: false)
Future<SaleView?> sale(
  SaleRef ref,
  String? saleId,
) async =>
    saleId == null ? null : ref.watch(saleRepoProvider).getSaleWithId(saleId: saleId);

@Riverpod(keepAlive: false)
class SaleListNotifier extends _$SaleListNotifier {
  late ISaleRepository _saleRepository;
  @override
  SaleListState build() {
    _saleRepository = ref.watch(saleRepoProvider); // Watch for business changes
    ref.listen(businessNotifierProvider, (previous, next) {
      // Refresh the paging controller when business changes
      setFilter(pageNumber: 1);
    });

    state = SaleListState.initial();

    // This is to set infinte scrolling in mobile devices
    return state.copyWith(
      pagingController: PagingController<int, SaleView>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener(
          (pageKey) async {
            final sales = await getSales(pageNumber: pageKey);
            final isLastPage = sales.data.length < state.pageSize;
            if (isLastPage) {
              state.pagingController!.appendLastPage(sales.data);
            } else {
              final nextPageKey = pageKey + 1;
              state.pagingController!.appendPage(sales.data, nextPageKey);
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
    int? pageSize,
    int? pageNumber,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    state = state.copyWith(
      query: query ?? state.query,
      pageSize: pageSize ?? state.pageSize,
      pageNumber: pageNumber ?? state.pageNumber,
      startDate: startDate,
      endDate: endDate,
    );
    state.pagingController?.refresh();
    setTable();
  }

  Future<PaginatedResponse<SaleView>> getSales({
    String? query,
    int? pageSize,
    int? pageNumber,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final sales = await _saleRepository.getSales(
        query: query ?? state.query,
        pageSize: pageSize ?? state.pageSize,
        pageNumber: pageNumber ?? state.pageNumber,
        fromDate: fromDate ?? state.startDate,
        toDate: toDate ?? state.endDate,
      );
      return sales;
    } catch (e) {
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<void> setTable() async {
    if (state.stateManager == null) return;

    state.stateManager?.setShowLoading(true);
    state = state.copyWith(status: SaleListStatus.loading);
    final sales = await getSales();
    state = state.copyWith(
      status: SaleListStatus.success,
      sales: sales.data,
      count: sales.count,
    );

    final baseIndex = (state.pageNumber - 1) * state.pageSize + 1;
    final rows = await PlutoGridStateManager.initializeRowsAsync(
      supplierColumns,
      [
        for (int i = 0; i < state.sales.length; i++)
          PlutoRow(
            cells: {
              'sl_no': PlutoCell(value: baseIndex + i),
              'invoice': PlutoCell(value: state.sales[i].saleInvoice),
              'date': PlutoCell(value: state.sales[i].saleDate.toLocal().toFullFormat),
              'customer': PlutoCell(value: state.sales[i].customer?.name ?? AppRouter.l10n.walkInCustomer),
              'payment_type': PlutoCell(
                value: state.sales[i].payments.map((e) => e.paymentMethod.name.displayCase).toSet().join(', '),
              ),
              'amount': PlutoCell(value: state.sales[i].totalAmount),
              'due_amount': PlutoCell(value: state.sales[i].dueAmount),
              'payment_status': PlutoCell(value: state.sales[i].transaction.status.name.displayCase),
              'actions': PlutoCell(value: state.sales[i]),
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
                AppRouter.goNamed(
                  AppRouter.saleDetails,
                  pathParameters: {'id': value.saleId},
                );
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
