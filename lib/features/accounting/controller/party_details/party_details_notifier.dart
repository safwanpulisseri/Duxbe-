import 'dart:async';

import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/features/purchase/presentation/supplier_list/supplier_settlement.dart';
import 'package:duxbe/features/purchase/purchase.dart';
import 'package:duxbe/features/sale/presentation/customer_list/customer_settlement.dart';
import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'party_details_notifier.freezed.dart';
part 'party_details_notifier.g.dart';
part 'party_details_state.dart';

@Riverpod(keepAlive: false)
class PartyDetailsNotifier extends _$PartyDetailsNotifier {
  late IPurchaseRepository _purchaseRepository;
  late ISaleRepository _saleRepository;
  late ILedgerRepository _ledgerRepository;
  late ICustomerRepository _customerRepository;
  late ISupplierRepository _supplierRepository;
  @override
  PartyDetailsState build(TransactionParty party, String id) {
    _purchaseRepository = ref.watch(purchaseRepoProvider);
    _saleRepository = ref.watch(saleRepoProvider);
    _ledgerRepository = ref.watch(ledgerRepoProvider);
    _customerRepository = ref.watch(customerRepoProvider);
    _supplierRepository = ref.watch(supplierRepoProvider);
    state = PartyDetailsState.initial();
    getPartyDetails();
    return state.copyWith(
      salesPagingController: party == TransactionParty.customer
          ? (PagingController<int, SaleView>(
              firstPageKey: state.pageNumber,
            )..addPageRequestListener(
              (pageKey) async {
                final sales = await getSales(pageNumber: pageKey);
                final isLastPage = sales.length < state.pageSize;
                if (isLastPage) {
                  state.salesPagingController!.appendLastPage(sales);
                } else {
                  final nextPageKey = pageKey + 1;
                  state.salesPagingController!.appendPage(sales, nextPageKey);
                }
              },
            ))
          : null,
      purchasesPagingController: party == TransactionParty.supplier
          ? (PagingController<int, PurchaseView>(
              firstPageKey: state.pageNumber,
            )..addPageRequestListener(
              (pageKey) async {
                final purchases = await getPurchases(pageNumber: pageKey);
                final isLastPage = purchases.length < state.pageSize;
                if (isLastPage) {
                  state.purchasesPagingController!.appendLastPage(purchases);
                } else {
                  final nextPageKey = pageKey + 1;
                  state.purchasesPagingController!.appendPage(purchases, nextPageKey);
                }
              },
            ))
          : null,
    );
  }

  void setStateManager({required PlutoGridStateManager stateManager}) {
    state = state.copyWith(stateManager: stateManager);
  }

