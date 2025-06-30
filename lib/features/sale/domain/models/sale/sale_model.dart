import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/features/invoice/invoice.dart';
import 'package:duxbe/features/reservations/reservations.dart';
import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sale_model.freezed.dart';
part 'sale_model.g.dart';

@freezed
class Sale with _$Sale {
  const factory Sale({
    @JsonKey(name: 'sale_id', includeIfNull: false) String? saleId,
  }) = _Sale;

  factory Sale.fromJson(Map<String, dynamic> json) => _$SaleFromJson(json);
}

@unfreezed
class SalePageData with _$SalePageData {
  factory SalePageData({
    @JsonKey(name: 'shipping') required double shipping,
    @JsonKey(name: 'discount-percent') required double discountPercent,
    @JsonKey(name: 'discount-amount') required double discountAmount,
    @JsonKey(name: 'sale_items') required List<SaleItem> items,
    @JsonKey(name: 'order_mode') required bool orderMode,
    @JsonKey(name: 'employee') required EmployeeModel employee,
    @JsonKey(name: 'customer') Customer? customer,
    @Default({})
    @JsonKey(name: 'payment_details')
    Map<PaymentMode, String> paymentDetails,
    @JsonKey(name: 'attachment') String? attachment,
    @JsonKey(name: 'notes') String? notes,
    @JsonKey(name: 'business_id') String? businessId,
    @JsonKey(name: 'table') Table? table,
    @Default([])
    @JsonKey(name: 'custom_fields')
    List<Map<String, dynamic>> customFields,
  }) = _SalePageData;
  SalePageData._();

  factory SalePageData.fromJson(Map<String, dynamic> json) =>
      _$SalePageDataFromJson(json);

  @JsonKey(includeToJson: true, name: 'subtotal')
  double get subtotal =>
      items.fold<double>(0, (sum, item) => sum + item.itemTotal);

  @JsonKey(includeToJson: true, name: 'tax_total')
  double get taxTotal =>
      items.fold<double>(0, (sum, item) => sum + item.itemTaxTotal);

  @JsonKey(includeToJson: true, name: 'grand_total')
  double get grandTotal => subtotal + shipping - discountAmount;

  @JsonKey(includeToJson: true, name: 'paid_amount')
  double get paidAmount => paymentDetails.values
      .fold<double>(0, (sum, value) => sum + (double.tryParse(value) ?? 0));

  @JsonKey(includeToJson: true, name: 'balance')
  double get balance => grandTotal - paidAmount;

  SaleCreateModel toCreateModel() => SaleCreateModel(
        customerId: this.customer?.customerId,
        shipping: shipping,
        discountPercent: discountPercent,
        discountAmount: discountAmount,
        orderMode: orderMode,
        notes: notes,
        items: items
            .map(
              (item) => {
                'item_id': item.item.itemId,
                'quantity': item.quantity,
                'unit_price': item.unitPrice,
                'item_total': item.itemTotal,
                'item_tax_total': item.itemTaxTotal,
                'note': item.note,
                'subservices': item.selectedSubServices
                    .map(
                      (service) => {
                        'sub_service_id': service.subServiceId,
                        'additional_price': service.additionalPrice,
                        'quantity': service.quantity,
                      },
                    )
                    .toList(),
              },
            )
            .toList(),
        paymentDetails: paymentDetails.map(
            (key, value) => MapEntry(key.name, double.tryParse(value) ?? 0)),
        attachment: attachment,
        businessId: businessId,
        customFields: customFields,
        employeeId: employee.employeeId,
        tableId: table?.tableId,
      );
}

@freezed
class SaleCreateModel with _$SaleCreateModel {
  factory SaleCreateModel({
    @JsonKey(name: 'customer_id') required String? customerId,
    @JsonKey(name: 'table_id') required String? tableId,
    @JsonKey(name: 'shipping') required double shipping,
    @JsonKey(name: 'discount_percent') required double discountPercent,
    @JsonKey(name: 'discount_amount') required double discountAmount,
    @JsonKey(name: 'sale_items') required List<Map<String, dynamic>> items,
    @JsonKey(name: 'order_mode') required bool orderMode,
    @JsonKey(name: 'employee_id') required String employeeId,
    @Default({})
    @JsonKey(name: 'payment_details')
    Map<String, double> paymentDetails,
    @JsonKey(name: 'attachment') String? attachment,
    @JsonKey(name: 'business_id') String? businessId,
    @JsonKey(name: 'notes') String? notes,
    @Default([])
    @JsonKey(name: 'custom_fields')
    List<Map<String, dynamic>> customFields,
  }) = _SaleCreateModel;
  SaleCreateModel._();

  factory SaleCreateModel.fromJson(Map<String, dynamic> json) =>
      _$SaleCreateModelFromJson(json);

  @JsonKey(includeToJson: true, name: 'paid_amount')
  double get paidAmount =>
      paymentDetails.values.fold<double>(0, (sum, value) => sum + value);

  @JsonKey(includeToJson: true, name: 'balance')
  double get balance => grandTotal - paidAmount;

  @JsonKey(includeToJson: true, name: 'subtotal')
  double get subtotal => items.fold<double>(
      0, (sum, item) => sum + (item['item_total'] as double));

