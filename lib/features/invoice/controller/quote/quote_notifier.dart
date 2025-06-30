import 'package:duxbe/features/auth/controller/business/business_notifier.dart';
import 'package:duxbe/features/inventory/item/domain/models/item/item_model.dart';
import 'package:duxbe/features/inventory/item/domain/repositories/implementations/item/item_repository.dart';
import 'package:duxbe/features/inventory/item_category/domain/models/item_category/item_category_model.dart';
import 'package:duxbe/features/invoice/domain/models/quote/quote_model.dart';
import 'package:duxbe/features/invoice/domain/repositories/invoice_repositories.dart';
import 'package:duxbe/features/invoice/presentation/widgets/invoice_details_card.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'quote_notifier.freezed.dart';
part 'quote_notifier.g.dart';
part 'quote_state.dart';

@Riverpod(keepAlive: false)
Future<Quote?> quote(
  // ignore: deprecated_member_use_from_same_package
  QuoteRef ref,
  String? quoteId,
) async =>
    quoteId == null ? null : ref.watch(quoteRepoProvider).getQuoteWithId(quoteId: quoteId);

@Riverpod(keepAlive: false)
class QuoteNotifier extends _$QuoteNotifier {
  late IQuoteRepository _quoteRepository;
  @override
  QuoteState build() {
    _quoteRepository = ref.watch(quoteRepoProvider);
    ref.listen(businessNotifierProvider, (previous, next) {
      // Refresh the paging controller when business changes
      setFilter(pageNumber: 1);
    });

    state = QuoteState.initial();
    return state.copyWith(
      pagingController: PagingController<int, Quote>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener(
          (pageKey) async {
            final quotes = await getQuotes(pageNumber: pageKey);
            final isLastPage = quotes.data.length < state.pageSize;
            if (isLastPage) {
              state.pagingController!.appendLastPage(quotes.data);
            } else {
              final nextPageKey = pageKey + 1;
              state.pagingController!.appendPage(quotes.data, nextPageKey);
            }
          },
        ),
      quoteDetailsPagingController: PagingController<int, Quote>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener(
          (pageKey) async {
            final quotes = await getQuotesDetails(pageNumber: pageKey);
            final isLastPage = quotes.length < state.pageSize;
            if (isLastPage) {
              state.quoteDetailsPagingController!.appendLastPage(quotes);
            } else {
              final nextPageKey = pageKey + 1;
              state.quoteDetailsPagingController!.appendPage(quotes, nextPageKey);
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
    String? selectedQuoteId,
  }) {
    state = state.copyWith(
      pageNumber: pageNumber ?? state.pageNumber,
      query: query ?? state.query,
      selectedItemType: type ?? state.selectedItemType,
      selectedCategories: categories ?? state.selectedCategories,
      selectedQuoteId: selectedQuoteId ?? state.selectedQuoteId,
    );
    state.pagingController?.refresh();
    state.quoteDetailsPagingController?.refresh();
    setTable();
  }

  Future<Quote?> getQuoteWithId(String quoteId) async {
    try {
      final quote = await _quoteRepository.getQuoteWithId(quoteId: quoteId);
      return quote;
    } catch (e) {
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  void setStateManager({required PlutoGridStateManager stateManager}) {
    state = state.copyWith(stateManager: stateManager);
    setTable();
  }

  Future<List<Item>> getItems({
    required int pageNumber,
    String? query,
    int? pageSize,
    ItemType? type,
    List<ItemCategory>? selectedCategories,
  }) async {
    try {
      final items = await ref.read(itemRepoProvider).getItems(
            query: query ?? state.query ?? '',
            pageSize: pageSize ?? state.pageSize,
            pageNumber: pageNumber,
            salesEnabled: true,
            itemType: type?.name ?? state.selectedItemType?.name ?? '',
            categories: selectedCategories ?? state.selectedCategories,
          );
      return items.data;
    } catch (e) {
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<PaginatedResponse<Quote>> getQuotes({
    String? query,
    int? pageNumber,
    int? pageSize,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final quotes = await _quoteRepository.getQuotes(
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

  Future<List<Quote>> getQuotesDetails({
    String? query,
    int? pageNumber,
    int? pageSize,
  }) async {
    try {
      final quotes = await _quoteRepository.getQuotesDetails(
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

  ///MARK:- Delete Quote
  Future<void> changeQuoteStatus(String quoteId, QuoteFormStatus status) async {
    try {
      await _quoteRepository.deleteQuote(
        quoteId: quoteId,
        status: status.name,
      );
      state = state.copyWith(status: QuoteStatus.success);
      Alert.showSnackBar(
        'Quote Updated Successfully',
        type: SnackBarType.success,
      );
      state.pagingController?.refresh();
      state.quoteDetailsPagingController?.refresh();
    } catch (e) {
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  ///MARK:- Set Table
  Future<void> setTable() async {
    if (state.stateManager == null) return;
    state.stateManager?.setShowLoading(true);
    state = state.copyWith(status: QuoteStatus.loading);
    final quotes = await getQuotes();
    state = state.copyWith(
      status: QuoteStatus.success,
      quotes: quotes.data,
      count: quotes.count,
    );
    final baseIndex = (state.pageNumber - 1) * state.pageSize + 1;
    final rows = await PlutoGridStateManager.initializeRowsAsync(quoteColumns, [
      for (int i = 0; i < state.quotes.length; i++)
        PlutoRow(
          cells: {
            'sl_no': PlutoCell(value: baseIndex + i),
            'date': PlutoCell(
              value: state.quotes[i].quoteDate?.toLocal().toFullFormat ?? '',
            ),
            'quote_no': PlutoCell(value: state.quotes[i].quoteCode ?? ''),
            'customer_name': PlutoCell(
              value: state.quotes[i].customerName ?? AppRouter.l10n.walkInCustomer,
            ),
            'status': PlutoCell(
              value: state.quotes[i].quoteStatus?.toString().split('.').last ?? '',
            ),
            'amount': PlutoCell(value: state.quotes[i].amount?.toString() ?? '0'),
            'actions': PlutoCell(value: state.quotes[i]),
          },
        ),
    ]);

    state.stateManager?.refRows.clear();
    state.stateManager?.refRows.addAll(rows);
    state.stateManager?.setShowLoading(false);
  }

  Future<void> recordPayment(Map<String, dynamic> invoice) async {
    try {
      await ref.read(invoicesRepoProvider).createInvoice(invoice);
      Alert.showSnackBar(AppRouter.l10n.updatedSuccessfully, type: SnackBarType.success);
    } catch (e) {
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  List<PlutoColumn> get quoteColumns => <PlutoColumn>[
        PlutoColumn(
          title: 'SL.No',
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
          title: 'Date',
          field: 'date',
          titleSpan: TextSpan(
            text: AppRouter.l10n.date,
            style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
          ),
          type: PlutoColumnType.text(),
          backgroundColor: AppColors.tableHeaderColor,
        ),
        PlutoColumn(
          title: 'Quote No',
          field: 'quote_no',
          titleSpan: TextSpan(
            text: AppRouter.l10n.quoteNo,
            style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
          ),
          type: PlutoColumnType.text(),
          backgroundColor: AppColors.tableHeaderColor,
        ),
        PlutoColumn(
          title: 'Customer Name',
          field: 'customer_name',
          titleSpan: TextSpan(
            text: AppRouter.l10n.customerName,
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
            setFilter(selectedQuoteId: state.quotes[context.rowIdx].quoteId);
            AppRouter.goNamed(
              AppRouter.quoteDetails,
            );
          },
          child: Text(AppRouter.l10n.view),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.print, color: AppColors.primaryColor),
          onPressed: () async {
            final quote = await ref.read(quoteRepoProvider).getQuoteWithId(
                  quoteId: state.quotes[context.rowIdx].quoteId!,
                );

            if (quote != null) {
              await PdfService.printQuotePdf(
                quoteNumber: quote.quoteCode ?? '',
                quoteDate: DateFormat('dd MMM yyyy').format(quote.createdAt?.toLocal() ?? DateTime.now()),
                expiryDate: DateFormat('dd MMM yyyy').format(quote.validUntilDate?.toLocal() ?? DateTime.now()),
                customerName: quote.customerName ?? '',
                customerAddress:
                    '${quote.billingAddressDetails?.address ?? ''}, \n${quote.billingAddressDetails?.city ?? ''}, ${quote.billingAddressDetails?.state ?? ''} \n${quote.billingAddressDetails?.zipcode ?? ''}, ${quote.billingAddressDetails?.country ?? ''}',
                items: quote.quoteItems
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
                subtotal: quote.subTotal ?? 0,
                cgst: quote.taxTotal ?? 0,
                sgst: quote.taxTotal ?? 0,
                total: quote.grandTotal ?? 0,
                totalInWords: AmountToWordsConverter.convertToWordsOnly(
                  quote.grandTotal ?? 0,
                ),
                note: quote.quoteNotes ?? '',
                termsAndConditions: quote.quoteTermsAndConditions ?? '',
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
            changeQuoteStatus(
              state.quotes[context.rowIdx].quoteId!,
              QuoteFormStatus.deleted,
            );
          },
          child: Text(AppRouter.l10n.delete),
        ),
      ],
    );
  }
}
