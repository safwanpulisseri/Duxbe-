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

part 'purchase_list_notifier.freezed.dart';
part 'purchase_list_notifier.g.dart';
part 'purchase_list_state.dart';

@Riverpod(keepAlive: false)
Future<PurchaseView?> purchase(
  PurchaseRef ref,
  String? purchaseId,
) async =>
    purchaseId == null ? null : ref.watch(purchaseRepoProvider).getPurchaseWithId(purchaseId: purchaseId);

@Riverpod(keepAlive: false)
class PurchaseListNotifier extends _$PurchaseListNotifier {
  late IPurchaseRepository _purchaseRepository;

  @override
  PurchaseListState build() {
    _purchaseRepository = ref.watch(purchaseRepoProvider); // Watch for business changes
    ref.listen(businessNotifierProvider, (previous, next) {
      // Refresh the paging controller when business changes
      state.pagingController?.refresh();
      getPurchases(pageNumber: 1);
    });

    state = PurchaseListState.initial();

    // This is to set infinte scrolling in mobile devices
    return state.copyWith(
      pagingController: PagingController<int, PurchaseView>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener(
          (pageKey) async {
            final purchases = await getPurchases(pageNumber: pageKey);
            final isLastPage = purchases.data.length < state.pageSize;
            if (isLastPage) {
              state.pagingController!.appendLastPage(purchases.data);
            } else {
              final nextPageKey = pageKey + 1;
              state.pagingController!.appendPage(purchases.data, nextPageKey);
            }
          },
        ),
    );
  }

  void setStateManager({required PlutoGridStateManager stateManager}) {
    state = state.copyWith(stateManager: stateManager);
    setTable();
  }

  void setFilter({String? query}) {
    state = state.copyWith(query: query ?? state.query);
    state.pagingController?.refresh();
    setTable();
  }

  Future<PaginatedResponse<PurchaseView>> getPurchases({
    String? query,
    int? pageSize,
    int? pageNumber,
  }) async {
    try {
      final purchases = await _purchaseRepository.getPurchases(
        query: query ?? state.query,
        pageSize: pageSize ?? state.pageSize,
        pageNumber: pageNumber ?? state.pageNumber,
      );
      return purchases;
    } catch (e) {
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
    state = state.copyWith(status: PurchaseListStatus.loading);
    final purchases = await getPurchases(query: query, pageSize: pageSize, pageNumber: pageNumber);
    state = state.copyWith(
      status: PurchaseListStatus.success,
      purchases: purchases.data,
      count: purchases.count,
      pageNumber: pageNumber ?? state.pageNumber,
    );
    final baseIndex = (state.pageNumber - 1) * state.pageSize + 1;
    final rows = await PlutoGridStateManager.initializeRowsAsync(
      supplierColumns,
      [
        for (int i = 0; i < state.purchases.length; i++)
          PlutoRow(
            cells: {
              'sl_no': PlutoCell(value: baseIndex + i),
              'invoice': PlutoCell(value: state.purchases[i].invoiceNo),
              'date': PlutoCell(value: state.purchases[i].purchaseDate.toLocal().toFullFormat),
              'supplier': PlutoCell(value: state.purchases[i].supplier.name),
              'payment_type': PlutoCell(
                value: state.purchases[i].payments.map((e) => e.paymentMethod.name.displayCase).toSet().join(', '),
              ),
              'amount': PlutoCell(value: state.purchases[i].totalAmount),
              'due_amount': PlutoCell(value: state.purchases[i].dueAmount),
              'status': PlutoCell(value: state.purchases[i].transaction.status.name.displayCase),
              'actions': PlutoCell(value: state.purchases[i]),
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
        final value = rendererContext.cell.value as PurchaseView;
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
                AppRouter.pushNamed(AppRouter.purchaseDetails, pathParameters: {'id': value.purchaseId});
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
                AppRouter.pushNamed(AppRouter.createPurchaseReturn, queryParameters: {'id': value.purchaseId});
              },
              child: Text(AppRouter.l10n.purchaseReturn),
            ),
            MenuItemButton(
              leadingIcon: const Icon(Icons.print, color: AppColors.primaryColor),
              onPressed: () {
                PdfService.printPurchaseInvoice(value);
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
