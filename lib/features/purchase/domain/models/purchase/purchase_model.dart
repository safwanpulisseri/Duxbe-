import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/features/purchase/purchase.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:file_picker/file_picker.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'purchase_model.freezed.dart';
part 'purchase_model.g.dart';

@freezed
class PurchasePageData with _$PurchasePageData {
  factory PurchasePageData({
    @JsonKey(name: 'purchase_invoice') required String purchaseInvoice,
    @JsonKey(name: 'supplier') required Supplier supplier,
    @JsonKey(name: 'shipping') required double shipping,
    @JsonKey(name: 'discount-percent') required double discountPercent,
    @JsonKey(name: 'discount-amount') required double discountAmount,
    @JsonKey(name: 'purchase_items') required List<PurchaseItem> items,
    @Default({}) @JsonKey(name: 'payment_details') Map<PaymentMode, String> paymentDetails,
    @JsonKey(includeFromJson: false) PlatformFile? file,
    @JsonKey(name: 'attachment') String? attachment,
    @JsonKey(name: 'business_id') String? businessId,
  }) = _PurchasePageData;
  PurchasePageData._();

  factory PurchasePageData.fromJson(Map<String, dynamic> json) => _$PurchasePageDataFromJson(json);

  @JsonKey(includeToJson: true, name: 'paid_amount')
  double get paidAmount => paymentDetails.values.fold<double>(0, (sum, value) => sum + (double.tryParse(value) ?? 0));
  @JsonKey(includeToJson: true, name: 'balance')
  double get balance => grandTotal - paidAmount;
  @JsonKey(includeToJson: true, name: 'subtotal')
  double get subtotal => items.fold<double>(0, (sum, item) => sum + (item.quantity * item.unitPrice));
  @JsonKey(includeToJson: true, name: 'grand_total')
  double get grandTotal => subtotal + shipping - discountAmount;

  PurchaseCreateModel toCreateModel() => PurchaseCreateModel(
        purchaseInvoice: purchaseInvoice,
        supplierId: this.supplier.supplierId!,
        shipping: shipping,
        discountPercent: discountPercent,
        discountAmount: discountAmount,
        items: items.map((item) => {'item_id': item.item.itemId, 'quantity': item.quantity, 'unit_price': item.unitPrice}).toList(),
        paymentDetails: paymentDetails.map((key, value) => MapEntry(key.name, double.tryParse(value) ?? 0)),
        attachment: attachment,
        businessId: businessId,
      );
}

@freezed
class PurchaseCreateModel with _$PurchaseCreateModel {
  factory PurchaseCreateModel({
    @JsonKey(name: 'purchase_invoice') required String purchaseInvoice,
    @JsonKey(name: 'supplier_id') required String supplierId,
    @JsonKey(name: 'shipping') required double shipping,
    @JsonKey(name: 'discount_percent') required double discountPercent,
    @JsonKey(name: 'discount_amount') required double discountAmount,
    @JsonKey(name: 'purchase_items') required List<Map<String, dynamic>> items,
    @Default({}) @JsonKey(name: 'payment_details') Map<String, double> paymentDetails,
    @JsonKey(name: 'attachment') String? attachment,
    @JsonKey(name: 'business_id') String? businessId,
  }) = _PurchaseCreateModel;
  PurchaseCreateModel._();

  factory PurchaseCreateModel.fromJson(Map<String, dynamic> json) => _$PurchaseCreateModelFromJson(json);

  @JsonKey(includeToJson: true, name: 'paid_amount')
  double get paidAmount => paymentDetails.values.fold<double>(0, (sum, value) => sum + value);
  @JsonKey(includeToJson: true, name: 'balance')
  double get balance => grandTotal - paidAmount;
  @JsonKey(includeToJson: true, name: 'subtotal')
  double get subtotal => items.fold<double>(0, (sum, item) => sum + ((item['quantity'] as double) * (item['unit_price'] as double)));
  @JsonKey(includeToJson: true, name: 'grand_total')
  double get grandTotal => subtotal + shipping - discountAmount;
}

@freezed
class PurchaseItem with _$PurchaseItem {
  const factory PurchaseItem({
    @JsonKey(name: 'item') required Item item,
    @JsonKey(name: 'quantity') required double quantity,
    @JsonKey(name: 'unit-price') required double unitPrice,
  }) = _PurchaseItem;

  factory PurchaseItem.fromJson(Map<String, dynamic> json) => _$PurchaseItemFromJson(json);
}

@freezed
class PurchaseView with _$PurchaseView {
  const factory PurchaseView({
    @JsonKey(name: 'purchase_id') required String purchaseId,
    @JsonKey(name: 'invoice_no') required String invoiceNo,
    @JsonKey(name: 'purchase_invoice') required String purchaseInvoice,
    @JsonKey(name: 'supplier_id') required String supplierId,
    @JsonKey(name: 'purchase_date') required DateTime purchaseDate,
    @JsonKey(name: 'transaction_id') required String transactionId,
    @JsonKey(name: 'subtotal') required double subTotal,
    @JsonKey(name: 'discount_amount') required double discountAmount,
    @JsonKey(name: 'tax_amount') required double taxAmount,
    @JsonKey(name: 'shipping_charge') required double shippingCharge,
    @JsonKey(name: 'total_amount') required double totalAmount,
    @JsonKey(name: 'paid_amount') required double paidAmount,
    @JsonKey(name: 'due_amount') required double dueAmount,
    @JsonKey(name: 'business_id') required String businessId,
    @JsonKey(name: 'created_by') required String createdBy,
    @JsonKey(name: 'supplier') required Supplier supplier,
    @JsonKey(name: 'transaction') required Transaction transaction,
    @JsonKey(name: 'metadata') required Map<String, dynamic>? metadata,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'employee') required EmployeeModel employee,
    @Default([]) @JsonKey(name: 'transaction_entries') List<TransactionEntry> transactionEntries,
    @Default([]) @JsonKey(name: 'payments') List<Payment> payments,
    @Default([]) @JsonKey(name: 'purchase_items') List<PurchaseItemView> purchaseItems,
    @JsonKey(name: 'notes') String? notes,
    @JsonKey(name: 'attachment_url') String? attachmentURL,
  }) = _PurchaseView;

  factory PurchaseView.fromJson(Map<String, dynamic> json) => _$PurchaseViewFromJson(json);
}

@freezed
class PurchaseItemView with _$PurchaseItemView {
  const factory PurchaseItemView({
    @JsonKey(name: 'purchase_item_id') required String purchaseItemId,
    @JsonKey(name: 'purchase_id') required String purchaseId,
    @JsonKey(name: 'item_id') required String itemId,
    @JsonKey(name: 'item') required Item item,
    @JsonKey(name: 'quantity') required double quantity,
    @JsonKey(name: 'unit_price') required double unitPrice,
    @JsonKey(name: 'total_price') required double totalPrice,
  }) = _PurchaseItemView;

  factory PurchaseItemView.fromJson(Map<String, dynamic> json) => _$PurchaseItemViewFromJson(json);
}
