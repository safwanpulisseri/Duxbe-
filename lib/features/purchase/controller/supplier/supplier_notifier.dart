import 'dart:async';

import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/purchase/presentation/supplier_list/supplier_settlement.dart';
import 'package:duxbe/features/purchase/purchase.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'supplier_notifier.freezed.dart';
part 'supplier_notifier.g.dart';
part 'supplier_state.dart';

@Riverpod(keepAlive: false)
Future<Supplier?> supplier(
  SupplierRef ref,
  String? supplierId,
) async =>
    supplierId == null ? null : ref.watch(supplierRepoProvider).getSupplierWithId(supplierId: supplierId);

@Riverpod(keepAlive: false)
class SupplierNotifier extends _$SupplierNotifier {
  late ISupplierRepository _supplierRepository;

  @override
  SupplierState build() {
    _supplierRepository = ref.watch(supplierRepoProvider); // Watch for business changes
    ref.listen(businessNotifierProvider, (previous, next) {
      // Refresh the paging controller when business changes
      state.pagingController?.refresh();
      getSuppliers(pageNumber: 1);
    });

    state = SupplierState.initial();

    // This is to set infinte scrolling in mobile devices
    return state.copyWith(
      pagingController: PagingController<int, Supplier>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener(
          (pageKey) async {
            final suppliers = await getSuppliers(pageNumber: pageKey);
            final isLastPage = suppliers.data.length < state.pageSize;
            if (isLastPage) {
              state.pagingController!.appendLastPage(suppliers.data);
            } else {
              final nextPageKey = pageKey + 1;
              state.pagingController!.appendPage(suppliers.data, nextPageKey);
            }
          },
        ),
    );
  }

  void setFilter({String? query}) {
    state = state.copyWith(query: query ?? state.query);
    state.pagingController?.refresh();
    setTable();
  }

  void setStateManager({required PlutoGridStateManager stateManager}) {
    state = state.copyWith(stateManager: stateManager);
    setTable();
  }

  Future<PaginatedResponse<Supplier>> getSuppliers({
    String? query,
    int? pageSize,
    int? pageNumber,
  }) async {
    try {
      final suppliers = await _supplierRepository.getSuppliers(
        query: query ?? state.query,
        pageSize: pageSize ?? state.pageSize,
        pageNumber: pageNumber ?? state.pageNumber,
      );
      return suppliers;
    } catch (e) {
      state = state.copyWith(
        status: SupplierStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<Supplier> upsertSupplier(Supplier supplier, {dynamic image}) async {
    try {
      state = state.copyWith(status: SupplierStatus.loading);
      final updatedSupplier = await _supplierRepository.upsertSupplier(supplier, image: image);
      state = state.copyWith(status: SupplierStatus.success);
      setFilter();
      return updatedSupplier;
    } catch (e) {
      state = state.copyWith(
        status: SupplierStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<void> deleteSupplier(Supplier supplier) async {
    try {
      state = state.copyWith(status: SupplierStatus.loading);
      await _supplierRepository.deleteSupplier(supplier.supplierId!);
      state = state.copyWith(status: SupplierStatus.success);
      setFilter();
    } catch (e) {
      state = state.copyWith(
        status: SupplierStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
    }
  }

  Future<void> setTable({
    String? query,
    int? pageSize,
    int? pageNumber,
  }) async {
    state.stateManager?.setShowLoading(true);
    state = state.copyWith(status: SupplierStatus.loading);
    final suppliers = await getSuppliers(
      query: query,
      pageSize: pageSize,
      pageNumber: pageNumber,
    );
    state = state.copyWith(
      status: SupplierStatus.success,
      suppliers: suppliers.data,
      count: suppliers.count,
      pageNumber: pageNumber ?? state.pageNumber,
    );
    final baseIndex = (state.pageNumber - 1) * state.pageSize + 1;
    final rows = await PlutoGridStateManager.initializeRowsAsync(
      supplierColumns,
      [
        for (int i = 0; i < state.suppliers.length; i++)
          PlutoRow(
            cells: {
              'sl_no': PlutoCell(value: baseIndex + i),
              'name': PlutoCell(value: state.suppliers[i].name),
              'phone': PlutoCell(value: state.suppliers[i].phone),
              'email': PlutoCell(value: state.suppliers[i].email),
              'supplier_balance': PlutoCell(value: state.suppliers[i].supplierBalance),
              'actions': PlutoCell(value: state.suppliers[i]),
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
      title: AppRouter.l10n.phoneNo,
      field: 'phone',
      titleSpan: TextSpan(
        text: AppRouter.l10n.phoneNo,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.email,
      field: 'email',
      titleSpan: TextSpan(
        text: AppRouter.l10n.email,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.supplierBalance,
      field: 'supplier_balance',
      titleSpan: TextSpan(
        text: AppRouter.l10n.supplierBalance,
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
        final supplier = rendererContext.cell.value as Supplier;
        return MenuAnchor(
          builder: (context, controller, child) {
            return IconButton(
              onPressed: controller.isOpen ? controller.close : controller.open,
              icon: const Icon(Icons.more_horiz),
            );
          },
          menuChildren: [
            MenuItemButton(
              leadingIcon: Assets.icons.edit.svg(width: 20),
              style: MenuItemButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
              ),
              onPressed: () {
                AppRouter.goNamed(
                  AppRouter.supplierDetails,
                  pathParameters: {
                    'id': supplier.supplierId!,
                  },
                );
              },
              child: Text(AppRouter.l10n.edit),
            ),
            MenuItemButton(
              leadingIcon: Assets.icons.delete.svg(width: 20),
              onPressed: () {
                showDialog<void>(
                  context: AppRouter.rootContext,
                  builder: (context) => ConfirmationDialog(
                    title: AppRouter.l10n.deleteSupplier,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppRouter.l10n.areYouSureWantToDeleteSupplierName(supplier.name),
                        style: AppText.mediumN.copyWith(color: AppColors.primaryColor),
                      ),
                    ],
                    onPositive: (ref) {
                      ref.read(supplierNotifierProvider.notifier).deleteSupplier(supplier).then(context.pop);
                    },
                  ),
                );
              },
              style: MenuItemButton.styleFrom(foregroundColor: AppColors.red),
              child: Text(AppRouter.l10n.delete),
            ),
            Consumer(
              builder: (context, ref, child) {
                return MenuItemButton(
                  leadingIcon: const Icon(Icons.description, color: AppColors.primaryColor),
                  onPressed: () {
                    showDialog<void>(
                      context: AppRouter.rootContext,
                      builder: (context) {
                        return SupplierSettlementDialog(
                          supplierId: supplier.supplierId!,
                        );
                      },
                    );
                  },
                  style: MenuItemButton.styleFrom(foregroundColor: AppColors.primaryColor),
                  child: Text(AppRouter.l10n.settlements),
                );
              },
            ),
          ],
        );
      },
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
  ];
}
