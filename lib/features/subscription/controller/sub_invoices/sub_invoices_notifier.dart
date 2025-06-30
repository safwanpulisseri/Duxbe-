import 'dart:async';

import 'package:duxbe/features/organization/organization.dart';
// Assuming SubscriptionInvoice is exported from subscription.dart or available globally
// If not, ensure correct import for SubscriptionInvoice, e.g.:
// import 'package:duxbe/features/subscription/domain/models/subscription_invoice.dart'; // Example path
import 'package:duxbe/features/subscription/subscription.dart'; // For SubscriptionInvoice, repo provider
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hancod_theme/hancod_theme.dart'; // For ConfirmationDialog
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

part 'sub_invoices_notifier.freezed.dart';
part 'sub_invoices_notifier.g.dart';
part 'sub_invoices_state.dart';

@Riverpod(keepAlive: false)
class SubInvoicesNotifier extends _$SubInvoicesNotifier {
  late ISubscriptionRepository _subscriptionRepository;
  // _rawInvoicesData and _fetchAllInvoicesFromRepo removed

  @override
  SubInvoicesState build() {
    _subscriptionRepository = ref.watch(subscriptionRepoProvider);
    ref.listen(organizationNotifierProvider, (previous, next) {
      state.pagingController?.refresh(); // Refresh PagingController
      if (state.stateManager != null) {
        // If PlutoGrid is initialized
        setTable(pageNumber: 1); // Refresh PlutoGrid data
      }
    });

    state = SubInvoicesState.initial();

    return state.copyWith(
      pagingController: PagingController<int, SubscriptionInvoice>(
        // Changed to SubscriptionInvoice
        firstPageKey: 1,
      )..addPageRequestListener(
          (pageKey) async {
            try {
              final response = await getInvoices(
                pageNumberOverride: pageKey,
                pageSizeOverride: state.pageSize, // Use current page size from state
              );
              if (state.status == SubInvoicesStatus.error) {
                state.pagingController!.error = state.error;
                return;
              }
              final isLastPage = response.data.length < state.pageSize;
              if (isLastPage) {
                state.pagingController!.appendLastPage(response.data);
              } else {
                final nextPageKey = pageKey + 1;
                state.pagingController!.appendPage(response.data, nextPageKey);
              }
            } catch (e) {
              // This catch is primarily if getInvoices rethrows an exception
              // not already handled by setting state.status = error inside getInvoices
              state.pagingController!.error = e.toString();
              // Alert.showSnackBar(e.toString(), type: SnackBarType.error); // Already shown in getInvoices
            }
          },
        ),
    );
  }

  // _fetchAllInvoicesFromRepo removed

