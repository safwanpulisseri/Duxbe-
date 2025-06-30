import 'dart:async';

import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/features/purchase/purchase.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:file_picker/file_picker.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'purchase_notifier.freezed.dart';
part 'purchase_notifier.g.dart';
part 'purchase_state.dart';

@Riverpod(keepAlive: false)
Future<List<PurchaseAudit>> purchaseAudits(
  PurchaseAuditsRef ref,
  String purchaseId,
) async =>
    ref.watch(purchaseRepoProvider).getPurchaseAudits(purchaseId);

@Riverpod(keepAlive: false)
class PurchaseNotifier extends _$PurchaseNotifier {
  late IItemRepository _itemRepository;
  late IPurchaseRepository _purchaseRepository;
  final _debouncer = Debouncer(milliseconds: 500);
  @override
  PurchaseState build() {
    _itemRepository = ref.watch(itemRepoProvider);
    _purchaseRepository = ref.watch(purchaseRepoProvider);

    getCustomFields();
    ref.listen(businessNotifierProvider, (previous, next) {
      if (next?.businessId != previous?.businessId) {
        // Refresh the paging controller when business changes
        state.pagingController?.refresh();
        getCustomFields();
        resetForm();
      }
    });

    state = PurchaseState.initial();
    // This is to set infinte scrolling in mobile devices
    state = state.copyWith(
      pagingController: PagingController<int, Item>(
        firstPageKey: 1,
      )..addPageRequestListener(
          (pageKey) async {
            _debouncer.run(
              () async {
                final suppliers = await getItems(pageNumber: pageKey);
                final isLastPage = suppliers.length < state.pageSize;
                if (isLastPage) {
                  state.pagingController!.appendLastPage(suppliers);
                } else {
                  final nextPageKey = pageKey + 1;
                  state.pagingController!.appendPage(suppliers, nextPageKey);
                }
              },
            );
          },
        ),
    );
    return state;
  }

