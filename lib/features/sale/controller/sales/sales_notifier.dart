import 'dart:async';
import 'dart:convert';

import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/features/reservations/reservations.dart';
import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sales_notifier.freezed.dart';
part 'sales_notifier.g.dart';
part 'sales_state.dart';

@Riverpod(keepAlive: false)
Future<List<Status>> saleStatuses(
  SaleStatusesRef ref,
) async =>
    ref.watch(saleRepoProvider).getSaleStatuses();

@Riverpod(keepAlive: false)
Future<List<SaleAudit>> saleAudits(
  SaleAuditsRef ref,
  String saleId,
) async =>
    ref.watch(saleRepoProvider).getSaleAudits(saleId);

@Riverpod(keepAlive: false)
class SalesNotifier extends _$SalesNotifier {
  late IItemRepository _itemRepository;
  late ISaleRepository _saleRepository;
  late IItemCategoryRepository _itemCategoryRepository;

  final _debouncer = Debouncer(milliseconds: 500);

  @override
  SalesState build() {
    _itemRepository = ref.watch(itemRepoProvider);
    _saleRepository = ref.watch(saleRepoProvider);
    _itemCategoryRepository = ref.watch(itemCategoryRepoProvider);
    getCustomFields();
    final business = ref.watch(businessNotifierProvider);
    ref.listen(businessNotifierProvider, (previous, next) {
      if (next?.businessId != previous?.businessId) {
        // Refresh the paging controller when business changes
        state.pagingController?.refresh();
        state.categoryPagingController?.refresh();
        state = state.copyWith(orderMode: next?.businessType == BusinessType.foodAndBeverage);
        getCustomFields();
        resetForm();
      }
    });

    state = SalesState.initial();
    // This is to set infinte scrolling in mobile devices
    state = state.copyWith(
      orderMode: business?.businessType == BusinessType.foodAndBeverage,
      employee: ref.read(authNotifierProvider).user,
      pagingController: PagingController<int, Item>(
        firstPageKey: 1,
      )..addPageRequestListener(
          (pageKey) async {
            _debouncer.run(
              () async {
                final items = await getItems(
                  pageNumber: pageKey,
                  type: state.selectedItemType,
                  selectedCategories: state.selectedCategories,
                );
                final isLastPage = items.length < state.pageSize;
                if (isLastPage) {
                  state.pagingController!.appendLastPage(items);
                } else {
                  final nextPageKey = pageKey + 1;
                  state.pagingController!.appendPage(items, nextPageKey);
                }
              },
            );
          },
        ),
      categoryPagingController: PagingController<int, ItemCategory>(
        firstPageKey: 1,
      )..addPageRequestListener(
          (pageKey) async {
            final categories = await getCategories(pageNumber: pageKey);
            final isLastPage = categories.length < state.pageSize;
            if (isLastPage) {
              state.categoryPagingController!.appendLastPage(categories);
            } else {
              final nextPageKey = pageKey + 1;
              state.categoryPagingController!.appendPage(categories, nextPageKey);
            }
          },
        ),
    );
    recalculateTotals();
    return state;
  }