  Future<PaginatedResponse<SubscriptionInvoice>> getInvoices({
    // Changed to SubscriptionInvoice
    String? queryOverride,
    int? pageSizeOverride,
    int? pageNumberOverride,
  }) async {
    state = state.copyWith(status: SubInvoicesStatus.loading);

    final currentQuery = queryOverride ?? state.query;
    final currentPageSize = pageSizeOverride ?? state.pageSize;
    final currentPageNumber = pageNumberOverride ?? state.pageNumber;

    try {
      final response = await _subscriptionRepository.getSubscriptionInvoices(
        query: currentQuery,
        pageSize: currentPageSize,
        pageNumber: currentPageNumber,
      );
      state = state.copyWith(
        status: SubInvoicesStatus.success,
        invoices: response.data, // Update state for PlutoGrid
        count: response.count, // Update state for PlutoGrid
        pageNumber: currentPageNumber,
        pageSize: currentPageSize,
        query: currentQuery,
        error: '',
      );
      return response;
    } catch (e) {
      state = state.copyWith(
        status: SubInvoicesStatus.error,
        error: e.toString(),
        invoices: [], // Clear invoices on error
        count: 0,
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      return const PaginatedResponse<SubscriptionInvoice>(data: [], count: 0); // Return empty on error
    }
  }

  void setStateManager({required PlutoGridStateManager stateManager}) {
    state = state.copyWith(stateManager: stateManager);
    setTable(); // Load initial data for the table
  }

  void setFilter({String? query}) {
    state = state.copyWith(query: query ?? state.query, pageNumber: 1); // Reset to page 1
    state.pagingController?.refresh();
    setTable(); // Refresh table with new filter
  }

  void refreshData() {
    // _rawInvoicesData = null; // Removed
    state = state.copyWith(pageNumber: 1); // Reset to page 1
    state.pagingController?.refresh();
    setTable();
  }

  Future<void> setTable({
    String? query,
    int? pageSize,
    int? pageNumber,
  }) async {
    state.stateManager?.setShowLoading(true);
    // status is set by getInvoices
    // state = state.copyWith(status: SubInvoicesStatus.loading);

    // getInvoices will update state.invoices, state.count, state.pageNumber etc.
    await getInvoices(
      queryOverride: query,
      pageSizeOverride: pageSize,
      pageNumberOverride: pageNumber,
    );

    if (state.status == SubInvoicesStatus.error) {
      state.stateManager?.setShowLoading(false);
      state.stateManager?.removeAllRows(); // Clear rows on error
      return;
    }

    // State (invoices, count, pageNumber, pageSize, query) already updated by getInvoices call above
    // state = state.copyWith(
    //   status: SubInvoicesStatus.success, // This is set by getInvoices
    //   invoices: response.data, // This is now state.invoices
    //   count: response.count, // This is now state.count
    //   pageNumber: pageNumber ?? state.pageNumber,
    //   pageSize: pageSize ?? state.pageSize,
    //   query: query ?? state.query,
    // );

    final baseIndex = (state.pageNumber - 1) * state.pageSize + 1;
    final rows = await PlutoGridStateManager.initializeRowsAsync(
      invoiceColumns, // Ensure these columns are compatible with SubscriptionInvoice fields
      [
        for (int i = 0; i < state.invoices.length; i++) // state.invoices is List<SubscriptionInvoice>
          PlutoRow(
            cells: {
              'sl_no': PlutoCell(value: baseIndex + i),
              'date': PlutoCell(value: state.invoices[i].createdAt.toFullFormat), // Assumes SubscriptionInvoice.id
              'amount': PlutoCell(
                value: '${state.invoices[i].currency} ${state.invoices[i].amount.toStringAsFixed(2)}',
              ), // Assumes .amount
              'status': PlutoCell(value: state.invoices[i].status), // Assumes .status
              'invoice_id': PlutoCell(value: state.invoices[i].paymentProviderInvoiceId), // Assumes .subscriptionId
              'actions': PlutoCell(value: state.invoices[i]), // Pass SubscriptionInvoice object
            },
          ),
      ],
    );
    state.stateManager?.refRows.clear();
    state.stateManager?.refRows.addAll(rows);
    state.stateManager?.setShowLoading(false);
  }

  final List<PlutoColumn> invoiceColumns = <PlutoColumn>[
    PlutoColumn(
      title: AppRouter.l10n.slNo,
      field: 'sl_no',
      width: 70,
      titleSpan: TextSpan(
        text: AppRouter.l10n.slNo,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.number(),
      backgroundColor: AppColors.tableHeaderColor,
      textAlign: PlutoColumnTextAlign.center,
      titleTextAlign: PlutoColumnTextAlign.center,
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
      title: AppRouter.l10n.invoiceId,
      field: 'invoice_id',
      titleSpan: TextSpan(
        text: AppRouter.l10n.invoiceId,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      titleTextAlign: PlutoColumnTextAlign.center,
      title: AppRouter.l10n.actions,
      field: 'actions',
      width: 80,
      titleSpan: TextSpan(
        text: AppRouter.l10n.actions,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      renderer: (rendererContext) {
        final invoice = rendererContext.cell.value as SubscriptionInvoice; // Changed to SubscriptionInvoice
        return IconButton(
          icon: const Icon(Icons.download_for_offline, color: AppColors.primaryColor),
          tooltip: AppRouter.l10n.downloadInvoice,
          // Assumes SubscriptionInvoice has .shortUrl, and it's nullable
          onPressed: invoice.pdfUrl != null && invoice.pdfUrl!.isNotEmpty
              ? () async {
                  final uri = Uri.tryParse(invoice.pdfUrl!);
                  if (uri != null && await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    Alert.showSnackBar(AppRouter.l10n.couldNotOpenInvoiceLink, type: SnackBarType.error);
                  }
                }
              : null,
        );
      },
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
      textAlign: PlutoColumnTextAlign.center,
    ),
  ];
}
