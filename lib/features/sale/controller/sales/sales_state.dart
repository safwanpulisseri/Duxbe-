part of 'sales_notifier.dart';

enum SalesStatus {
  initial,
  loading,
  success,
  error,
  calculating,
}

@freezed
class SalesState with _$SalesState {
  const factory SalesState({
    @Default(SalesStatus.initial) SalesStatus status,
    PagingController<int, Item>? pagingController,
    PagingController<int, ItemCategory>? categoryPagingController,
    @Default([]) List<CustomField> customFields,
    @Default('') String query,
    @Default(10) int pageSize,
    @Default('') String error,
    @Default(1) int pageNumber,
    @Default([]) List<Map<String, dynamic>> heldCarts,
    @Default([]) List<ItemCategory> categories,
    @Default([]) List<ItemCategory> selectedCategories,
    @Default(ItemType.goods) ItemType selectedItemType,
    Customer? customer,
    Table? selectedTable,
    @Default(0.0) double shipping,
    @Default(0.0) double discountPercent,
    @Default(0.0) double discountAmount,
    @Default(false) bool orderMode,
    EmployeeModel? employee,
    String? notes,
    @Default([]) List<SaleItem> saleItems,
    @Default({}) Map<PaymentMode, String> paymentDetails,
    @Default({}) Map<String, dynamic> customFieldValues,
    @Default(true) bool useWallet,
  }) = _SalesState;

  factory SalesState.initial() => const SalesState();
  const SalesState._();

  bool get isLoading => status == SalesStatus.loading;

  double get subtotal => saleItems.fold(
        0,
        (sum, item) => sum + item.itemTotal,
      );

  double get taxTotal {
    return saleItems.fold(
      0,
      (sum, item) => sum + item.itemTaxTotal,
    );
  }

  double get grandTotal => subtotal + shipping - discountAmount;
}
