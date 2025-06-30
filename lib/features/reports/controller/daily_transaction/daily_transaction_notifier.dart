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

part 'daily_transaction_notifier.freezed.dart';
part 'daily_transaction_notifier.g.dart';
part 'daily_transaction_state.dart';

@Riverpod(keepAlive: true)
Future<DailyTransactionSummary> dailyTransactionSummary(
  DailyTransactionSummaryRef ref,
  DateTime? startDate,
  DateTime? endDate,
) async =>
    ref
        .watch(reportRepoProvider)
        .getDailyTransactionSummary(startDate: startDate, endDate: endDate);

@Riverpod(keepAlive: false)
class DailyTransactionNotifier extends _$DailyTransactionNotifier {
  late IReportRepository _reportRepository;
  @override
  DailyTransactionState build() {
    _reportRepository = ref.watch(reportRepoProvider);
    ref.listen(businessNotifierProvider, (previous, next) {
      setFilter(pageNumber: 1);
    });

    state = DailyTransactionState.initial();

    return state.copyWith(
      pagingController: PagingController<int, DailyTransaction>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener(
          (pageKey) async {
            final dailyTransactions =
                await getDailyTransactionReport(pageNumber: pageKey);
            final isLastPage = dailyTransactions.data.length < state.pageSize;
            if (isLastPage) {
              state.pagingController!.appendLastPage(dailyTransactions.data);
            } else {
              final nextPageKey = pageKey + 1;
              state.pagingController!
                  .appendPage(dailyTransactions.data, nextPageKey);
            }
          },
        ),
      payInPagingController: PagingController<int, DailyTransaction>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener(
          (pageKey) async {
            final dailyTransactions = await getDailyTransactionReport(
              pageNumber: pageKey,
              payIn: true,
            );
            final isLastPage = dailyTransactions.data.length < state.pageSize;
            if (isLastPage) {
              state.payInPagingController!
                  .appendLastPage(dailyTransactions.data);
            } else {
              final nextPageKey = pageKey + 1;
              state.payInPagingController!
                  .appendPage(dailyTransactions.data, nextPageKey);
            }
          },
        ),
      payOutPagingController: PagingController<int, DailyTransaction>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener(
          (pageKey) async {
            final dailyTransactions = await getDailyTransactionReport(
              pageNumber: pageKey,
              payIn: false,
            );
            final isLastPage = dailyTransactions.data.length < state.pageSize;
            if (isLastPage) {
              state.payOutPagingController!
                  .appendLastPage(dailyTransactions.data);
            } else {
              final nextPageKey = pageKey + 1;
              state.payOutPagingController!
                  .appendPage(dailyTransactions.data, nextPageKey);
            }
          },
        ),
    );
  }

  void setFilter({
    String? query,
    int? pageSize,
    int? pageNumber,
    Object? fromDate = freezed,
    Object? toDate = freezed,
  }) {
    state = state.copyWith(
      query: query ?? state.query,
      pageSize: pageSize ?? state.pageSize,
      pageNumber: pageNumber ?? state.pageNumber,
      fromDate: fromDate == freezed ? state.fromDate : fromDate as DateTime?,
      toDate: toDate == freezed ? state.toDate : toDate as DateTime?,
    );
    state.pagingController?.refresh();
    state.payInPagingController?.refresh();
    state.payOutPagingController?.refresh();
    setTable();
  }

  void setStateManager(PlutoGridStateManager stateManager) {
    state = state.copyWith(stateManager: stateManager);
    setTable();
  }

  Future<PaginatedResponse<DailyTransaction>> getDailyTransactionReport({
    String? query,
    int? pageSize,
    int? pageNumber,
    bool? payIn,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final dailyTransactions =
          await _reportRepository.getDailyTransactionReport(
        query: query ?? state.query,
        pageSize: pageSize ?? state.pageSize,
        pageNumber: pageNumber ?? state.pageNumber,
        payIn: payIn,
        fromDate: fromDate ?? state.fromDate,
        toDate: toDate ?? state.toDate,
      );
      return dailyTransactions;
    } catch (e) {
      state = state.copyWith(
        status: DailyTransactionStatus.error,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> exportDailyTransaction() async {
    try {
      state = state.copyWith(status: DailyTransactionStatus.loading);
      final sales = await _reportRepository.getDailyTransactionReport(
        query: state.query,
        pageSize: state.pageSize,
        pageNumber: state.pageNumber,
        fromDate: state.fromDate,
        toDate: state.toDate,
      );
      state = state.copyWith(status: DailyTransactionStatus.success);
      unawaited(
        exportToExcel(
          sales.data
              .map(
                (e) => {
                  'Date': e.date.toLocal().toFullFormat,
                  'Customer Name': e.name,
                  'Payment Type': e.type,
                  'Total': e.transactionTotal,
                  'Payment In': e.paymentIn,
                  'Payment Out': e.paymentOut,
                  'Balance': e.balance,
                },
              )
              .toList(),
          'Daily Transaction${state.fromDate != null ? '-${state.fromDate?.toFullFormat}' : ''}${state.toDate != null ? '-${state.toDate?.toFullFormat}' : ''}',
        ),
      );
    } catch (e) {
      state = state.copyWith(
        status: DailyTransactionStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
    }
  }

  Future<void> setTable() async {
    if (state.stateManager == null) return;
    state.stateManager?.setShowLoading(true);
    state = state.copyWith(status: DailyTransactionStatus.loading);

    final dailyTransactions = await getDailyTransactionReport();
    state = state.copyWith(
      status: DailyTransactionStatus.success,
      dailyTransactions: dailyTransactions.data,
      count: dailyTransactions.count,
    );
    final baseIndex = (state.pageNumber - 1) * state.pageSize + 1;
    final rows = await PlutoGridStateManager.initializeRowsAsync(
      dailyTransactionColumns,
      [
        for (int i = 0; i < state.dailyTransactions.length; i++)
          PlutoRow(
            cells: {
              'sl_no': PlutoCell(value: baseIndex + i),
              'date': PlutoCell(
                value:
                    state.dailyTransactions[i].date.toLocal().toInvoiceFormat,
              ),
              'name': PlutoCell(value: state.dailyTransactions[i].name),
              'type': PlutoCell(value: state.dailyTransactions[i].type),
              'total':
                  PlutoCell(value: state.dailyTransactions[i].transactionTotal),
              'payment_in':
                  PlutoCell(value: state.dailyTransactions[i].paymentIn ?? ''),
              'payment_out':
                  PlutoCell(value: state.dailyTransactions[i].paymentOut ?? ''),
              'balance': PlutoCell(value: state.dailyTransactions[i].balance),
            },
          ),
      ],
    );
    state.stateManager?.refRows.clear();
    state.stateManager?.refRows.addAll(rows);
    state.stateManager?.setShowLoading(false);
  }

  final List<PlutoColumn> dailyTransactionColumns = <PlutoColumn>[
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
      width: 100,
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.name,
      field: 'name',
      width: 100,
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.type,
      field: 'type',
      width: 100,
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.total,
      field: 'total',
      width: 100,
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.paymentIn,
      field: 'payment_in',
      width: 100,
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.paymentOut,
      field: 'payment_out',
      width: 100,
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.balance,
      field: 'balance',
      width: 100,
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
  ];
}
