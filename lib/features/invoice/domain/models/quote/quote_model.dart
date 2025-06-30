import 'dart:convert';

import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/features/invoice/invoice.dart';
import 'package:duxbe/features/sale/sale.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'quote_model.freezed.dart';
part 'quote_model.g.dart';

enum QuoteFormStatus {
  draft,
  deleted,
  sent,
}

@freezed
class Quote with _$Quote {
  const factory Quote({
    @JsonKey(name: 'quote_id') String? quoteId,
    @JsonKey(name: 'business_id') String? businessId,
    @JsonKey(name: 'customer_id') String? customerId,
    @JsonKey(name: 'quote_code') String? quoteCode,
    @JsonKey(name: 'quote_status', fromJson: _quoteStatusFromJson) QuoteFormStatus? quoteStatus,
    @JsonKey(name: 'quote_date', fromJson: dateTimeFromString) DateTime? quoteDate,
    @JsonKey(name: 'valid_until_date', fromJson: dateTimeFromString) DateTime? validUntilDate,
    @JsonKey(name: 'amount', fromJson: parseDoubleSafe)
    double? amount, // Fields from quote_view, potentially derived if details_view is primary
    @JsonKey(readValue: _readCustomerNameValue) String? customerName,
    @JsonKey(readValue: _readGrandTotalValue, fromJson: parseDoubleSafe) double? grandTotal,
    @JsonKey(readValue: _readCreatedAtValue, fromJson: dateTimeFromString) DateTime? createdAt,
    @JsonKey(name: 'created_by') String? createdBy,
    @JsonKey(name: 'billing_address_id') String? billingAddressId,
    @JsonKey(name: 'shipping_address_id') String? shippingAddressId,
    @JsonKey(name: 'quote_notes') String? quoteNotes,
    @JsonKey(name: 'quote_terms_and_conditions') String? quoteTermsAndConditions,
    @JsonKey(name: 'tax_total', fromJson: parseDoubleSafe) double? taxTotal,
    @JsonKey(name: 'sub_total', fromJson: parseDoubleSafe) double? subTotal,
    @JsonKey(name: 'discount_amount', fromJson: parseDoubleSafe) double? discountAmount,
    @JsonKey(name: 'shipping_charges', fromJson: parseDoubleSafe) double? shippingCharges,
    BusinessInfo? business,
    Customer? customer,
    EmployeeInfo? employee,
    @JsonKey(name: 'billing_address_details') CustomerAddress? billingAddressDetails,
    @JsonKey(name: 'shipping_address_details') CustomerAddress? shippingAddressDetails,
    @JsonKey(name: 'quote_items') @Default([]) List<QuoteItem> quoteItems,
  }) = _Quote;

  factory Quote.fromJson(Map<String, dynamic> json) => _$QuoteFromJson(json);
}

@freezed
class BusinessInfo with _$BusinessInfo {
  const factory BusinessInfo({
    String? logo,
    String? name,
    String? state,
    String? format,
    @JsonKey(name: 'gst_in') String? gstIn,
    List<String>? images,
    @JsonKey(name: 'org_id') String? orgId,
    String? country,
    CurrencyInfo? currency,
    @JsonKey(name: 'fiscal_id') String? fiscalId,
    @JsonKey(name: 'time_zone') String? timeZone,
    @JsonKey(name: 'created_at', fromJson: dateTimeFromString) DateTime? createdAt,
    @JsonKey(name: 'created_by') String? createdBy,
    @JsonKey(name: 'store_name') String? storeName,
    @JsonKey(name: 'trade_name') String? tradeName,
    @JsonKey(name: 'business_id') String? businessId,
    @JsonKey(name: 'business_type') String? businessType,
    @JsonKey(name: 'contact_email') String? contactEmail,
    @JsonKey(name: 'contact_phone') String? contactPhone,
    @JsonKey(name: 'print_on_sale') bool? printOnSale,
    @JsonKey(name: 'last_active_at', fromJson: dateTimeFromString) DateTime? lastActiveAt,
    @JsonKey(name: 'contact_address') String? contactAddress,
    @JsonKey(name: 'is_gst_registered') bool? isGstRegistered,
    @JsonKey(name: 'print_on_purchase') bool? printOnPurchase,
    @JsonKey(name: 'gst_registered_date', fromJson: dateTimeFromString) DateTime? gstRegisteredDate,
    @JsonKey(name: 'legal_business_name') String? legalBusinessName,
    @JsonKey(name: 'subscription_status') String? subscriptionStatus,
    @JsonKey(name: 'allow_walkin_customer') bool? allowWalkinCustomer,
    @JsonKey(name: 'print_barcode_on_purchase') bool? printBarcodeOnPurchase,
    @JsonKey(name: 'allow_sales_when_outofstock') bool? allowSalesWhenOutofstock,
  }) = _BusinessInfo;

  factory BusinessInfo.fromJson(Map<String, dynamic> json) => _$BusinessInfoFromJson(json);
}

@freezed
class CurrencyInfo with _$CurrencyInfo {
  const factory CurrencyInfo({
    required String name,
    String? code,
    String? flag,
    @JsonKey(fromJson: parseIntSafe) int? number,
    String? symbol,
    @JsonKey(name: 'name_plural') String? namePlural,
    @JsonKey(name: 'country_code') List<String>? countryCode,
    @JsonKey(name: 'decimal_digits') int? decimalDigits,
    @JsonKey(name: 'symbol_on_left') bool? symbolOnLeft,
    @JsonKey(name: 'decimal_separator') String? decimalSeparator,
    @JsonKey(name: 'thousands_separator') String? thousandsSeparator,
    @JsonKey(name: 'space_between_amount_and_symbol') bool? spaceBetweenAmountAndSymbol,
  }) = _CurrencyInfo;

