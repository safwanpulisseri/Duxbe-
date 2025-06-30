import 'package:duxbe/features/auth/auth.dart';
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

part 'credit_note_notifier.freezed.dart';
part 'credit_note_notifier.g.dart';
part 'credit_note_state.dart';

@Riverpod(keepAlive: false)
Future<CreditNote?> creditNoteData(
  // ignore: deprecated_member_use_from_same_package
  CreditNoteDataRef ref,
  String? creditId,
) async =>
    creditId == null ? null : ref.watch(creditNoteRepoProvider).getCreditWithId(creditId: creditId);

@Riverpod(keepAlive: false)
class CreditNoteNotifier extends _$CreditNoteNotifier {
  late ICreditNoteRepository _repository;
  @override
  CreditNoteState build() {
    _repository = ref.watch(creditNoteRepoProvider);
    ref.listen(businessNotifierProvider, (previous, next) {
      // Refresh the paging controller when business changes
      setFilter(pageNumber: 1);
    });
    state = CreditNoteState.initial();
    return state.copyWith(
      pagingController: PagingController<int, CreditNote>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener(
          (pageKey) async {
            final creditNotes = await getCreditNotesLists(pageNumber: pageKey);
            final isLastPage = creditNotes.data.length < state.pageSize;
            if (isLastPage) {
              state.pagingController!.appendLastPage(creditNotes.data);
            } else {
              final nextPageKey = pageKey + 1;
              state.pagingController!.appendPage(creditNotes.data, nextPageKey);
            }
          },
        ),
      creditDetailsPagingController: PagingController<int, CreditNote>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener(
          (pageKey) async {
            final creditNotes = await getCreditDetails(pageNumber: pageKey);
            final isLastPage = creditNotes.length < state.pageSize;
            if (isLastPage) {
              state.creditDetailsPagingController?.appendLastPage(creditNotes);
            } else {
              state.creditDetailsPagingController?.appendPage(creditNotes, pageKey + 1);
            }
          },
        ),
    );
  }

  void setFilter({
    String? query,
    int? pageNumber,
    String? selectedQuoteId,
  }) {
    state = state.copyWith(
      pageNumber: pageNumber ?? state.pageNumber,
      query: query ?? state.query,
      selectedCreditId: selectedQuoteId ?? state.selectedCreditId,
    );
    state.pagingController?.refresh();
    state.creditDetailsPagingController?.refresh();
    setTable();
  }

  void setStateManager({required PlutoGridStateManager stateManager}) {
    state = state.copyWith(stateManager: stateManager);
    setTable();
  }

