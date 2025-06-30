import 'dart:async';

import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'item_category_notifier.freezed.dart';
part 'item_category_notifier.g.dart';
part 'item_category_state.dart';

@Riverpod(keepAlive: false)
Future<ItemCategory?> itemCategory(
  ItemCategoryRef ref,
  String? itemCategoryId,
) async =>
    itemCategoryId == null
        ? null
        : ref.watch(itemCategoryRepoProvider).getItemCategoryWithId(itemCategoryId: itemCategoryId);

@Riverpod(keepAlive: false)
class ItemCategoryNotifier extends _$ItemCategoryNotifier {
  late IItemCategoryRepository _itemCategoryRepository;

  @override
  ItemCategoryState build() {
    _itemCategoryRepository = ref.watch(itemCategoryRepoProvider); // Watch for business changes
    ref.listen(businessNotifierProvider, (previous, next) {
      // Refresh the paging controller when business changes
      if (next?.businessId != previous?.businessId) {
        // Refresh the paging controller when business changes
        setFilter(pageNumber: 1);
      }
    });

    state = ItemCategoryState.initial();

    // This is to set infinte scrolling in mobile devices
    return state.copyWith(
      pagingController: PagingController<int, ItemCategory>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener(
          (pageKey) async {
            final itemCategories = await getItemCategories(pageNumber: pageKey);
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

  Future<PaginatedResponse<ItemCategory>> getItemCategories({
    String? query,
    int? pageSize,
    int? pageNumber,
  }) async {
    try {
      final itemCategories = await _itemCategoryRepository.getItemCategories(
        query: query ?? state.query,
        pageSize: pageSize ?? state.pageSize,
        pageNumber: pageNumber ?? state.pageNumber,
      );
      return itemCategories;
    } catch (e) {
      state = state.copyWith(
        status: ItemCategoryStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<ItemCategory> upsertItemCategory(ItemCategory itemCategory) async {
    try {
      state = state.copyWith(status: ItemCategoryStatus.loading);
      final updatedUnit = await _itemCategoryRepository.upsertItemCategory(itemCategory);
      state = state.copyWith(status: ItemCategoryStatus.success);
      setFilter(pageNumber: 1);
      // show success snackbar, different message for insert and update, if itemCategoryId is null, it is an insert, otherwise an update
      Alert.showSnackBar(
        itemCategory.itemCategoryId == null ? AppRouter.l10n.itemCategoryAdded : AppRouter.l10n.itemCategoryUpdated,
        type: SnackBarType.success,
      );
      return updatedUnit;
    } catch (e) {
      state = state.copyWith(
        status: ItemCategoryStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<void> deleteItemCategory(ItemCategory itemCategory) async {
    try {
      state = state.copyWith(status: ItemCategoryStatus.loading);
      await _itemCategoryRepository.deleteItemCategory(itemCategory.itemCategoryId!);
      state = state.copyWith(status: ItemCategoryStatus.success);
      setFilter(pageNumber: 1);
      // delete success snackbar
      Alert.showSnackBar(AppRouter.l10n.itemCategoryDeleted, type: SnackBarType.success);
    } catch (e) {
      state = state.copyWith(
        status: ItemCategoryStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
    }
  }

  Future<void> setTable() async {
    if (state.stateManager == null) return;

    state.stateManager?.setShowLoading(true);
    state = state.copyWith(status: ItemCategoryStatus.loading);
    final itemCategories = await getItemCategories();
    state = state.copyWith(
      status: ItemCategoryStatus.success,
      itemCategories: itemCategories.data,
      count: itemCategories.count,
    );

    final baseIndex = (state.pageNumber - 1) * state.pageSize + 1;
    final rows = await PlutoGridStateManager.initializeRowsAsync(
      categoryColumns,
      [
        for (int i = 0; i < state.itemCategories.length; i++)
          PlutoRow(
            cells: {
              'sl_no': PlutoCell(value: baseIndex + i),
              'category_name': PlutoCell(value: state.itemCategories[i].name),
              'description': PlutoCell(value: state.itemCategories[i].description ?? ''),
              'actions': PlutoCell(value: state.itemCategories[i]),
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
      title: AppRouter.l10n.categoryName,
      field: 'category_name',
      titleSpan: TextSpan(
        text: AppRouter.l10n.categoryName,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.description,
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
      title: AppRouter.l10n.actions,
      field: 'actions',
      titleSpan: TextSpan(
        text: AppRouter.l10n.actions,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      renderer: (rendererContext) {
        final category = rendererContext.cell.value as ItemCategory;
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
                  builder: (context) => AddCategoryDialog(
                    category: category,
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
                      ref.read(itemCategoryNotifierProvider.notifier).deleteItemCategory(category).then(AppRouter.pop);
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
