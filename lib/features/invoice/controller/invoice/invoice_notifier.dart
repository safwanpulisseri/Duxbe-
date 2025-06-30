import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/features/invoice/invoice.dart';
import 'package:duxbe/features/invoice/presentation/widgets/invoice_details_card.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'invoice_notifier.freezed.dart';
part 'invoice_notifier.g.dart';
part 'invoice_state.dart';

@Riverpod(keepAlive: false)
Future<Invoice?> invoiceData(
  // ignore: deprecated_member_use_from_same_package
  InvoiceDataRef ref,
  String? invoiceId,
) async =>
    invoiceId == null ? null : ref.watch(invoicesRepoProvider).getInvoiceWithId(invoiceId: invoiceId);

@Riverpod(keepAlive: false)
class InvoiceNotifier extends _$InvoiceNotifier {
  late IInvoicesRepository _invoicesRepository;
  @override
  InvoiceState build() {
    _invoicesRepository = ref.read(invoicesRepoProvider);
    ref.listen(businessNotifierProvider, (previous, next) {
      // Refresh the paging controller when business changes
      setFilter(pageNumber: 1);
    });
    state = InvoiceState.initial();
    return state.copyWith(
      pagingController: PagingController<int, Invoice>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener(
          (pageKey) async {
            final invoices = await getInvoices(
              pageNumber: pageKey,
            );
            final isLastPage = invoices.data.length < state.pageSize;
            if (isLastPage) {
              state.pagingController!.appendLastPage(invoices.data);
            } else {
              final nextPageKey = pageKey + 1;
              state.pagingController!.appendPage(invoices.data, nextPageKey);
            }
          },
        ),
      invoiceDetailsPagingController: PagingController<int, Invoice>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener(
          (pageKey) async {
            final invoices = await getInvoicesDetails(pageNumber: pageKey);
            final isLastPage = invoices.length < state.pageSize;
            if (isLastPage) {
              state.invoiceDetailsPagingController!.appendLastPage(invoices);
            } else {
              final nextPageKey = pageKey + 1;
              state.invoiceDetailsPagingController!.appendPage(invoices, nextPageKey);
            }
          },
        ),
    );
  }

  void setFilter({
    String? query,
    int? pageNumber,
    ItemType? type,
    List<ItemCategory>? categories,
    String? selectedInvoiceId,
  }) {
    state = state.copyWith(
      pageNumber: pageNumber ?? state.pageNumber,
      query: query ?? state.query,
      selectedItemType: type ?? state.selectedItemType,
      selectedCategories: categories ?? state.selectedCategories,
      selectedInvoiceId: selectedInvoiceId ?? state.selectedInvoiceId,
    );
    state.pagingController?.refresh();
    state.invoiceDetailsPagingController?.refresh();
    setTable();
  }

  void setStateManager({required PlutoGridStateManager stateManager}) {
    state = state.copyWith(stateManager: stateManager);
    setTable();
  }