  Future<void> deleteCredit(String credit) async {
    try {
      state = state.copyWith(status: CreditNoteStatus.loading);
      await ref.read(creditNoteRepoProvider).deleteCredit(credit);
      state = state.copyWith(status: CreditNoteStatus.success);
      ref.read(creditNoteNotifierProvider.notifier).setFilter();
      AppRouter.pop();
      Alert.showSnackBar(
        '${AppRouter.l10n.creditNote} ${AppRouter.l10n.delete} ${AppRouter.l10n.successfully}',
        type: SnackBarType.success,
      );
    } catch (e) {
      state = state.copyWith(status: CreditNoteStatus.error);
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<PaginatedResponse<CreditNote>> getCreditNotesLists({
    String? query,
    int? pageNumber,
    int? pageSize,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final quotes = await _repository.getcreditNotesLists(
        query: query ?? state.query ?? '',
        pageNumber: pageNumber ?? state.pageNumber,
        pageSize: pageSize ?? state.pageSize,
        fromDate: fromDate ?? state.startDate,
        toDate: toDate ?? state.endDate,
      );
      return quotes;
    } catch (e) {
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<List<CreditNote>> getCreditDetails({
    String? query,
    int? pageNumber,
    int? pageSize,
  }) async {
    try {
      final quotes = await _repository.getCreditDetails(
        query: query ?? state.query ?? '',
        pageNumber: pageNumber ?? state.pageNumber,
        pageSize: pageSize ?? state.pageSize,
      );
      return quotes.data;
    } catch (e) {
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<void> deleteRefund(String refund) async {
    try {
      state = state.copyWith(status: CreditNoteStatus.loading);
      await ref.read(creditNoteRepoProvider).deleteRefund(refund);
      state = state.copyWith(status: CreditNoteStatus.success, selectedCreditId: null);
      state.creditDetailsPagingController?.refresh();
      state.pagingController?.refresh();

      AppRouter.pop();
      Alert.showSnackBar(
        '${AppRouter.l10n.refund} ${AppRouter.l10n.delete} ${AppRouter.l10n.successfully}',
        type: SnackBarType.success,
      );
    } on AppException catch (e) {
      state = state.copyWith(status: CreditNoteStatus.error);
      Alert.showSnackBar(e.message, type: SnackBarType.error);
    }
  }

  Future<void> setTable() async {
    if (state.stateManager == null) return;
    state.stateManager?.setShowLoading(true);
    state = state.copyWith(status: CreditNoteStatus.loading);
    final credit = await getCreditNotesLists();
    state = state.copyWith(
      status: CreditNoteStatus.success,
      credit: credit.data,
      count: credit.count,
    );
    final baseIndex = (state.pageNumber - 1) * state.pageSize + 1;
    final rows = await PlutoGridStateManager.initializeRowsAsync(creditNoteColumns, [
      for (int i = 0; i < state.credit.length; i++)
        PlutoRow(
          cells: {
            'sl_no': PlutoCell(value: baseIndex + i),
            'date': PlutoCell(
              value: state.credit[i].creditNoteDate?.toLocal().toFullFormat ?? '',
            ),
            'credit_note': PlutoCell(value: state.credit[i].creditNoteCode ?? ''),
            'customer_name': PlutoCell(
              value: state.credit[i].customerName ?? AppRouter.l10n.walkInCustomer,
            ),
            'invoice_no': PlutoCell(
              value: state.credit[i].linkedInvoiceCode?.toString().split('.').last ?? '',
            ),
            'status': PlutoCell(
              value: state.credit[i].status?.toString().split('.').last ?? '',
            ),
            'amount': PlutoCell(value: state.credit[i].amount?.toString() ?? '0'),
            'actions': PlutoCell(value: state.credit[i]),
          },
        ),
    ]);

    state.stateManager?.refRows.clear();
    state.stateManager?.refRows.addAll(rows);
    state.stateManager?.setShowLoading(false);
  }

  List<PlutoColumn> get creditNoteColumns => <PlutoColumn>[
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
          title: AppRouter.l10n.creditNote,
          field: 'credit_note',
          titleSpan: TextSpan(
            text: AppRouter.l10n.creditNote,
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
              selectedQuoteId: state.credit[context.rowIdx].creditNoteId,
            );
            AppRouter.goNamed(
              AppRouter.creditNoteDetails,
            );
          },
          child: Text(AppRouter.l10n.view),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.print, color: AppColors.primaryColor),
          onPressed: () async {
            final credit = await ref.read(creditNoteRepoProvider).getCreditWithId(
                  creditId: state.credit[context.rowIdx].creditNoteId ?? '',
                );

            if (credit != null) {
              await PdfService.printCreditNotePdf(
                creditRemaining: credit.creditRemaining ?? 0,
                creditNoteDate: DateFormat('dd MMM yyyy').format(credit.creditNoteDate?.toLocal() ?? DateTime.now()),
                creditNoteNumber: credit.creditNoteCode ?? '',
                referenceInvoiceNumber: credit.linkedInvoiceCode ?? '',
                customerName: credit.customerName ?? '',
                customerAddress:
                    '${credit.invoiceDetails?.billingAddress?.address ?? ''}, \n${credit.invoiceDetails?.billingAddress?.city ?? ''}, ${credit.invoiceDetails?.billingAddress?.state ?? ''} \n${credit.invoiceDetails?.billingAddress?.zipcode ?? ''}, ${credit.invoiceDetails?.billingAddress?.country ?? ''}',
                items: credit.invoiceDetails!.invoiceItems
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
                subtotal: credit.subTotal ?? 0,
                cgst: credit.taxTotal ?? 0,
                sgst: credit.taxTotal ?? 0,
                total: credit.grandTotal ?? 0,
                totalInWords: AmountToWordsConverter.convertToWordsOnly(
                  credit.grandTotal ?? 0,
                ),
                note: credit.notes ?? '',
                termsAndConditions: credit.termsAndConditions ?? '',
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
            // changeQuoteStatus(
            //   state.quotes[context.rowIdx].quoteId!,
            //   QuoteFormStatus.deleted,
            // );
          },
          child: Text(AppRouter.l10n.delete),
        ),
      ],
    );
  }
}
