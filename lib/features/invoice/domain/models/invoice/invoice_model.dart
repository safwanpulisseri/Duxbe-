import 'package:duxbe/features/invoice/domain/models/customer_address/customer_address_model.dart';
import 'package:duxbe/features/invoice/domain/models/quote/quote_model.dart';
import 'package:duxbe/features/sale/sale.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'invoice_model.freezed.dart';
part 'invoice_model.g.dart';

enum InvoiceFormStatus { draft, paid, deleted, sent, overdue }
// This model is designed to be flexible enough for both invoice_view and invoice_details_view

@freezed
class Invoice with _$Invoice {
  const factory Invoice({
    // --- Fields from invoices table (present in both views) ---
    @JsonKey(name: 'business_id') String? businessId,
    @JsonKey(name: 'customer_id') String? customerId,
    @JsonKey(name: 'invoice_id') String? invoiceId,
    @JsonKey(name: 'invoice_code') String? invoiceCode,
    @JsonKey(readValue: _readGrandTotalValue, fromJson: parseDoubleSafe) double? amount, // Aliased in the simple view
    @JsonKey(name: 'invoice_date') DateTime? invoiceDate,
    @JsonKey(name: 'due_date') DateTime? dueDate,
    @JsonKey(name: 'quote_id') String? quoteId,

    // --- Fields with aliased names in the views ---
    @JsonKey(readValue: _dateTimeFromAny, fromJson: dateTimeFromString) DateTime? createdAt,
    @JsonKey(name: 'invoice_status', fromJson: _quoteStatusFromJson) InvoiceFormStatus? status,
    @JsonKey(name: 'invoice_notes') String? notes,
    @JsonKey(name: 'invoice_terms_and_conditions') String? termsAndConditions,

    // --- Fields from invoices table (mostly in details_view) ---
    @JsonKey(name: 'created_by') String? createdBy,
    @JsonKey(name: 'tax_total') double? taxTotal,
    @JsonKey(name: 'sub_total') double? subTotal,
    @JsonKey(name: 'discount_amount') double? discountAmount,
    @JsonKey(name: 'shipping_charges') double? shippingCharges,
    @JsonKey(name: 'credit_applied') double? creditApplied,
    @JsonKey(name: 'amount_paid') double? amountPaid,
    @JsonKey(name: 'balance_due') double? balanceDue,

    // --- Nested Objects (only in invoice_details_view) ---
    @JsonKey(name: 'billing_address_details') CustomerAddress? billingAddress,
    @JsonKey(name: 'shipping_address_details') CustomerAddress? shippingAddress,
    BusinessInfo? business,
    Customer? customer,
    EmployeeInfo? employee,

    // The list of items, with corrected type and JSON key
    @JsonKey(name: 'invoice_items') @Default([]) List<QuoteItem> invoiceItems,

    // --- Simple fields (only in invoice_view) ---
    @JsonKey(name: 'customer_name') String? customerName,
  }) = _Invoice;

  factory Invoice.fromJson(Map<String, dynamic> json) => _$InvoiceFromJson(json);
}

// Helper functions to handle parsing DateTime from either `invoice_created_at` or `created_at`
Object? _dateTimeFromAny(Map<dynamic, dynamic> json, String key) {
  return json['invoice_created_at'] ?? json['created_at'];
}

Object? _readGrandTotalValue(Map<dynamic, dynamic> json, String key) {
  return json['grand_total'] ?? json['amount'];
}

String _dateTimeToIso(DateTime dateTime) => dateTime.toIso8601String();
InvoiceFormStatus? _quoteStatusFromJson(String? status) {
  if (status == null) return null;
  return InvoiceFormStatus.values.firstWhere(
    (e) => e.toString().split('.').last.toLowerCase() == status.toLowerCase(),
    orElse: () => InvoiceFormStatus.draft,
  );
}
