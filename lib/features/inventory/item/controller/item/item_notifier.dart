import 'dart:async';

import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/features/purchase/purchase.dart';
import 'package:duxbe/features/sale/controller/sales/sales_notifier.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'item_notifier.freezed.dart';
part 'item_notifier.g.dart';
part 'item_state.dart';

@Riverpod(keepAlive: false)
Future<Item?> item(
  ItemRef ref,
  String? itemId,
) async =>
    itemId == null ? null : ref.watch(itemRepoProvider).getItemWithId(itemId: itemId);

@Riverpod(keepAlive: false)
class ItemNotifier extends _$ItemNotifier {
  late IItemRepository _itemRepository;

  @override
  ItemState build() {
    _itemRepository = ref.watch(itemRepoProvider); // Watch for business changes
    getCustomFields();
    ref.listen(businessNotifierProvider, (previous, next) {
      if (next?.businessId != previous?.businessId) {
        // Refresh the paging controller when business changes
        setFilter(pageNumber: 1);
        getCustomFields();
      }
    });

    state = ItemState.initial();

    // This is to set infinte scrolling in mobile devices
    return state.copyWith(
      pagingController: PagingController<int, Item>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener(
          (pageKey) async {
            final items = await getItems(pageNumber: pageKey);
            final isLastPage = items.data.length < state.pageSize;
            if (isLastPage) {
              state.pagingController!.appendLastPage(items.data);
            } else {
              final nextPageKey = pageKey + 1;
              state.pagingController!.appendPage(items.data, nextPageKey);
            }
          },
        ),
      goodsPagingController: PagingController<int, Item>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener(
          (pageKey) async {
            final items = await getItems(pageNumber: pageKey, itemType: ItemType.goods);
            final isLastPage = items.data.length < state.pageSize;
            if (isLastPage) {
              state.goodsPagingController!.appendLastPage(items.data);
            } else {
              final nextPageKey = pageKey + 1;
              state.goodsPagingController!.appendPage(items.data, nextPageKey);
            }
          },
        ),
      servicesPagingController: PagingController<int, Item>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener(
          (pageKey) async {
            final items = await getItems(pageNumber: pageKey, itemType: ItemType.services);
            final isLastPage = items.data.length < state.pageSize;
            if (isLastPage) {
              state.servicesPagingController!.appendLastPage(items.data);
            } else {
              final nextPageKey = pageKey + 1;
              state.servicesPagingController!.appendPage(items.data, nextPageKey);
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
    Object? itemType = freezed,
  }) {
    state = state.copyWith(
      query: query ?? state.query,
      pageSize: pageSize ?? state.pageSize,
      pageNumber: pageNumber ?? state.pageNumber,
      itemType: itemType == freezed ? state.itemType : itemType as ItemType?,
    );
    state.pagingController?.refresh();
    state.goodsPagingController?.refresh();
    state.servicesPagingController?.refresh();
    setTable();
  }

  Future<PaginatedResponse<Item>> getItems({
    String? query,
    ItemType? itemType,
    int? pageSize,
    int? pageNumber,
  }) async {
    try {
      final items = await _itemRepository.getItems(
        query: query ?? state.query,
        pageSize: pageSize ?? state.pageSize,
        pageNumber: pageNumber ?? state.pageNumber,
        itemType: itemType?.name ?? state.itemType?.name,
      );
      return items;
    } catch (e) {
      state = state.copyWith(
        status: ItemStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<List<CustomField>> getCustomFields() async {
    try {
      final customFields = await _itemRepository.getCustomFields();
      state = state.copyWith(customFields: customFields);
      return customFields;
    } catch (e) {
      state = state.copyWith(
        status: ItemStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      return [];
    }
  }

  Future<void> upsertItem(
    Map<String, dynamic> item,
    List<ItemImage> images, {
    List<ItemImage> initialImages = const [],
  }) async {
    try {
      state = state.copyWith(status: ItemStatus.loading);

      final upsertData = {
        'name': item['name'],
        'item_id': item['item_id'],
        'item_type': item['item_type'],
        'item_category_id': (item['item_category'] as ItemCategory?)?.itemCategoryId,
        'brand_id': (item['brand'] as Brand?)?.brandId,
        'tax_id': (item['tax'] as Tax?)?.taxId,
        'preferred_vendor_id': (item['preferred_vendor'] as Supplier?)?.supplierId,
        'item_code': item['item_code'],
        'unit_id': (item['unit'] as Unit?)?.unitId,
        'sale_price': item['sale_price'],
        'retail_price': item['retail_price'],
        'purchase_price': item['purchase_price'],
        'opening_stock_qty': item['opening_qty'],
        'quantity': item['quantity'],
        'opening_stock_value': item['opening_value'],
        'is_returnable': item['is_returnable'],
        'alert_quantity': item['alert_qty'] ?? 0,
        'rich_text': item['rich_text'],
        'serial_nos': item['serial_number'] ?? <String>[],
        'sales_enabled': item['sales_enabled'],
        'purchase_enabled': item['purchase_enabled'],
        'inventory_enabled': item['track_inventory'],
        'is_tax_inclusive': item['is_tax_inclusive'],
        'custom_fields': state.customFields
            .map(
              (e) => {
                'key': e.fieldName,
                'value': item[e.fieldName],
              },
            )
            .toList(),
        'sub_services': item['sub_service'],
      };

      await _itemRepository.upsertItem(upsertData, images, initialImages: initialImages);
      // show success snackbar
      Alert.showSnackBar(AppRouter.l10n.itemAdded, type: SnackBarType.success);

      state = state.copyWith(status: ItemStatus.success);
      setFilter();
      ref.read(salesNotifierProvider).pagingController?.refresh();
      ref.read(purchaseNotifierProvider).pagingController?.refresh();
      ref.invalidate(itemProvider(item['item_id']?.toString()));
      return;
    } catch (e) {
      state = state.copyWith(
        status: ItemStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<void> deleteItem(Item item) async {
    try {
      state = state.copyWith(status: ItemStatus.loading);
      await _itemRepository.deleteItem(item.itemId!);
      state = state.copyWith(status: ItemStatus.success);
      setFilter();
      Alert.showSnackBar(AppRouter.l10n.itemDeletedSuccessfully, type: SnackBarType.success);
    } catch (e) {
      state = state.copyWith(
        status: ItemStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
    }
  }

  Future<void> setTable() async {
    if (state.stateManager == null) return;
    state.stateManager?.setShowLoading(true);
    state = state.copyWith(
      status: ItemStatus.loading,
      query: state.query,
      pageNumber: state.pageNumber,
      pageSize: state.pageSize,
      itemType: state.itemType,
    );

    final baseIndex = (state.pageNumber - 1) * state.pageSize + 1;
    final items = await getItems();
    state = state.copyWith(
      status: ItemStatus.success,
      items: items.data,
      count: items.count,
    );
    final rows = await PlutoGridStateManager.initializeRowsAsync(
      itemColumns,
      [
        for (int i = 0; i < state.items.length; i++)
          PlutoRow(
            cells: {
              'sl_no': PlutoCell(value: baseIndex + i),
              'item_name': PlutoCell(value: state.items[i].name),
              'code': PlutoCell(value: state.items[i].itemCode),
              'category': PlutoCell(value: state.items[i].itemCategory?.name ?? ''),
              'sale_price': PlutoCell(value: state.items[i].salePrice),
              'purchase_price': PlutoCell(value: state.items[i].purchasePrice),
              'stock': PlutoCell(value: state.items[i].stockQuantity),
              'actions': PlutoCell(value: state.items[i]),
            },
          ),
      ],
    );
    state.stateManager?.refRows.clear();
    state.stateManager?.refRows.addAll(rows);
    state.stateManager?.setShowLoading(false);
  }

  final List<PlutoColumn> itemColumns = <PlutoColumn>[
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
      title: AppRouter.l10n.itemName,
      field: 'item_name',
      titleSpan: TextSpan(
        text: AppRouter.l10n.itemName,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.code,
      field: 'code',
      titleSpan: TextSpan(
        text: AppRouter.l10n.itemCode,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.category,
      field: 'category',
      titleSpan: TextSpan(
        text: AppRouter.l10n.itemCategory,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.salePrice,
      field: 'sale_price',
      titleSpan: TextSpan(
        text: AppRouter.l10n.salePrice,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.purchasePrice,
      field: 'purchase_price',
      titleSpan: TextSpan(
        text: AppRouter.l10n.purchasePrice,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.stock,
      field: 'stock',
      titleSpan: TextSpan(
        text: AppRouter.l10n.stock,
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
        text: AppRouter.l10n.action,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      renderer: (rendererContext) {
        final item = rendererContext.cell.value as Item;
        return MenuAnchor(
          builder: (context, controller, child) {
            return IconButton(
              onPressed: controller.isOpen ? controller.close : controller.open,
              icon: const Icon(Icons.more_horiz),
            );
          },
          menuChildren: [
            MenuItemButton(
              leadingIcon: const Icon(Icons.remove_red_eye_outlined),
              style: MenuItemButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
              ),
              onPressed: () {
                AppRouter.pushNamed(
                  AppRouter.itemView,
                  pathParameters: {'id': item.itemId!},
                );
              },
              child: Text(AppRouter.l10n.view),
            ),
            MenuItemButton(
              leadingIcon: Assets.icons.barcodeAlt.svg(width: 20),
              style: MenuItemButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
              ),
              onPressed: () {
                AppRouter.pushNamed(
                  AppRouter.printBarcode,
                  pathParameters: {'id': item.itemId!},
                );
              },
              child: Text(AppRouter.l10n.printBarcode),
            ),
            MenuItemButton(
              leadingIcon: Assets.icons.edit.svg(width: 20),
              style: MenuItemButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
              ),
              onPressed: () {
                AppRouter.pushNamed(
                  AppRouter.itemDetails,
                  pathParameters: {'id': item.itemId!},
                );
              },
              child: Text(AppRouter.l10n.edit),
            ),
            MenuItemButton(
              leadingIcon: Assets.icons.delete.svg(width: 20),
              onPressed: () {
                showDialog<void>(
                  context: AppRouter.rootContext,
                  builder: (context) {
                    return ConfirmationDialog(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      title: AppRouter.l10n.deleteItem,
                      children: [
                        Text(
                          AppRouter.l10n.deleteThisItem,
                          style: AppText.mediumN.copyWith(color: AppColors.primaryColor),
                        ),
                      ],
                      onPositive: (ref) {
                        ref.read(itemNotifierProvider.notifier).deleteItem(item).then(AppRouter.pop);
                      },
                    );
                  },
                );
              },
              style: MenuItemButton.styleFrom(foregroundColor: AppColors.red),
              child: Text(AppRouter.l10n.delete),
            ),
          ],
        );
      },
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
  ];
}
