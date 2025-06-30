import 'package:duxbe/features/purchase/purchase.dart';
import 'package:duxbe/features/sale/sale.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sale_return_model.freezed.dart';
part 'sale_return_model.g.dart';

@freezed
class SaleReturn with _$SaleReturn {
  const factory SaleReturn({
    @JsonKey(name: 'return_id') required String returnId,
    @JsonKey(name: 'sale_id') required String saleId,
    @JsonKey(name: 'return_invoice') required String returnInvoice,
    @JsonKey(name: 'return_date') required DateTime returnDate,
    @JsonKey(name: 'return_amount') required double returnAmount,
    @JsonKey(name: 'transaction_id') required String transactionId,
    @JsonKey(name: 'business_id') required String businessId,
    @JsonKey(name: 'created_by') required String createdBy,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'sale_invoice') required String saleInvoice,
    @JsonKey(name: 'sale_date') required DateTime saleDate,
    @JsonKey(name: 'original_sale_amount') required double originalSaleAmount,
    @JsonKey(name: 'transaction_reference') required String transactionReference,
    @JsonKey(name: 'transaction_status') required String transactionStatus,
    @JsonKey(name: 'transaction_amount') required double transactionAmount,
    @JsonKey(name: 'transaction_paid_amount') required double transactionPaidAmount,
    @JsonKey(name: 'transaction_due_amount') required double transactionDueAmount,
    @JsonKey(name: 'created_by_name') required String createdByName,
    @JsonKey(name: 'return_items') required List<ReturnItemDetail> returnItems,
    @JsonKey(name: 'accounting_entries') required List<AccountingEntry> accountingEntries,
    @JsonKey(name: 'reason') String? reason,
    @JsonKey(name: 'notes') String? notes,
    @JsonKey(name: 'customer') Customer? customer,
  }) = _SaleReturn;

  factory SaleReturn.fromJson(Map<String, dynamic> json) => _$SaleReturnFromJson(json);
}

@freezed
class ReturnItemDetail with _$ReturnItemDetail {
  const factory ReturnItemDetail({
    @JsonKey(name: 'item_id') required String itemId,
    @JsonKey(name: 'item_code') required String itemCode,
    @JsonKey(name: 'item_name') required String itemName,
    @JsonKey(name: 'return_item_id') required String returnItemId,
    @JsonKey(name: 'return_quantity') required double returnQuantity,
    @JsonKey(name: 'original_quantity') required double originalQuantity,
    @JsonKey(name: 'return_unit_price') required double returnUnitPrice,
    @JsonKey(name: 'return_total_price') required double returnTotalPrice,
    @JsonKey(name: 'original_unit_price') required double originalUnitPrice,
    @JsonKey(name: 'original_total_price') required double originalTotalPrice,
  }) = _ReturnItemDetail;

  factory ReturnItemDetail.fromJson(Map<String, dynamic> json) => _$ReturnItemDetailFromJson(json);
}

@freezed
class AccountingEntry with _$AccountingEntry {
  const factory AccountingEntry({
    @JsonKey(name: 'amount') required double amount,
    @JsonKey(name: 'entry_id') required String entryId,
    @JsonKey(name: 'account_id') required String accountId,
    @JsonKey(name: 'entry_type') required String entryType,
    @JsonKey(name: 'description') required String description,
    @JsonKey(name: 'account_name') required String accountName,
  }) = _AccountingEntry;

  factory AccountingEntry.fromJson(Map<String, dynamic> json) => _$AccountingEntryFromJson(json);
}

@freezed
class CreateSaleReturn with _$CreateSaleReturn {
  const factory CreateSaleReturn({
    @JsonKey(name: 'sale_id') required String saleId,
    @JsonKey(name: 'business_id') required String businessId,
    @JsonKey(name: 'return_invoice') required String returnInvoice,
    @JsonKey(name: 'return_date') required DateTime returnDate,
    @JsonKey(name: 'reason') required String reason,
    @JsonKey(name: 'items') required List<ReturnedItem> items,
    @JsonKey(name: 'return_amount') required double returnAmount,
    @JsonKey(name: 'notes') String? notes,
  }) = _CreateSaleReturn;

  factory CreateSaleReturn.fromJson(Map<String, dynamic> json) => _$CreateSaleReturnFromJson(json);
}
