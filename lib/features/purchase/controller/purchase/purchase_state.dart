part of 'purchase_notifier.dart';

enum PurchaseStatus { initial, loading, success, error, calculating }

@freezed
class PurchaseState with _$PurchaseState {
  factory PurchaseState({
    @Default(PurchaseStatus.initial) PurchaseStatus status,
    PagingController<int, Item>? pagingController,
    @Default('') String query,
    @Default(10) int pageSize,
    @Default([]) List<CustomField> customFields,
    @Default('') String error,
    @Default(1) int pageNumber,
    @Default('') String purchaseInvoice,
    Supplier? supplier,
    @Default(0.0) double shipping,
    @Default(0.0) double discountPercent,
    @Default(0.0) double discountAmount,
    @Default([]) List<PurchaseItem> purchaseItems,
    @Default({}) Map<PaymentMode, String> paymentDetails,
    PlatformFile? file,
    @Default(true) bool useWallet,
  }) = _PurchaseState;
  const PurchaseState._();

  factory PurchaseState.initial() => PurchaseState();

  // Getters for totals
  double get subtotal => purchaseItems.fold(0, (sum, item) => sum + (item.quantity * item.unitPrice));
  double get grandTotal => subtotal + shipping - discountAmount;

  bool get isLoading => status == PurchaseStatus.loading;
}
