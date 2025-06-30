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

part 'expense_notifier.freezed.dart';
part 'expense_notifier.g.dart';
part 'expense_state.dart';

@Riverpod(keepAlive: false)
Future<Expense?> expense(
  ExpenseRef ref,
  String? expenseId,
) async =>
    expenseId == null
        ? null
        : ref.watch(expenseRepoProvider).getExpenseWithId(expenseId: expenseId);

@Riverpod(keepAlive: false)
class ExpenseNotifier extends _$ExpenseNotifier {
  late IExpenseRepository _expenseRepository;

  @override
  ExpenseState build() {
    _expenseRepository =
        ref.watch(expenseRepoProvider); // Watch for business changes
    ref.listen(businessNotifierProvider, (previous, next) {
      // Refresh the paging controller when business changes
      setFilter(pageNumber: 1);
    });

    state = ExpenseState.initial();

    // This is to set infinte scrolling in mobile devices
    return state.copyWith(
      pagingController: PagingController<int, Expense>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener(
          (pageKey) async {
            final expenses = await getExpenses(pageNumber: pageKey);
            final isLastPage = expenses.data.length < state.pageSize;
            if (isLastPage) {
              state.pagingController!.appendLastPage(expenses.data);
            } else {
              final nextPageKey = pageKey + 1;
              state.pagingController!.appendPage(expenses.data, nextPageKey);
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
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    state = state.copyWith(
      query: query ?? state.query,
      pageSize: pageSize ?? state.pageSize,
      pageNumber: pageNumber ?? state.pageNumber,
      fromDate: fromDate ?? state.fromDate,
      toDate: toDate ?? state.toDate,
    );
    state.pagingController?.refresh();
    setTable();
  }

  Future<PaginatedResponse<Expense>> getExpenses({
    String? query,
    int? pageSize,
    int? pageNumber,

    /// This hack is used for null omitting,
    Object? fromDate = freezed,
    Object? toDate = freezed,
  }) async {
    try {
      final expenses = await _expenseRepository.getExpenses(
        query: query ?? state.query,
        pageSize: pageSize ?? state.pageSize,
        pageNumber: pageNumber ?? state.pageNumber,
        fromDate: fromDate == freezed ? state.fromDate : fromDate as DateTime?,
        toDate: toDate == freezed ? state.toDate : toDate as DateTime?,
      );
      return expenses;
    } catch (e) {
      state = state.copyWith(
        status: ExpenseStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<String> upsertExpense(Expense expense) async {
    try {
      state = state.copyWith(status: ExpenseStatus.loading);
      final updatedExpense = await _expenseRepository.upsertExpense(expense);
      state = state.copyWith(status: ExpenseStatus.success);
      setFilter(pageNumber: 1);
      return updatedExpense;
    } catch (e) {
      state = state.copyWith(
        status: ExpenseStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<void> deleteExpense(Expense expense) async {
    try {
      state = state.copyWith(status: ExpenseStatus.loading);
      await _expenseRepository.deleteExpense(expense.transactionId!);
      state = state.copyWith(status: ExpenseStatus.success);
      Alert.showSnackBar(AppRouter.l10n.expenseDeletedSuccessfully,
          type: SnackBarType.success);
      setFilter(pageNumber: 1);
    } catch (e) {
      state = state.copyWith(
        status: ExpenseStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
    }
  }

  Future<void> setTable() async {
    if (state.stateManager == null) return;
    state.stateManager?.setShowLoading(true);
    state = state.copyWith(status: ExpenseStatus.loading);

    final expenses = await getExpenses();
    state = state.copyWith(
      status: ExpenseStatus.success,
      expenses: expenses.data,
      count: expenses.count,
      totalAmount: expenses.json['amount_sum'] as num,
    );

    final baseIndex = (state.pageNumber - 1) * state.pageSize + 1;
    final rows = await PlutoGridStateManager.initializeRowsAsync(
      expenseColumns,
      [
        for (int i = 0; i < state.expenses.length; i++)
          PlutoRow(
            cells: {
              'sl_no': PlutoCell(value: baseIndex + i),
              'date': PlutoCell(value: state.expenses[i].date.toFullFormat),
              'expense_for': PlutoCell(value: state.expenses[i].expenseFor),
              'category':
                  PlutoCell(value: state.expenses[i].category?.name ?? ''),
              'note': PlutoCell(value: state.expenses[i].note ?? ''),
              'payment_type': PlutoCell(
                  value: state.expenses[i].paymentType.name.displayCase),
              'amount': PlutoCell(value: state.expenses[i].amount),
              'actions': PlutoCell(value: state.expenses[i]),
            },
          ),
      ],
    );
    state.stateManager?.refRows.clear();
    state.stateManager?.refRows.addAll(rows);
    state.stateManager?.setShowLoading(false);
  }

  final List<PlutoColumn> expenseColumns = <PlutoColumn>[
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
      title: 'Expense For',
      field: 'expense_for',
      titleSpan: TextSpan(
        text: AppRouter.l10n.expenseFor,
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
        final expense = rendererContext.cell.value as Expense;
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
                AppRouter.goNamed(AppRouter.expenseDetails,
                    pathParameters: {'id': expense.expenseId!});
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
                      isLoading: ref.watch(expenseNotifierProvider).status ==
                          ExpenseStatus.loading,
                      title: AppRouter.l10n.deleteExpense,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppRouter.l10n.areYouSureYouWantToDeleteThisExpense,
                          style: AppText.mediumN
                              .copyWith(color: AppColors.primaryColor),
                        ),
                      ],
                      onPositive: (ref) {
                        ref
                            .read(expenseNotifierProvider.notifier)
                            .deleteExpense(expense)
                            .then(AppRouter.pop);
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