  @JsonKey(includeToJson: true, name: 'tax_total')
  double get taxTotal => items.fold<double>(
      0, (sum, item) => sum + (item['item_tax_total'] as double));

  @JsonKey(includeToJson: true, name: 'grand_total')
  double get grandTotal => subtotal + shipping + taxTotal - discountAmount;
}

@unfreezed
class SaleItem with _$SaleItem {
  @JsonSerializable(explicitToJson: true)
  factory SaleItem({
    @JsonKey(name: 'item') required Item item,
    @JsonKey(name: 'quantity') required double quantity,
    @JsonKey(name: 'unit-price') required double unitPrice,
    @Default('')
    @JsonKey(name: 'note', includeFromJson: true,includeIfNull: false,)
    String note,
    @Default([])
    @JsonKey(
      name: 'selected_sub_services',
      includeIfNull: false,
      includeFromJson: true,
    )
    List<SubService> selectedSubServices,
  }) = _SaleItem;

  const SaleItem._();
  factory SaleItem.fromJson(Map<String, dynamic> json) =>
      _$SaleItemFromJson(json);

  double get itemTaxTotal {
    if (this.item.tax == null) return 0;
    // Calculate total amount including base price and sub-services
    final totalAmount = quantity *
        (unitPrice +
            selectedSubServices.fold<double>(
              0,
              (sum, e) => sum + e.additionalPrice,
            ));
    if (this.item.isTaxInclusive) {
      // For inclusive tax: tax = total * (rate / (100 + rate))
      return totalAmount * (this.item.tax!.rate / (100 + this.item.tax!.rate));
    } else {
      // For exclusive tax: tax = total * (rate / 100)
      return totalAmount * (this.item.tax!.rate / 100);
    }
  }

  double get itemTotal {
    final totalAmount = quantity *
        (unitPrice +
            selectedSubServices.fold<double>(
              0,
              (sum, e) => sum + e.additionalPrice,
            ));
    return totalAmount + (this.item.isTaxInclusive ? 0 : itemTaxTotal);
  }
}

@freezed
class SaleView with _$SaleView {
  const factory SaleView({
    @JsonKey(name: 'sale_id') required String saleId,
    @JsonKey(name: 'sale_invoice') required String saleInvoice,
    @JsonKey(name: 'customer_id') required String? customerId,
    @JsonKey(name: 'sale_date') required DateTime saleDate,
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
    @JsonKey(name: 'status_id') required String? statusId,
    @JsonKey(name: 'customer') required Customer? customer,
    @JsonKey(name: 'status') required Status? status,
    @JsonKey(name: 'transaction') required Transaction transaction,
    @JsonKey(name: 'metadata') required Map<String, dynamic>? metadata,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'employee') EmployeeModel? employee,
    @Default([])
    @JsonKey(name: 'transaction_entries')
    List<TransactionEntry> transactionEntries,
    @Default([]) @JsonKey(name: 'payments') List<Payment> payments,
    @Default([]) @JsonKey(name: 'sale_items') List<SaleItemView> saleItems,
    @JsonKey(name: 'notes') String? notes,
    @JsonKey(name: 'platform') String? orderSource,
    @JsonKey(name: 'attachment_url') String? attachmentURL,
    @JsonKey(name: 'billing_address') CustomerAddress? billingAddress,
    @JsonKey(name: 'shipping_address') CustomerAddress? shippingAddress,
    @JsonKey(name: 'table') Table? table,
  }) = _SaleView;

  factory SaleView.fromJson(Map<String, dynamic> json) =>
      _$SaleViewFromJson(json);
}

@freezed
class SaleItemView with _$SaleItemView {
  const factory SaleItemView({
    @JsonKey(name: 'sale_item_id') required String saleItemId,
    @JsonKey(name: 'item_id') required String itemId,
    @JsonKey(name: 'item') required Item item,
    @JsonKey(name: 'quantity') required double quantity,
    @JsonKey(name: 'unit_price') required double unitPrice,
    @JsonKey(name: 'total_price') required double totalPrice,
    @JsonKey(name: 'note')  String? saleItemNote,
    @Default([])
    @JsonKey(name: 'subservices')
    List<SaleServiceView> subServices,
  }) = _SaleItemView;

  factory SaleItemView.fromJson(Map<String, dynamic> json) =>
      _$SaleItemViewFromJson(json);
}

@freezed
class SaleServiceView with _$SaleServiceView {
  const factory SaleServiceView({
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'sale_item_subservice_id')
    required String saleItemSubserviceId,
    @JsonKey(name: 'sub_service_id') required String subServiceId,
    @JsonKey(name: 'additional_price') required double additionalPrice,
    @JsonKey(name: 'quantity') required double quantity,
    @JsonKey(name: 'total_additional_price')
    required double totalAdditionalPrice,
  }) = _SaleServiceView;

  factory SaleServiceView.fromJson(Map<String, dynamic> json) =>
      _$SaleServiceViewFromJson(json);
}

@freezed
class Status with _$Status {
  const factory Status({
    @JsonKey(name: 'status_id') required String statusId,
    @JsonKey(name: 'business_id') required String businessId,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'sequence_order') required int sequenceOrder,
    @JsonKey(name: 'moving_order') int? movingOrder,
  }) = _Status;

  factory Status.fromJson(Map<String, dynamic> json) => _$StatusFromJson(json);
}