  Future<void> getPartyDetails() async {
    try {
      final partyDetails = await _ledgerRepository.getPartyDetails(partyId: id, partyType: party);

      if (party == TransactionParty.customer) {
        final customer = await _customerRepository.getCustomerWithId(customerId: id);
        await getSales(pageNumber: 1);
        state = state.copyWith(
          customer: customer,
          partyDetails: partyDetails,
        );
      } else {
        final supplier = await _supplierRepository.getSupplierWithId(supplierId: id);
        await getPurchases(pageNumber: 1);
        state = state.copyWith(
          supplier: supplier,
          partyDetails: partyDetails,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: PartyDetailsStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<List<SaleView>> getSales({
    String? query,
    int? pageSize,
    int? pageNumber,
  }) async {
    try {
      state.stateManager?.setShowLoading(true);
      state = state.copyWith(status: PartyDetailsStatus.loading);
      final sales = await _saleRepository.getSales(
        query: query ?? state.query,
        pageSize: pageSize ?? state.pageSize,
        pageNumber: pageNumber ?? state.pageNumber,
        customerId: id,
        orderMode: null,
      );
      state = state.copyWith(
        status: PartyDetailsStatus.success,
        sales: sales.data,
        pageNumber: pageNumber ?? state.pageNumber,
        count: sales.count,
      );
      unawaited(setTable());
      return sales.data;
    } catch (e) {
      state = state.copyWith(
        status: PartyDetailsStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      return [];
    }
  }

  Future<List<PurchaseView>> getPurchases({
    String? query,
    int? pageSize,
    int? pageNumber,
  }) async {
    try {
      state.stateManager?.setShowLoading(true);
      state = state.copyWith(status: PartyDetailsStatus.loading);
      final purchases = await _purchaseRepository.getPurchases(
        query: query ?? state.query,
        pageSize: pageSize ?? state.pageSize,
        pageNumber: pageNumber ?? state.pageNumber,
        supplierId: id,
      );
      state = state.copyWith(
        status: PartyDetailsStatus.success,
        purchases: purchases.data,
        pageNumber: pageNumber ?? state.pageNumber,
        count: purchases.count,
      );
      unawaited(setTable());
      return purchases.data;
    } catch (e) {
      state = state.copyWith(
        status: PartyDetailsStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      return [];
    }
  }

  Future<void> setTable() async {
    final baseIndex = (state.pageNumber - 1) * state.pageSize + 1;
    if (party == TransactionParty.customer) {
      final rows = await PlutoGridStateManager.initializeRowsAsync(
        partyDetailsColumns,
        [
          for (int i = 0; i < state.sales.length; i++)
            PlutoRow(
              cells: {
                'sl_no': PlutoCell(value: baseIndex + i),
                'invoice': PlutoCell(value: state.sales[i].saleInvoice),
                'name': PlutoCell(value: state.sales[i].customer?.name ?? AppRouter.l10n.walkInCustomer),
                'type': PlutoCell(
                  value: state.sales[i].payments.map((e) => e.paymentMethod.name.displayCase).toSet().join(', '),
                ),
                'amount': PlutoCell(value: state.sales[i].totalAmount),
                'due': PlutoCell(value: state.sales[i].dueAmount),
                'status': PlutoCell(value: state.sales[i].transaction.status.name.displayCase),
                'actions': PlutoCell(value: state.sales[i]),
              },
            ),
        ],
      );
      state.stateManager?.refRows.clear();
      state.stateManager?.refRows.addAll(rows);
      state.stateManager?.setShowLoading(false);
    } else {
      final rows = await PlutoGridStateManager.initializeRowsAsync(
        partyDetailsColumns,
        [
          for (int i = 0; i < state.purchases.length; i++)
            PlutoRow(
              cells: {
                'sl_no': PlutoCell(value: baseIndex + i),
                'invoice': PlutoCell(value: state.purchases[i].purchaseInvoice),
                'name': PlutoCell(value: state.purchases[i].supplier.name),
                'type': PlutoCell(
                  value: state.purchases[i].payments.map((e) => e.paymentMethod.name.displayCase).toSet().join(', '),
                ),
                'amount': PlutoCell(value: state.purchases[i].totalAmount),
                'due': PlutoCell(value: state.purchases[i].dueAmount),
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
  }

  final List<PlutoColumn> partyDetailsColumns = <PlutoColumn>[
    PlutoColumn(
      title: 'Sl No.',
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
      title: 'Invoice',
      field: 'invoice',
      titleSpan: TextSpan(
        text: AppRouter.l10n.invoice,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: 'Party Name',
      field: 'name',
      titleSpan: TextSpan(
        text: AppRouter.l10n.partyName,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: 'Payment Type',
      field: 'type',
      titleSpan: TextSpan(
        text: AppRouter.l10n.paymentType,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: 'Amount',
      field: 'amount',
      titleSpan: TextSpan(
        text: AppRouter.l10n.amount,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: 'Due',
      field: 'due',
      titleSpan: TextSpan(
        text: AppRouter.l10n.due,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: 'Status',
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
      title: 'Action',
      field: 'actions',
      titleSpan: TextSpan(
        text: AppRouter.l10n.action,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
      renderer: (rendererContext) {
        final data = rendererContext.cell.value;
        if (data is SaleView && data.transaction.dueAmount > 0) {
          return Consumer(
            builder: (context, ref, child) {
              return AppButton(
                padding: const EdgeInsets.all(2),
                label: Text(AppRouter.l10n.settle),
                width: 20,
                style: ButtonStyles.secondary,
                onPress: () {
                  showDialog<void>(
                    context: AppRouter.rootContext,
                    builder: (context) {
                      return CustomerSettlementDialog(
                        customerId: data.customer!.customerId!,
                        invoice: data,
                      );
                    },
                  ).then((value) {
                    ref
                        .read(
                          partyDetailsNotifierProvider(TransactionParty.customer, data.customer!.customerId!).notifier,
                        )
                        .getSales(pageNumber: 1);
                  });
                },
              );
            },
          );
        } else if (data is PurchaseView && data.transaction.dueAmount > 0) {
          return Consumer(
            builder: (context, ref, child) {
              return AppButton(
                padding: const EdgeInsets.all(2),
                label: Text(AppRouter.l10n.settle),
                width: 20,
                style: ButtonStyles.secondary,
                onPress: () {
                  showDialog<void>(
                    context: AppRouter.rootContext,
                    builder: (context) {
                      return SupplierSettlementDialog(
                        supplierId: data.supplier.supplierId!,
                        invoice: data,
                      );
                    },
                  ).then((value) {
                    ref
                        .read(
                          partyDetailsNotifierProvider(TransactionParty.supplier, data.supplier.supplierId!).notifier,
                        )
                        .getPurchases(pageNumber: 1);
                  });
                },
              );
            },
          );
        }
        return const SizedBox();
      },
    ),
  ];
}