  Future<List<Item>> getItems({
    required int pageNumber,
    String? query,
    int? pageSize,
    ItemType? type,
    List<ItemCategory>? selectedCategories,
  }) async {
    try {
      final items = await _itemRepository.getItems(
        query: query ?? state.query,
        pageSize: pageSize ?? state.pageSize,
        pageNumber: pageNumber,
        salesEnabled: true,
        itemType: type?.name ?? state.selectedItemType.name,
        categories: selectedCategories ?? state.selectedCategories,
      );
      return items.data;
    } catch (e) {
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  void addNote(String note, int index) {
    final items = state.saleItems;
    items[index].note = note;
    state = state.copyWith(saleItems: items);
    // state.saleItems.addAll(items);
  }

  Future<List<ItemCategory>> getCategories({
    required int pageNumber,
    String? query,
    int? pageSize,
  }) async {
    final categories = await _itemCategoryRepository.getItemCategories(
      query: query ?? state.query,
      pageSize: pageSize ?? state.pageSize,
      pageNumber: pageNumber,
    );
    return categories.data;
  }

  Future<List<CustomField>> getCustomFields() async {
    try {
      final customFields = await _saleRepository.getCustomFields();
      state = state.copyWith(customFields: customFields);
      return customFields;
    } catch (e) {
      state = state.copyWith(
        status: SalesStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      return [];
    }
  }

  void setFilter({
    String? query,
    ItemType? type,
    List<ItemCategory>? selectedCategories,
  }) {
    state = state.copyWith(
      query: query ?? state.query,
      selectedItemType: type ?? state.selectedItemType,
      pageNumber: 1,
      selectedCategories: selectedCategories ?? state.selectedCategories,
    );
    state.pagingController?.refresh();
  }

  // Update state methods
  void updateCustomer(Customer? customer) {
    state = state.copyWith(customer: customer);
  }

  void updateEmployee(EmployeeModel? employee) {
    state = state.copyWith(employee: employee);
  }

  void updateOrderMode({required bool orderMode}) {
    state = state.copyWith(orderMode: orderMode);
  }

  void updateShipping(double value) {
    state = state.copyWith(shipping: value);
    recalculateTotals();
  }

  void updateDiscountPercent(double value) {
    state = state.copyWith(discountPercent: value);
    state = state.copyWith(discountAmount: (state.subtotal * value / 100).toPrecision(2));
    recalculateTotals();
  }

  void updateDiscountAmount(double value) {
    state = state.copyWith(discountAmount: value);
    if (state.subtotal > 0) {
      state = state.copyWith(discountPercent: ((value / state.subtotal) * 100).toPrecision(2));
    }
    recalculateTotals();
  }

  void updateSelectedTable(Table? table) {
    state = state.copyWith(selectedTable: table);
  }

  void updateCustomFieldValue(String key, dynamic value) {
    final updatedCustomFieldValues = Map<String, dynamic>.from(state.customFieldValues);
    updatedCustomFieldValues[key] = value;
    state = state.copyWith(customFieldValues: updatedCustomFieldValues);
  }

  void updateUseWallet({required bool useWallet}) {
    state = state.copyWith(useWallet: useWallet);
  }

  void addItem(Item item, {List<SubService>? selectedServices}) {
    // For service items, compare both itemId and selected subservices
    final isService = item.itemType == ItemType.services;
    final subServiceIds =
        (selectedServices ?? []).map((e) => e.subServiceId).toSet();

    final existingIndex = state.saleItems.indexWhere((element) {
      final sameId = element.item.itemId == item.itemId;
      if (!isService) return sameId;
      final elementSubServiceIds =
          element.selectedSubServices.map((e) => e.subServiceId).toSet();
      return sameId && setEquals(subServiceIds, elementSubServiceIds);
    });

    if (existingIndex != -1) {
      final existingItem = state.saleItems[existingIndex];
      updateItemQuantity(
        existingItem.item.itemId!,
        existingItem.quantity + 1,
        selectedSubServices: existingItem.selectedSubServices,
      );
      return;
    }

    state = state.copyWith(
      saleItems: [
        ...state.saleItems,
        SaleItem(
          item: item,
          quantity: 1,
          unitPrice: item.salePrice,
          selectedSubServices: selectedServices ?? [],
        ),
      ],
    );
    recalculateTotals();
  }

  void updateCustomerWallet({required bool useWallet}) {
    state = state.copyWith(useWallet: useWallet);
  }

  double getItemQuantity(String itemId) {
    final item = state.saleItems.firstWhere(
      (item) => item.item.itemId == itemId,
      orElse: () => SaleItem(item: Item.empty(), quantity: 0, unitPrice: 0),
    );
    return item.quantity;
  }

  void setSaleNote(String note) {
    state = state.copyWith(notes: note);
  }

  // void updateItemQuantity(String itemId, double quantity) {
  //   final updatedItems = state.saleItems.map((item) {
  //     if (item.item.itemId == itemId) {
  //       return item.copyWith(quantity: quantity);
  //     }
  //     return item;
  //   }).toList();

  //   state = state.copyWith(saleItems: updatedItems);
  //   recalculateTotals();
  // }

  void updateItemQuantity(String itemId, double quantity,
      {List<SubService>? selectedSubServices}) {
    final isService = selectedSubServices != null;
    final subServiceIds =
        (selectedSubServices ?? []).map((e) => e.subServiceId).toSet();

    final updatedItems = state.saleItems.map((item) {
      final sameId = item.item.itemId == itemId;
      if (!isService) {
        return sameId ? item.copyWith(quantity: quantity) : item;
      }
      final itemSubServiceIds =
          item.selectedSubServices.map((e) => e.subServiceId).toSet();
      return (sameId && setEquals(subServiceIds, itemSubServiceIds))
          ? item.copyWith(quantity: quantity)
          : item;
    }).toList();

    state = state.copyWith(saleItems: updatedItems);
    recalculateTotals();
  }

  void updateItemUnitPrice(String itemId, double unitPrice) {
    final updatedItems = state.saleItems.map((item) {
      if (item.item.itemId == itemId) {
        return item.copyWith(unitPrice: unitPrice);
      }
      return item;
    }).toList();

    state = state.copyWith(saleItems: updatedItems);
    recalculateTotals();
  }

  void removeItem(String itemId) {
    state = state.copyWith(
      saleItems: state.saleItems.where((item) => item.item.itemId != itemId).toList(),
    );
    recalculateTotals();
  }

  void updatePaymentDetails(Map<PaymentMode, String> value) {
    state = state.copyWith(paymentDetails: value);
  }

  void resetForm() {
    state = state.copyWith(
      customer: null,
      shipping: 0,
      discountPercent: 0,
      discountAmount: 0,
      saleItems: [],
      employee: ref.read(authNotifierProvider).user,
      orderMode: ref.read(businessNotifierProvider)?.businessType ==
          BusinessType.foodAndBeverage,
      paymentDetails: const {},
      useWallet: true,
      customFieldValues: const {},
      status: SalesStatus.initial,
      error: '',
    );

    // Refresh the controllers if needed
    state.pagingController?.refresh();
    state.categoryPagingController?.refresh();
  }

  // Total Calculation
  void recalculateTotals() {
    state = state.copyWith(status: SalesStatus.calculating);
    state = state.copyWith(status: SalesStatus.initial);
  }

  Future<void> validateSaleData(Map<String, dynamic> formData) async {
    try {
      final business = ref.read(businessNotifierProvider);
      // Check if walk-in customer is allowed
      if (state.customer == null && !(business?.allowWalkinCustomer ?? false)) {
        throw AppException(
          formData['order_mode'] == true
              ? AppRouter.l10n.customerRequiredOrder
              : AppRouter.l10n.walkinCustomerIsNotAllowed,
        );
      }

      if (state.saleItems.isEmpty) {
        throw AppException(AppRouter.l10n.pleaseSelectAtLeastOneItem);
      }

      if (state.saleItems.any((e) => e.quantity == 0 || e.unitPrice == 0)) {
        throw AppException(AppRouter.l10n.quantityOrUnitPriceCannotBeZero);
      }
    } catch (e) {
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  // Method to get current cart data as a map for holding
  Map<String, dynamic> _getCurrentCartDataMap() {
    return {
      'held_time': DateTime.now().toIso8601String(),
      'saleItems': state.saleItems.map((si) => si.toJson()).toList(), // Assumes SaleItem has toJson
      'customer': state.customer?.toJson(), // Assumes Customer has toJson
      'employee': state.employee?.toJson(), // Assumes EmployeeModel has toJson
      'shipping': state.shipping,
      'discountPercent': state.discountPercent,
      'discountAmount': state.discountAmount,
      'orderMode': state.orderMode,
      'paymentDetails': state.paymentDetails, // Ensure PaymentMode can be serialized if complex
      'customFieldValues': state.customFieldValues,
      'useWallet': state.useWallet,
      // Add any other relevant fields from SalesState that need to be preserved
    };
  }

  void recallCart(Map<String, dynamic> recalledCartData, {bool autoHoldCurrentCart = true}) {
    if (autoHoldCurrentCart && state.saleItems.isNotEmpty) {
      final currentCartToHold = _getCurrentCartDataMap();
      // Avoid adding if it's essentially the same cart being re-held immediately (e.g. by timestamp)
      // This basic check might need refinement based on how you identify unique carts for holding.
      if (state.heldCarts.every((hc) => hc['held_time'] != currentCartToHold['held_time'])) {
        holdCart(currentCartToHold, isRecallInProgress: true); // Pass a flag to avoid immediate persistence if needed
      }
    }

    try {
      final itemMaps = recalledCartData['saleItems'] as List<dynamic>? ?? [];
      final recalledSaleItems = itemMaps.map((itemMap) {
        // IMPORTANT: Assumes SaleItem.fromJson exists and correctly deserializes
        // Item within SaleItem also needs fromJson
        return SaleItem.fromJson(itemMap as Map<String, dynamic>);
      }).toList();

      Customer? recalledCustomer;
      if (recalledCartData['customer'] != null) {
        // Assumes Customer.fromJson exists
        recalledCustomer = Customer.fromJson(recalledCartData['customer'] as Map<String, dynamic>);
      }

      EmployeeModel? recalledEmployee;
      if (recalledCartData['employee'] != null) {
        // Assumes EmployeeModel.fromJson exists
        recalledEmployee = EmployeeModel.fromJson(recalledCartData['employee'] as Map<String, dynamic>);
      }

      final recalledShipping = (recalledCartData['shipping'] as num?)?.toDouble() ?? 0.0;
      final recalledDiscountPercent = (recalledCartData['discount-percent'] as num?)?.toDouble() ?? 0.0;
      final recalledDiscountAmount = (recalledCartData['discount-amount'] as num?)?.toDouble() ?? 0.0;
      final recalledOrderMode = recalledCartData['orderMode'] as bool? ?? false;
      final recalledPaymentDetails = (recalledCartData['paymentDetails'] as Map<dynamic, dynamic>?)?.map(
            (k, v) => MapEntry(
              PaymentMode.values.firstWhere((pm) => pm.name == k.toString(), orElse: () => PaymentMode.cash),
              v.toString(),
            ),
          ) ??
          {};
      final recalledCustomFieldValues = (recalledCartData['customFieldValues'] as Map<String, dynamic>?) ?? {};
      final recalledUseWallet = recalledCartData['useWallet'] as bool? ?? true;

      state = state.copyWith(
        saleItems: recalledSaleItems,
        customer: recalledCustomer,
        employee: recalledEmployee ??
            ref.read(authNotifierProvider).user, // Fallback to current user if no employee in held cart
        shipping: recalledShipping,
        discountPercent: recalledDiscountPercent,
        discountAmount: recalledDiscountAmount,
        orderMode: recalledOrderMode,
        paymentDetails: recalledPaymentDetails,
        customFieldValues: recalledCustomFieldValues,
        useWallet: recalledUseWallet,
        status: SalesStatus.initial, // Reset status
        error: '',
      );

      // Remove the recalled cart from the held list using its unique identifier (held_time)
      final recalledCartTime = recalledCartData['held_time'] as String;
      deleteCartByTime(recalledCartTime);

      recalculateTotals();
    } catch (e, s) {
      // Log error for debugging
      debugPrint('Error recalling cart: $e\n$s');
      Alert.showSnackBar('Error recalling bill: $e', type: SnackBarType.error);
      // Optionally, restore previous state or handle error more gracefully
    }
  }

  void holdCart(Map<String, dynamic> cartData, {bool isRecallInProgress = false}) {
    // `cartData` is already the map prepared by the UI or _getCurrentCartDataMap
    // Ensure it has a unique held_time if not already present (though it should be)
    final cartWithTime =
        cartData.containsKey('held_time') ? cartData : {...cartData, 'held_time': DateTime.now().toIso8601String()};

    if ((cartWithTime['saleItems'] as List?)?.isNotEmpty ?? false) {
      state = state.copyWith(
        heldCarts: [...state.heldCarts, cartWithTime],
      );
      // if (!isRecallInProgress) {
      //   _persistHeldCarts(); // Persist if this hold is not part of a recall operation
      // }
    } else {
      // Optionally, notify user if trying to hold an empty cart from internal logic
    }
  }

  // void _persistHeldCarts() {
  //   // Implement persistence logic here, e.g., using SharedPreferences
  //   // final serializedCarts = state.heldCarts.map((cart) => jsonEncode(cart)).toList();
  //   // ref.read(sharedPreferencesProvider).setStringList('held_carts', serializedCarts);
  // }

  // List<Map<String, dynamic>> _loadHeldCartsFromPersistence() {
  //   // Implement loading logic here
  //   // final serializedCarts = ref.read(sharedPreferencesProvider).getStringList('held_carts');
  //   // if (serializedCarts == null) return [];
  //   // return serializedCarts.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();
  //   return []; // Default to empty if no persistence
  // }

  void deleteCart(Map<String, dynamic> cartToDelete) {
    final timeOfCartToDelete = cartToDelete['held_time'] as String?;
    if (timeOfCartToDelete != null) {
      deleteCartByTime(timeOfCartToDelete);
    }
  }

  void deleteCartByTime(String heldTime) {
    state = state.copyWith(
      heldCarts: state.heldCarts.where((cart) => cart['held_time'] != heldTime).toList(),
    );
    // _persistHeldCarts(); // Update persistence
  }

  Future<SaleView> createSaleTransaction(Map<PaymentMode, String> paymentDetails) async {
    state = state.copyWith(paymentDetails: paymentDetails);
    final paidAmount =
        state.paymentDetails.values.fold<double>(0, (sum, element) => sum + (double.tryParse(element) ?? 0));
    if (!state.useWallet && !(paidAmount == state.grandTotal)) {
      Alert.showSnackBar('Cant have due or balance without using customer wallet', type: SnackBarType.error);
      throw Exception('Cant have due or balance without using customer wallet');
    }
    try {
      state = state.copyWith(status: SalesStatus.loading);
      // log(
      //   JsonEncoder.withIndent(' ' * 2).convert(
      //     state.saleItems[0]
      //         .toCreateModel()
      //         .toJson(),
      //   ),
      // );
      final sale = await _saleRepository.createSaleTransaction(
        SalePageData(
          shipping: state.shipping,
          discountPercent: state.discountPercent,
          discountAmount: state.discountAmount,
          items: state.saleItems,
          orderMode: state.orderMode,
          paymentDetails: paymentDetails,
          notes: state.notes,
          customer: state.customer,
          businessId: ref.read(businessNotifierProvider)!.businessId,
          employee: state.employee ?? ref.read(authNotifierProvider).user!,
          table: state.selectedTable,
        ),
      );
      state = state.copyWith(status: SalesStatus.success);
      Alert.showSnackBar(AppRouter.l10n.saleTransactionCreatedSuccessfully, type: SnackBarType.success);
      ref.read(customerNotifierProvider.notifier).setFilter();
      ref.read(orderListNotifierProvider.notifier).setFilter();
      ref.read(saleListNotifierProvider.notifier).setFilter();

      resetForm();
      return sale;
    } catch (e) {
      state = state.copyWith(status: SalesStatus.error);
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  void updateItemQuantityInMobile(
    String itemId,
    double quantity,
    double salePrice, {
    List<SubService>? selectedSubServices,
  }) {
    // Check if the item is already in the cart
    final existingItemIndex = state.saleItems.indexWhere((item) => item.item.itemId == itemId);

    if (existingItemIndex != -1) {
      // If the item exists, update the quantity
      if (quantity <= 0) {
        // If quantity is zero or less, remove the item from the cart
        removeItem(itemId);
      } else {
        // Otherwise, update the quantity
        final updatedItems = state.saleItems.map((item) {
          if (item.item.itemId == itemId) {
            return item.copyWith(quantity: quantity, unitPrice: salePrice);
          }
          return item;
        }).toList();

        state = state.copyWith(saleItems: updatedItems);
        recalculateTotals();
      }
    } else {
      // If the item does not exist in the cart, add it if the quantity is greater than zero
      if (quantity > 0) {
        final itemToAdd = state.pagingController?.itemList?.firstWhere((e) => e.itemId == itemId);
        if (itemToAdd != null) {
          state = state.copyWith(
            saleItems: [
              ...state.saleItems,
              SaleItem(
                item: itemToAdd,
                quantity: quantity,
                unitPrice: salePrice,
                selectedSubServices: selectedSubServices ?? [],
              ),
            ],
          );
          recalculateTotals();
        }
      }
    }
  }

  Future<void> settleSale({
    required SaleView sale,
    required double amount,
    required PaymentMode mode,
    required DateTime date,
  }) async {
    try {
      state = state.copyWith(status: SalesStatus.loading);
      await _saleRepository.settleSale(
        amount: amount,
        mode: mode,
        date: date,
        saleId: sale.saleId,
        customerId: sale.customerId!,
      );
      ref
        ..invalidate(saleAuditsProvider(sale.saleId))
        ..invalidate(saleProvider(sale.saleId))
        ..invalidate(customerProvider(sale.customerId))
        ..read(
          partyDetailsNotifierProvider(
            TransactionParty.customer,
            sale.customerId!,
          ).notifier,
        ).getSales(pageNumber: 1)
        ..read(
          partyDetailsNotifierProvider(
            TransactionParty.customer,
            sale.customerId!,
          ).notifier,
        ).getPartyDetails()
        ..read(ledgerNotifierProvider.notifier).getParties(pageNumber: 1)
        ..read(ledgerNotifierProvider.notifier).getLedger()
        ..read(customerNotifierProvider.notifier).setFilter()
        ..read(saleListNotifierProvider.notifier).setFilter();

      state = state.copyWith(status: SalesStatus.success);
    } catch (e) {
      state = state.copyWith(status: SalesStatus.error);
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }
}