  Future<PaginatedResponse<Invoice>> getInvoices({
    String? query,
    int? pageNumber,
    int? pageSize,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final invoices = await _invoicesRepository.getInvoices(
        query: query ?? state.query ?? '',
        pageNumber: pageNumber ?? state.pageNumber,
        pageSize: pageSize ?? state.pageSize,
        fromDate: fromDate ?? state.startDate,
        toDate: toDate ?? state.endDate,
      );
      return invoices;
    } catch (e) {
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<List<Invoice>> getInvoicesDetails({
    String? query,
    int? pageNumber,
    int? pageSize,
  }) async {
    try {
      final invoices = await _invoicesRepository.getInvoicesDetails(
        query: query ?? state.query ?? '',
        pageNumber: pageNumber ?? state.pageNumber,
        pageSize: pageSize ?? state.pageSize,
      );
      return invoices.data;
    } catch (e) {
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  ///MARK:- Delete Invoice
  Future<void> deleteInvoice({required String invoiceId}) async {
    try {
      state = state.copyWith(status: InvoiceStatus.loading);
      await ref.read(invoicesRepoProvider).deleteInvoice(invoiceId: invoiceId);
      state = state.copyWith(status: InvoiceStatus.success);
      setFilter();
      AppRouter.pop();
      Alert.showSnackBar(
        AppRouter.l10n.updatedSuccessfully,
        type: SnackBarType.success,
      );
    } catch (e) {
      state = state.copyWith(status: InvoiceStatus.error);
      print(e);
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
    }
  }

  Future<void> updateInvoiceStatus({required String invoiceId, required String status}) async {
    try {
      state = state.copyWith(status: InvoiceStatus.loading);
      await ref.read(invoicesRepoProvider).updateInvoiceStatus(invoiceId: invoiceId, status: status);
      state = state.copyWith(status: InvoiceStatus.success);
      setFilter(selectedInvoiceId: invoiceId);
      Alert.showSnackBar(
        AppRouter.l10n.updatedSuccessfully,
        type: SnackBarType.success,
      );
    } catch (e) {
      state = state.copyWith(status: InvoiceStatus.error);
      print(e);
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
    }
  }

  Future<void> setTable() async {
    if (state.stateManager == null) return;
    state.stateManager?.setShowLoading(true);
    state = state.copyWith(status: InvoiceStatus.loading);
    final invoices = await getInvoices();
    state = state.copyWith(
      status: InvoiceStatus.success,
      invoices: invoices.data,
      count: invoices.count,
    );
    final baseIndex = (state.pageNumber - 1) * state.pageSize + 1;
    final rows = await PlutoGridStateManager.initializeRowsAsync(invoiceColumns, [
      for (int i = 0; i < state.invoices.length; i++)
        PlutoRow(
          cells: {
            'sl_no': PlutoCell(value: baseIndex + i),
            'date': PlutoCell(
              value: state.invoices[i].invoiceDate?.toLocal().toFullFormat ?? '',
            ),
            'invoice_no': PlutoCell(value: state.invoices[i].invoiceCode ?? ''),
            'customer_name': PlutoCell(
              value: state.invoices[i].customerName ?? AppRouter.l10n.walkInCustomer,
            ),
            'due_date': PlutoCell(
              value: state.invoices[i].dueDate?.toLocal().toFullFormat ?? '',
            ),
            'status': PlutoCell(
              value: state.invoices[i].status?.toString().split('.').last ?? '',
            ),
            'amount': PlutoCell(value: state.invoices[i].amount.toString()),
            'actions': PlutoCell(value: state.invoices[i]),
          },
        ),
    ]);

    state.stateManager?.refRows.clear();
    state.stateManager?.refRows.addAll(rows);
    state.stateManager?.setShowLoading(false);
  }

  List<PlutoColumn> get invoiceColumns => <PlutoColumn>[
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
          title: AppRouter.l10n.invoiceNo,
          field: 'invoice_no',
          titleSpan: TextSpan(
            text: AppRouter.l10n.invoiceNo,
            style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
          ),
          type: PlutoColumnType.text(),
          backgroundColor: AppColors.tableHeaderColor,
        ),
        PlutoColumn(
          title: AppRouter.l10n.customerName,
          field: 'customer_name',
          titleSpan: TextSpan(
            text: AppRouter.l10n.customerName,
            style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
          ),
          type: PlutoColumnType.text(),
          backgroundColor: AppColors.tableHeaderColor,
        ),
        PlutoColumn(
          title: AppRouter.l10n.dueDate,
          field: 'due_date',
          titleSpan: TextSpan(
            text: AppRouter.l10n.dueDate,
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
          renderer: _buildActionRenderer,
          type: PlutoColumnType.text(),
          backgroundColor: AppColors.tableHeaderColor,
        ),
      ];

  Widget _buildActionRenderer(PlutoColumnRendererContext context) {
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
            setFilter(
              selectedInvoiceId: state.invoices[context.rowIdx].invoiceId,
            );
            AppRouter.goNamed(
              AppRouter.invoiceDetails,
            );
          },
          child: Text(AppRouter.l10n.view),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.print, color: AppColors.primaryColor),
          onPressed: () async {
            final invoice = await ref.read(invoicesRepoProvider).getInvoiceWithId(
                  invoiceId: state.invoices[context.rowIdx].invoiceId!,
                );

            if (invoice != null) {
              await PdfService.printInvoicePdf(
                balanceDue: invoice.balanceDue ?? 0,
                dueDate: DateFormat('dd MMM yyyy').format(invoice.dueDate?.toLocal() ?? DateTime.now()),
                invoiceDate: DateFormat('dd MMM yyyy').format(invoice.invoiceDate?.toLocal() ?? DateTime.now()),
                status: invoice.status ?? InvoiceFormStatus.draft,
                invoiceNumber: invoice.invoiceCode ?? '',
                customerName: invoice.customer?.name ?? '',
                customerAddress:
                    '${invoice.billingAddress?.address ?? ''}, \n${invoice.billingAddress?.city ?? ''}, ${invoice.billingAddress?.state ?? ''} \n${invoice.billingAddress?.zipcode ?? ''}, ${invoice.billingAddress?.country ?? ''}',
                items: invoice.invoiceItems
                    .map(
                      (e) => InvoiceItem(
                        description: e.item?.name ?? '',
                        subDescription: e.item?.itemCategory?.name ?? '',
                        quantity: e.quantity?.toDouble() ?? 0,
                        rate: e.unitPrice ?? 0,
                        tax: 0,
                        amount: e.totalPrice ?? 0,
                      ),
                    )
                    .toList(),
                subtotal: invoice.subTotal ?? 0,
                cgst: invoice.taxTotal ?? 0,
                sgst: invoice.taxTotal ?? 0,
                total: invoice.amount ?? 0,
                totalInWords: AmountToWordsConverter.convertToWordsOnly(
                  invoice.amount ?? 0,
                ),
                note: invoice.notes ?? '',
                termsAndConditions: invoice.termsAndConditions ?? '',
              );
            }
          },
          style: MenuItemButton.styleFrom(
            foregroundColor: AppColors.primaryColor,
          ),
          child: Text(AppRouter.l10n.print),
        ),
        MenuItemButton(
          leadingIcon: const Icon(
            Icons.delete,
            color: AppColors.red,
          ),
          style: MenuItemButton.styleFrom(
            foregroundColor: AppColors.red,
          ),
          onPressed: () {
            deleteInvoice(
              invoiceId: state.invoices[context.rowIdx].invoiceId!,
            );
          },
          child: Text(AppRouter.l10n.delete),
        ),
      ],
    );
  }
}
