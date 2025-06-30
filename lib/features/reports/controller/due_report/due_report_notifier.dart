import 'dart:async';

import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/reports/reports.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'due_report_notifier.freezed.dart';
part 'due_report_notifier.g.dart';
part 'due_report_state.dart';

@Riverpod(keepAlive: true)
Future<TotalDuesSummary> totalDuesSummary(
  TotalDuesSummaryRef ref,
  DateTime? startDate,
  DateTime? endDate,
) async =>
    ref.watch(reportRepoProvider).getTotalDuesSummary(startDate: startDate, endDate: endDate);

@Riverpod(keepAlive: false)
class DueReportNotifier extends _$DueReportNotifier {
  late IReportRepository _reportRepository;
  @override
  DueReportState build() {
    _reportRepository = ref.watch(reportRepoProvider);
    ref.listen(businessNotifierProvider, (previous, next) {
      setFilter(pageNumber: 1);
      ref.invalidate(totalDuesSummaryProvider);
    });

    state = DueReportState.initial();

    return state.copyWith(
      pagingController: PagingController<int, Due>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener(
          (pageKey) async {
            final due = await getDueReport(pageNumber: pageKey);
            final isLastPage = due.data.length < state.pageSize;
            if (isLastPage) {
              state.pagingController!.appendLastPage(due.data);
            } else {
              final nextPageKey = pageKey + 1;
              state.pagingController!.appendPage(due.data, nextPageKey);
            }
          },
        ),
      salesDuePagingController: PagingController<int, Due>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener(
          (pageKey) async {
            final due = await getDueReport(pageNumber: pageKey, salesOrPurchase: true);
            final isLastPage = due.data.length < state.pageSize;
            if (isLastPage) {
              state.salesDuePagingController!.appendLastPage(due.data);
            } else {
              final nextPageKey = pageKey + 1;
              state.salesDuePagingController!.appendPage(due.data, nextPageKey);
            }
          },
        ),
      purchaseDuePagingController: PagingController<int, Due>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener(
          (pageKey) async {
            final due = await getDueReport(pageNumber: pageKey, salesOrPurchase: false);
            final isLastPage = due.data.length < state.pageSize;
            if (isLastPage) {
              state.purchaseDuePagingController!.appendLastPage(due.data);
            } else {
              final nextPageKey = pageKey + 1;
              state.purchaseDuePagingController!.appendPage(due.data, nextPageKey);
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
    bool? salesOrPurchase,
    Object? fromDate = freezed,
    Object? toDate = freezed,
  }) {
    state = state.copyWith(
      query: query ?? state.query,
      pageSize: pageSize ?? state.pageSize,
      pageNumber: pageNumber ?? state.pageNumber,
      salesOrPurchase: salesOrPurchase ?? state.salesOrPurchase,
      fromDate: fromDate == freezed ? state.fromDate : fromDate as DateTime?,
      toDate: toDate == freezed ? state.toDate : toDate as DateTime?,
    );
    state.pagingController?.refresh();
    state.salesDuePagingController?.refresh();
    state.purchaseDuePagingController?.refresh();
    setTable();
  }

  Future<PaginatedResponse<Due>> getDueReport({
    String? query,
    int? pageSize,
    int? pageNumber,
    bool? salesOrPurchase,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final due = await _reportRepository.getDueReport(
        query: query ?? state.query,
        pageSize: pageSize ?? state.pageSize,
        pageNumber: pageNumber ?? state.pageNumber,
        salesOrPurchase: salesOrPurchase,
        fromDate: fromDate ?? state.fromDate,
        toDate: toDate ?? state.toDate,
      );
      return due;
    } catch (e) {
      state = state.copyWith(
        status: DueReportStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<void> setTable({
    String? query,
    int? pageSize,
    int? pageNumber,
    bool? salesOrPurchase,
    Object? fromDate = freezed,
    Object? toDate = freezed,
  }) async {
    state.stateManager?.setShowLoading(true);
    state = state.copyWith(status: DueReportStatus.loading);
    final due = await getDueReport();
    state = state.copyWith(
      status: DueReportStatus.success,
      due: due.data,
      count: due.count,
      pageNumber: pageNumber ?? state.pageNumber,
    );

    final baseIndex = (state.pageNumber - 1) * state.pageSize + 1;
    final rows = await PlutoGridStateManager.initializeRowsAsync(
      dueReportColumns,
      [
        for (int i = 0; i < state.due.length; i++)
          PlutoRow(
            cells: {
              'sl_no': PlutoCell(value: baseIndex + i),
              'date': PlutoCell(value: state.due[i].date.toFullFormat),
              'invoice_no': PlutoCell(value: state.due[i].invoiceNo),
              'party_name': PlutoCell(value: state.due[i].partyName ?? ''),
              'payment_type': PlutoCell(
                value: state.due[i].payments.map((e) => e.paymentMethod.name.displayCase).toSet().join(', '),
              ),
              'total_amount': PlutoCell(value: state.due[i].totalAmount),
              'sale_due': PlutoCell(value: state.due[i].transactionType == 'sale' ? state.due[i].dueAmount : ''),
              'purchase_due':
                  PlutoCell(value: state.due[i].transactionType == 'purchase' ? state.due[i].dueAmount : ''),
            },
          ),
      ],
    );
    state.stateManager?.refRows.clear();
    state.stateManager?.refRows.addAll(rows);
    state.stateManager?.setShowLoading(false);
  }

  Future<void> exportDueReport() async {
    try {
      state = state.copyWith(status: DueReportStatus.loading);
      final due = await _reportRepository.getDueReport(
        query: state.query,
        pageSize: state.pageSize,
        pageNumber: state.pageNumber,
        salesOrPurchase: state.salesOrPurchase,
      );
      state = state.copyWith(status: DueReportStatus.success);
      unawaited(
        exportToExcel(
          due.data
              .map(
                (e) => {
                  'Invoice No': e.invoiceNo,
                  'Date': e.date,
                  'Party Name': e.partyName,
                  'Payment Type': e.payments.map((e) => e.paymentMethod.name.displayCase).toSet().join(', '),
                  'Amount': e.totalAmount,
                  'Due Amount': e.dueAmount,
                  'Sale Due': e.transactionType == 'sale' ? e.dueAmount : '',
                  'Purchase Due': e.transactionType == 'purchase' ? e.dueAmount : '',
                },
              )
              .toList(),
          'Due Report${state.salesOrPurchase != null ? '-${state.salesOrPurchase! ? 'Sales' : 'Purchases'}' : ''}',
        ),
      );
    } catch (e) {
      state = state.copyWith(
        status: DueReportStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
    }
  }

  final List<PlutoColumn> dueReportColumns = <PlutoColumn>[
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
      title: AppRouter.l10n.partyName,
      field: 'party_name',
      titleSpan: TextSpan(
        text: AppRouter.l10n.partyName,
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
      title: AppRouter.l10n.totalAmount,
      field: 'total_amount',
      titleSpan: TextSpan(
        text: AppRouter.l10n.totalAmount,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.saleDue,
      field: 'sale_due',
      titleSpan: TextSpan(
        text: AppRouter.l10n.saleDue,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.purchaseDue,
      field: 'purchase_due',
      titleSpan: TextSpan(
        text: AppRouter.l10n.purchaseDue,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
  ];
}
