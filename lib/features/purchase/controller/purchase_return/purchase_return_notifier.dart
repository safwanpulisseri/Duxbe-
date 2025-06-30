import 'dart:async';

import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/purchase/purchase.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'purchase_return_notifier.freezed.dart';
part 'purchase_return_notifier.g.dart';
part 'purchase_return_state.dart';

@Riverpod(keepAlive: false)
Future<PurchaseReturn?> purchaseReturn(
  PurchaseReturnRef ref,
  String? purchaseReturnId,
) async =>
    purchaseReturnId == null ? null : ref.watch(purchaseRepoProvider).getPurchaseReturnWithId(purchaseReturnId: purchaseReturnId);

@Riverpod(keepAlive: false)
class PurchaseReturnNotifier extends _$PurchaseReturnNotifier {
  late IPurchaseRepository _purchaseRepository;
  @override
  PurchaseReturnState build() {
    _purchaseRepository = ref.watch(purchaseRepoProvider); // Watch for business changes
    ref.listen(businessNotifierProvider, (previous, next) {
      // Refresh the paging controller when business changes
      state.pagingController?.refresh();
      getPurchaseReturns(pageNumber: 1);
    });

    state = PurchaseReturnState.initial();

    // This is to set infinte scrolling in mobile devices
    return state.copyWith(
      pagingController: PagingController<int, PurchaseReturn>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener(
          (pageKey) async {
            final returns = await getPurchaseReturns(pageNumber: pageKey);
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
    getPurchaseReturns();
  }

  Future<List<PurchaseReturn>> getPurchaseReturns({
    String? query,
    int? pageSize,
    int? pageNumber,
  }) async {
    try {
      state.stateManager?.setShowLoading(true);
      state = state.copyWith(status: PurchaseReturnStatus.loading);
      final returns = await _purchaseRepository.getPurchaseReturns(
        query: query ?? state.query,
        pageSize: pageSize ?? state.pageSize,
        pageNumber: pageNumber ?? state.pageNumber,
      );
      state = state.copyWith(
        status: PurchaseReturnStatus.success,
        returns: returns.data,
        count: returns.count,
        pageNumber: pageNumber ?? state.pageNumber,
      );
      unawaited(setTable());
      return returns.data;
    } catch (e) {
      state = state.copyWith(
        status: PurchaseReturnStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      return [];
    }
  }

  Future<void> createPurchaseReturn({required CreatePurchaseReturn data}) async {
    try {
      state = state.copyWith(status: PurchaseReturnStatus.loading);
      await _purchaseRepository.createPurchaseReturnTransaction(data);
      state = state.copyWith(status: PurchaseReturnStatus.success);
      unawaited(getPurchaseReturns());
    } catch (e) {
      state = state.copyWith(
        status: PurchaseReturnStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
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
              'supplier': PlutoCell(value: state.returns[i].supplier.name),
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
      title: AppRouter.l10n.supplierName,
      field: 'supplier',
      titleSpan: TextSpan(
        text: AppRouter.l10n.supplierName,
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
        final value = rendererContext.cell.value as PurchaseReturn;
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
                AppRouter.goNamed(AppRouter.purchaseReturnDetails, pathParameters: {'id': value.returnId});
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
