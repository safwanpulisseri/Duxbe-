import 'dart:async';

import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'income_notifier.freezed.dart';
part 'income_notifier.g.dart';
part 'income_state.dart';

@Riverpod(keepAlive: false)
Future<Income?> income(
  IncomeRef ref,
  String? incomeId,
) async =>
    incomeId == null ? null : ref.watch(incomeRepoProvider).getIncomeWithId(incomeId: incomeId);

@Riverpod(keepAlive: false)
class IncomeNotifier extends _$IncomeNotifier {
  late IIncomeRepository _incomeRepository;

  @override
  IncomeState build() {
    _incomeRepository = ref.watch(incomeRepoProvider); // Watch for business changes
    ref.listen(businessNotifierProvider, (previous, next) {
      // Refresh the paging controller when business changes
      setFilter(pageNumber: 1);
    });

    state = IncomeState.initial();

    // This is to set infinte scrolling in mobile devices
    return state.copyWith(
      pagingController: PagingController<int, Income>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener(
          (pageKey) async {
            final incomes = await getIncomes(pageNumber: pageKey);
            final isLastPage = incomes.data.length < state.pageSize;
            if (isLastPage) {
              state.pagingController!.appendLastPage(incomes.data);
            } else {
              final nextPageKey = pageKey + 1;
              state.pagingController!.appendPage(incomes.data, nextPageKey);
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
    Object? fromDate,
    Object? toDate,
  }) {
    state = state.copyWith(
      query: query ?? state.query,
      pageSize: pageSize ?? state.pageSize,
      pageNumber: pageNumber ?? state.pageNumber,
      fromDate: fromDate == freezed ? state.fromDate : fromDate as DateTime?,
      toDate: toDate == freezed ? state.toDate : toDate as DateTime?,
    );
    state.pagingController?.refresh();
    setTable();
  }

  Future<PaginatedResponse<Income>> getIncomes({
    String? query,
    int? pageSize,
    int? pageNumber,

    /// This hack is used for null omitting,
    Object? fromDate = freezed,
    Object? toDate = freezed,
  }) async {
    try {
      final incomes = await _incomeRepository.getIncomes(
        query: query ?? state.query,
        pageSize: pageSize ?? state.pageSize,
        pageNumber: pageNumber ?? state.pageNumber,
        fromDate: fromDate == freezed ? state.fromDate : fromDate as DateTime?,
        toDate: toDate == freezed ? state.toDate : toDate as DateTime?,
      );
      return incomes;
    } catch (e) {
      state = state.copyWith(
        status: IncomeStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<String> upsertIncome(Income income) async {
    try {
      state = state.copyWith(status: IncomeStatus.loading);
      final updatedIncome = await _incomeRepository.upsertIncome(income);
      state = state.copyWith(status: IncomeStatus.success);
      setFilter(pageNumber: 1);
      return updatedIncome;
    } catch (e) {
      state = state.copyWith(
        status: IncomeStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<void> deleteIncome(Income income) async {
    try {
      state = state.copyWith(status: IncomeStatus.loading);
      await _incomeRepository.deleteIncome(income.transactionId!);
      state = state.copyWith(status: IncomeStatus.success);
      setFilter(pageNumber: 1);
    } catch (e) {
      state = state.copyWith(
        status: IncomeStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
    }
  }

  Future<void> setTable() async {
    if (state.stateManager == null) return;
    state.stateManager?.setShowLoading(true);
    state = state.copyWith(status: IncomeStatus.loading);
    final incomes = await getIncomes();
    state = state.copyWith(
      status: IncomeStatus.success,
      incomes: incomes.data,
      count: incomes.count,
      totalAmount: incomes.json['amount_sum'] as double,
    );

    final baseIndex = (state.pageNumber - 1) * state.pageSize + 1;
    final rows = await PlutoGridStateManager.initializeRowsAsync(
      incomeColumns,
      [
        for (int i = 0; i < state.incomes.length; i++)
          PlutoRow(
            cells: {
              'sl_no': PlutoCell(value: baseIndex + i),
              'date': PlutoCell(value: state.incomes[i].date.toFullFormat),
              'income_for': PlutoCell(value: state.incomes[i].incomeFor),
              'category': PlutoCell(value: state.incomes[i].category?.name ?? ''),
              'note': PlutoCell(value: state.incomes[i].note ?? ''),
              'payment_type': PlutoCell(value: state.incomes[i].paymentType.name.displayCase),
              'amount': PlutoCell(value: state.incomes[i].amount),
              'actions': PlutoCell(value: state.incomes[i]),
            },
          ),
      ],
    );
    state.stateManager?.refRows.clear();
    state.stateManager?.refRows.addAll(rows);
    state.stateManager?.setShowLoading(false);
  }

  final List<PlutoColumn> incomeColumns = <PlutoColumn>[
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
      title: 'Income For',
      field: 'income_for',
      titleSpan: TextSpan(
        text: AppRouter.l10n.incomeFor,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: 'Category',
      field: 'category',
      titleSpan: TextSpan(
        text: AppRouter.l10n.category,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: 'Note',
      field: 'note',
      titleSpan: TextSpan(
        text: AppRouter.l10n.note,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: 'Payment Type',
      field: 'payment_type',
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
      titleTextAlign: PlutoColumnTextAlign.center,
      title: 'Action',
      field: 'actions',
      titleSpan: TextSpan(
        text: AppRouter.l10n.actions,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      renderer: (rendererContext) {
        final income = rendererContext.cell.value as Income;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              icon: Assets.icons.edit.svg(),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primaryColor.withOpacity(.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () {
                AppRouter.goNamed(AppRouter.incomeDetails, pathParameters: {'id': income.incomeId!});
              },
              label: Text(AppRouter.l10n.edit),
            ),
            const SizedBox(width: 20),
            TextButton.icon(
              icon: Assets.icons.delete.svg(),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.red.withOpacity(.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () {
                showDialog<void>(
                  context: AppRouter.rootContext,
                  builder: (context) => Consumer(
                    builder: (context, ref, child) => ConfirmationDialog(
                      positiveText: AppRouter.l10n.delete,
                      isLoading: ref.watch(incomeNotifierProvider).status == IncomeStatus.loading,
                      title: AppRouter.l10n.deleteIncome,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppRouter.l10n.areYouSureYouWantToDeleteThisIncome,
                          style: AppText.mediumN.copyWith(color: AppColors.primaryColor),
                        ),
                      ],
                      onPositive: (ref) {
                        ref.read(incomeNotifierProvider.notifier).deleteIncome(income).then(AppRouter.pop);
                      },
                    ),
                  ),
                );
              },
              label: Text(
                AppRouter.l10n.delete,
                style: AppText.mediumN.copyWith(color: AppColors.red),
              ),
            ),
          ],
        );
      },
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
  ];
}
