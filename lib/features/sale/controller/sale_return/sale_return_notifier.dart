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

part 'sale_return_notifier.freezed.dart';
part 'sale_return_notifier.g.dart';
part 'sale_return_state.dart';

@Riverpod(keepAlive: false)
Future<SaleReturn?> saleReturn(
  SaleReturnRef ref,
  String? saleReturnId,
) async =>
    saleReturnId == null ? null : ref.watch(saleRepoProvider).getSaleReturnWithId(saleReturnId: saleReturnId);

@Riverpod(keepAlive: false)
class SaleReturnNotifier extends _$SaleReturnNotifier {
  late ISaleRepository _saleRepository;
  @override
  SaleReturnState build() {
    _saleRepository = ref.watch(saleRepoProvider); // Watch for business changes
    ref.listen(businessNotifierProvider, (previous, next) {
      // Refresh the paging controller when business changes
      state.pagingController?.refresh();
      getSaleReturns(pageNumber: 1);
    });

    state = SaleReturnState.initial();

    // This is to set infinte scrolling in mobile devices
    return state.copyWith(
      pagingController: PagingController<int, SaleReturn>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener(
          (pageKey) async {
            final returns = await getSaleReturns(pageNumber: pageKey);
            final isLastPage = returns.length < state.pageSize;
            if (isLastPage) {
              state.pagingController!.appendLastPage(returns);
            } else {
              final nextPageKey = pageKey + 1;
              state.pagingController!.appendPage(returns, nextPageKey);
            }
          },
        ),
    );
  }

  void setStateManager({required PlutoGridStateManager stateManager}) {
    state = state.copyWith(stateManager: stateManager);
    getSaleReturns();
  }

  Future<List<SaleReturn>> getSaleReturns({
    String? query,
    int? pageSize,
    int? pageNumber,
  }) async {
    try {
      state.stateManager?.setShowLoading(true);
      state = state.copyWith(status: SaleReturnStatus.loading);
      final returns = await _saleRepository.getSaleReturns(
        query: query ?? state.query,
        pageSize: pageSize ?? state.pageSize,
        pageNumber: pageNumber ?? state.pageNumber,
      );
      state = state.copyWith(
        status: SaleReturnStatus.success,
        returns: returns.data,
        count: returns.count,
        pageNumber: pageNumber ?? state.pageNumber,
      );
      unawaited(setTable());
      return returns.data;
    } catch (e) {
      state = state.copyWith(
        status: SaleReturnStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      return [];
    }
  }

  Future<void> setTable() async {
    final baseIndex = (state.pageNumber - 1) * state.pageSize + 1;
    final rows = await PlutoGridStateManager.initializeRowsAsync(
      supplierColumns,
      [
        for (int i = 0; i < state.returns.length; i++)
          PlutoRow(
            cells: {
              'sl_no': PlutoCell(value: baseIndex + i),
              'invoice': PlutoCell(value: state.returns[i].returnInvoice),
              'date': PlutoCell(value: state.returns[i].returnDate.toFullFormat),
              'customer': PlutoCell(value: state.returns[i].customer?.name ?? AppRouter.l10n.walkInCustomer),
              'amount': PlutoCell(value: state.returns[i].returnAmount),
              'actions': PlutoCell(value: state.returns[i]),
            },
          ),
      ],
    );
    state.stateManager?.refRows.clear();
    state.stateManager?.refRows.addAll(rows);
    state.stateManager?.setShowLoading(false);
  }

  Future<void> createSaleReturn({required CreateSaleReturn data}) async {
    try {
      state = state.copyWith(status: SaleReturnStatus.loading);
      await _saleRepository.createSaleReturnTransaction(data);
      state = state.copyWith(status: SaleReturnStatus.success);
      unawaited(getSaleReturns());
    } catch (e) {
      state = state.copyWith(
        status: SaleReturnStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
    }
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
      title: AppRouter.l10n.invoice,
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
      titleTextAlign: PlutoColumnTextAlign.center,
      title: AppRouter.l10n.actions,
      field: 'actions',
      titleSpan: TextSpan(
        text: AppRouter.l10n.actions,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      renderer: (rendererContext) {
        final value = rendererContext.cell.value as SaleReturn;
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
                AppRouter.goNamed(AppRouter.saleReturnDetails, pathParameters: {'id': value.returnId});
              },
              child: Text(AppRouter.l10n.view),
            ),
            MenuItemButton(
              leadingIcon: const Icon(Icons.print, color: AppColors.primaryColor),
              onPressed: () {},
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