  Future<List<Item>> getItems({
    required int pageNumber,
    String? query,
    int? pageSize,
  }) async {
    try {
      final items = await _itemRepository.getItems(
        query: query ?? state.query,
        pageSize: pageSize ?? state.pageSize,
        pageNumber: pageNumber,
        purchaseEnabled: true,
        itemType: ItemType.goods.name,
      );
      return items.data;
    } catch (e) {
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  void setFilter({
    String? query,
  }) {
    state = state.copyWith(
      query: query ?? state.query,
      pageNumber: 1,
    );
    state.pagingController?.refresh();
  }

  // Form Field Updates
  void updatePurchaseInvoice(String value) {
    state = state.copyWith(purchaseInvoice: value);
  }

  void updateSupplier(Supplier? value) {
    state = state.copyWith(supplier: value);
  }

  void updateSupplierWallet({required bool useWallet}) {
    state = state.copyWith(useWallet: useWallet);
  }

  void updateShipping(double value) {
    state = state.copyWith(shipping: value);
    recalculateTotals();
  }

  void updateDiscountPercent(double value) {
    state = state.copyWith(discountPercent: value, discountAmount: subtotal * value / 100);
    recalculateTotals();
  }

  void updateDiscountAmount(double value) {
    state = state.copyWith(discountAmount: value);
    recalculateTotals();
  }

  void addItem(Item item) {
    if (state.purchaseItems.any((element) => element.item.itemId == item.itemId)) return;
    state = state.copyWith(
      purchaseItems: [
        ...state.purchaseItems,
        PurchaseItem(item: item, quantity: 1, unitPrice: item.purchasePrice),
      ],
    );
    recalculateTotals();
  }

  void updateItemQuantityInMobile(String itemId, double quantity, double purchasePrice) {
    // Check if the item is already in the cart
    final existingItemIndex = state.purchaseItems.indexWhere((item) => item.item.itemId == itemId);

    if (existingItemIndex != -1) {
      // If the item exists, update the quantity
      if (quantity <= 0) {
        // If quantity is zero or less, remove the item from the cart
        removeItem(itemId);
      } else {
        // Otherwise, update the quantity
        final updatedItems = state.purchaseItems.map((item) {
          if (item.item.itemId == itemId) {
            return item.copyWith(quantity: quantity, unitPrice: purchasePrice);
          }
          return item;
        }).toList();

        state = state.copyWith(purchaseItems: updatedItems);
        recalculateTotals();
      }
    } else {
      // If the item does not exist in the cart, add it if the quantity is greater than zero
      if (quantity > 0) {
        final itemToAdd = state.pagingController?.itemList?.firstWhere((e) => e.itemId == itemId);
        state = state.copyWith(
          purchaseItems: [
            ...state.purchaseItems,
            PurchaseItem(item: itemToAdd!, quantity: quantity, unitPrice: purchasePrice),
          ],
        );
        recalculateTotals();
      }
    }
  }

  void updateItemQuantity(String itemId, double quantity) {
    final updatedItems = state.purchaseItems.map((item) {
      if (item.item.itemId == itemId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    state = state.copyWith(purchaseItems: updatedItems);
    recalculateTotals();
  }

  void updateItemUnitPrice(String itemId, double unitPrice) {
    final updatedItems = state.purchaseItems.map((item) {
      if (item.item.itemId == itemId) {
        return item.copyWith(unitPrice: unitPrice);
      }
      return item;
    }).toList();

    state = state.copyWith(purchaseItems: updatedItems);
    recalculateTotals();
  }

  void removeItem(String itemId) {
    state = state.copyWith(
      purchaseItems: state.purchaseItems.where((item) => item.item.itemId != itemId).toList(),
    );
    recalculateTotals();
  }

  void updatePaymentDetails(Map<PaymentMode, String> value) {
    state = state.copyWith(paymentDetails: value);
  }

  void resetForm() {
    state = state.copyWith(
      purchaseInvoice: '',
      supplier: null,
      shipping: 0,
      discountPercent: 0,
      discountAmount: 0,
      purchaseItems: [],
      paymentDetails: const {},
      useWallet: true,
    );
  }

  // Total Calculation
  void recalculateTotals() {
    state = state.copyWith(status: PurchaseStatus.calculating);
    state = state.copyWith(status: PurchaseStatus.initial);
  }

  // Getters for totals
  double get subtotal => state.purchaseItems.fold(0, (sum, item) => sum + (item.quantity * item.unitPrice));
  double get grandTotal => subtotal + state.shipping - state.discountAmount;

  Future<PurchaseView> createPurchaseTransaction() async {
    if (state.supplier == null) {
      Alert.showSnackBar('Please select a supplier', type: SnackBarType.error);
      throw Exception('Please select a supplier');
    }
    final paidAmount =
        state.paymentDetails.values.fold<double>(0, (sum, element) => sum + (double.tryParse(element) ?? 0));
    if (!state.useWallet && !(paidAmount == grandTotal)) {
      Alert.showSnackBar(
        'Please enable the supplier wallet toggle to allow due amounts or balances',
        type: SnackBarType.error,
      );
      throw Exception('Please enable the supplier wallet toggle to allow due amounts or balances');
    }
    try {
      state = state.copyWith(status: PurchaseStatus.loading);
      final purchasePageData = PurchasePageData(
        purchaseInvoice: state.purchaseInvoice,
        supplier: state.supplier!,
        shipping: state.shipping,
        discountPercent: state.discountPercent,
        discountAmount: state.discountAmount,
        items: state.purchaseItems,
        paymentDetails: state.paymentDetails,
        file: state.file,
      );

      final purchase = await _purchaseRepository.createPurchaseTransaction(purchasePageData);
      state = state.copyWith(status: PurchaseStatus.success);
      Alert.showSnackBar(AppRouter.l10n.purchaseTransactionSuccessfullyCompleted, type: SnackBarType.success);
      resetForm();
      return purchase;
    } catch (e) {
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      state = state.copyWith(status: PurchaseStatus.error);
      rethrow;
    }
  }

  Future<List<CustomField>> getCustomFields() async {
    final customFields = await _purchaseRepository.getCustomFields();
    state = state.copyWith(customFields: customFields);
    return customFields;
  }

  Future<void> settlePurchase({
    required PurchaseView purchase,
    required double amount,
    required PaymentMode mode,
    required DateTime date,
  }) async {
    try {
      state = state.copyWith(status: PurchaseStatus.loading);
      await _purchaseRepository.settlePurchase(
        amount: amount,
        mode: mode,
        date: date,
        purchaseId: purchase.purchaseId,
        supplierId: purchase.supplierId,
      );
      state = state.copyWith(status: PurchaseStatus.success);
    } catch (e) {
      state = state.copyWith(status: PurchaseStatus.error);
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  void updateFile(PlatformFile? file) {
    state = state.copyWith(file: file);
  }
}