  factory CurrencyInfo.fromJson(Map<String, dynamic> json) => _$CurrencyInfoFromJson(json);
}

@freezed
class EmployeeInfo with _$EmployeeInfo {
  const factory EmployeeInfo({
    String? code,
    @JsonKey(name: 'name') String? name,
    String? role,
    String? email,
    String? image,
    String? phone,
    @JsonKey(name: 'org_id') String? orgId,
    @JsonKey(name: 'created_at', fromJson: dateTimeFromString) DateTime? createdAt,
    @JsonKey(name: 'business_id') String? businessId,
    @JsonKey(name: 'employee_id') String? employeeId,
    @JsonKey(name: 'business_ids') @Default([]) List<String> businessIds,
    @JsonKey(name: 'employee_roles') @Default([]) List<dynamic> employeeRoles, // or List<String> if always strings
    @JsonKey(name: 'employee_role_ids') @Default([]) List<String> employeeRoleIds,
  }) = _EmployeeInfo;

  factory EmployeeInfo.fromJson(Map<String, dynamic> json) => _$EmployeeInfoFromJson(json);
}

@freezed
class QuoteItem with _$QuoteItem {
  const factory QuoteItem({
    Item? item,
    @JsonKey(name: 'item_id') String? itemId,
    @JsonKey(fromJson: parseIntSafe) int? quantity,
    @JsonKey(name: 'created_at', fromJson: dateTimeFromString) DateTime? createdAt,
    @JsonKey(name: 'unit_price', fromJson: parseDoubleSafe) double? unitPrice,
    @JsonKey(name: 'updated_at', fromJson: dateTimeFromString) DateTime? updatedAt,
    @JsonKey(name: 'total_price', fromJson: parseDoubleSafe) double? totalPrice,
    @JsonKey(name: 'quote_item_id') String? quoteItemId,
    @JsonKey(name: 'invoice_item_id') String? invoiceItemId,
    @JsonKey(name: 'credit_note_item_id') String? creditNoteItemId,
  }) = _QuoteItem;

  factory QuoteItem.fromJson(Map<String, dynamic> json) => _$QuoteItemFromJson(json);
}

// @freezed
// class PreferredVendor with _$PreferredVendor {
//   const factory PreferredVendor({
//     String? name,
//     String? email,
//     String? phone,
//     @JsonKey(name: 'org_id') String? orgId,
//     String? address,
//     @JsonKey(name: 'created_at', fromJson: dateTimeFromString)
//     DateTime? createdAt,
//     @JsonKey(name: 'gst_number') String? gstNumber,
//     @JsonKey(name: 'business_id') required String businessId,
//     @JsonKey(name: 'supplier_id') required String supplierId,
//     @JsonKey(name: 'supplier_balance', fromJson: parseDoubleSafe)
//     double? supplierBalance,
//   }) = _PreferredVendor;

//   factory PreferredVendor.fromJson(Map<String, dynamic> json) =>
//       _$PreferredVendorFromJson(json);
// }

// Helper for parsing numbers that might be strings or actual numbers
double? parseDoubleSafe(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    if (value.isEmpty) return null;
    return double.tryParse(value);
  }
  return null;
}

int? parseIntSafe(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt(); // Allow double to int conversion
  if (value is String) {
    if (value.isEmpty) return null;
    return int.tryParse(value);
  }
  return null;
}

// Helper for parsing DateTime from String
DateTime? dateTimeFromString(String? dateString) {
  if (dateString == null || dateString.isEmpty) return null;
  try {
    return DateTime.parse(dateString);
  } catch (e) {
    print('Error parsing DateTime: $dateString, $e');
    return null;
  }
}

// Helper for Item.richText (which is a JSON string within the Item object)
List<Map<String, dynamic>> richTextFromJson(String? jsonString) {
  if (jsonString == null || jsonString.isEmpty) return [];
  try {
    final decoded = jsonDecode(jsonString) as List<dynamic>;
    return decoded.map((item) => item as Map<String, dynamic>).toList();
  } catch (e) {
    print('Error decoding rich_text: $e, String: $jsonString');
    return [];
  }
}

String? richTextToJson(List<Map<String, dynamic>>? data) {
  if (data == null || data.isEmpty) return null;
  return jsonEncode(data);
}

// ReadValue functions for aliased/derived fields
Object? _readCreatedAtValue(Map<dynamic, dynamic> json, String key) {
  return json['quote_created_at'] ?? json['created_at'];
}

Object? _readGrandTotalValue(Map<dynamic, dynamic> json, String key) {
  return json['grand_total'] ?? json['amount'];
}

Object? _readCustomerNameValue(Map<dynamic, dynamic> json, String key) {
  return json['customer_name'] ?? (json['customer'] as Map?)?['name'];
}

// Add this helper function for quote status conversion
QuoteFormStatus? _quoteStatusFromJson(String? status) {
  if (status == null) return null;
  return QuoteFormStatus.values.firstWhere(
    (e) => e.toString().split('.').last.toLowerCase() == status.toLowerCase(),
    orElse: () => QuoteFormStatus.draft,
  );
}
