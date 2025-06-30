import 'dart:async';

import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'income_category_notifier.freezed.dart';
part 'income_category_notifier.g.dart';
part 'income_category_state.dart';

@Riverpod(keepAlive: false)
Future<TransactionCategory?> incomeCategory(
  IncomeCategoryRef ref,
  String? incomeCategoryId,
) async =>
    incomeCategoryId == null
        ? null
        : ref.watch(incomeCategoryRepoProvider).getIncomeCategoryWithId(incomeCategoryId: incomeCategoryId);

@Riverpod(keepAlive: false)
class IncomeCategoryNotifier extends _$IncomeCategoryNotifier {
  late IIncomeCategoryRepository _incomeCategoryRepository;

  @override
  IncomeCategoryState build() {
    _incomeCategoryRepository = ref.watch(incomeCategoryRepoProvider); // Watch for business changes
    ref.listen(businessNotifierProvider, (previous, next) {
      // Refresh the paging controller when business changes
      setFilter(pageNumber: 1);
    });

    state = IncomeCategoryState.initial();

    // This is to set infinte scrolling in mobile devices
    return state.copyWith(
      pagingController: PagingController<int, TransactionCategory>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener(
          (pageKey) async {
            final itemCategories = await getIncomeCategories(pageNumber: pageKey);
            final isLastPage = itemCategories.data.length < state.pageSize;
            if (isLastPage) {
              state.pagingController!.appendLastPage(itemCategories.data);
            } else {
              final nextPageKey = pageKey + 1;
              state.pagingController!.appendPage(itemCategories.data, nextPageKey);
            }
          },
        ),
    );
  }

  void setStateManager({required PlutoGridStateManager stateManager}) {
    state = state.copyWith(stateManager: stateManager);
    setTable();
  }

  Future<PaginatedResponse<TransactionCategory>> getIncomeCategories({
    String? query,
    int? pageSize,
    int? pageNumber,
  }) async {
    try {
      final incomeCategories = await _incomeCategoryRepository.getIncomeCategories(
        query: query ?? state.query,
        pageSize: pageSize ?? state.pageSize,
        pageNumber: pageNumber ?? state.pageNumber,
      );
      return incomeCategories;
    } catch (e) {
      state = state.copyWith(
        status: IncomeCategoryStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<TransactionCategory> upsertIncomeCategory(TransactionCategory incomeCategory) async {
    try {
      state = state.copyWith(status: IncomeCategoryStatus.loading);
      final updatedUnit = await _incomeCategoryRepository.upsertIncomeCategory(incomeCategory);
      state = state.copyWith(status: IncomeCategoryStatus.success);
      Alert.showSnackBar(
        'Income Category ${incomeCategory.categoryId == null ? 'created' : 'edited'} successfully',
        type: SnackBarType.success,
      );
      setFilter(pageNumber: 1);
      return updatedUnit;
    } catch (e) {
      state = state.copyWith(
        status: IncomeCategoryStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<void> deleteIncomeCategory(TransactionCategory incomeCategory) async {
    try {
      state = state.copyWith(status: IncomeCategoryStatus.loading);
      await _incomeCategoryRepository.deleteIncomeCategory(incomeCategory.categoryId!);
      state = state.copyWith(status: IncomeCategoryStatus.success);
      Alert.showSnackBar('Income Category deleted successfully', type: SnackBarType.success);
      setFilter(pageNumber: 1);
    } catch (e) {
      state = state.copyWith(
        status: IncomeCategoryStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
    }
  }

  void setFilter({
    String? query,
    int? pageSize,
    int? pageNumber,
  }) {
    state = state.copyWith(
      query: query ?? state.query,
      pageSize: pageSize ?? state.pageSize,
      pageNumber: pageNumber ?? state.pageNumber,
    );
    state.pagingController?.refresh();
    setTable();
  }

  Future<void> setTable() async {
    if (state.stateManager == null) return;
    state.stateManager?.setShowLoading(true);
    state = state.copyWith(status: IncomeCategoryStatus.loading);

    final incomeCategories = await getIncomeCategories();

    state = state.copyWith(
      status: IncomeCategoryStatus.success,
      incomeCategories: incomeCategories.data,
      count: incomeCategories.count,
    );

    final baseIndex = (state.pageNumber - 1) * state.pageSize + 1;
    final rows = await PlutoGridStateManager.initializeRowsAsync(
      categoryColumns,
      [
        for (int i = 0; i < state.incomeCategories.length; i++)
          PlutoRow(
            cells: {
              'sl_no': PlutoCell(value: baseIndex + i),
              'category_name': PlutoCell(value: state.incomeCategories[i].name),
              'description': PlutoCell(value: state.incomeCategories[i].description ?? ''),
              'actions': PlutoCell(value: state.incomeCategories[i]),
            },
          ),
      ],
    );
    state.stateManager?.refRows.clear();
    state.stateManager?.refRows.addAll(rows);
    state.stateManager?.setShowLoading(false);
  }

  final List<PlutoColumn> categoryColumns = <PlutoColumn>[
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
      title: 'Category Name',
      field: 'category_name',
      titleSpan: TextSpan(
        text: AppRouter.l10n.categoryName,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: 'Description',
      field: 'description',
      titleSpan: TextSpan(
        text: AppRouter.l10n.description,
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
        final category = rendererContext.cell.value as TransactionCategory;
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
                showDialog<void>(
                  context: AppRouter.rootContext,
                  builder: (context) => AddTransactionCategoryDialog(
                    category: category,
                    type: TransactionCategoryType.income,
                  ),
                );
              },
              label: Text(AppRouter.l10n.edit),
            ),
            const SizedBox(width: 20),
            TextButton.icon(
              icon: Assets.icons.delete.svg(),
              style: TextButton.styleFrom(
                iconColor: AppColors.red,
                backgroundColor: AppColors.red.withOpacity(.05),
                foregroundColor: AppColors.red.withOpacity(.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () {
                showDialog<void>(
                  context: AppRouter.rootContext,
                  builder: (context) => ConfirmationDialog(
                    title: AppRouter.l10n.deleteCategory,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppRouter.l10n.deleteThisCategory,
                        style: AppText.mediumN.copyWith(color: AppColors.primaryColor),
                      ),
                    ],
                    onPositive: (ref) {
                      ref
                          .read(incomeCategoryNotifierProvider.notifier)
                          .deleteIncomeCategory(category)
                          .then(AppRouter.pop);
                    },
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
