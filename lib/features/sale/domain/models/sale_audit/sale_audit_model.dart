// ignore_for_file: constant_identifier_names

import 'package:freezed_annotation/freezed_annotation.dart';

part 'sale_audit_model.freezed.dart';
part 'sale_audit_model.g.dart';

/// Enum for sale audit actions
enum SaleAuditAction {
  CREATED,
  UPDATED,
  PAYMENT_ADDED,
  STATUS_CHANGED,
  CANCELED,
  ITEM_ADDED,
  ITEM_REMOVED,
  ITEM_QUANTITY_CHANGED,
  RETURN_CREATED,
  DISCOUNT_APPLIED,
  DELIVERY_STATUS_CHANGED,
  INVOICE_GENERATED
}

@freezed
class SaleAudit with _$SaleAudit {
  const factory SaleAudit({
    @JsonKey(name: 'audit_id') required String auditId,
    @JsonKey(name: 'sale_id') required String saleId,
    @JsonKey(name: 'transaction_id') required String transactionId,
    @JsonKey(name: 'action_type') required SaleAuditAction actionType,
    @JsonKey(name: 'action_timestamp') required DateTime actionTimestamp,
    @JsonKey(name: 'performed_by') required String performedBy,
    @JsonKey(name: 'old_data') Map<String, dynamic>? oldData,
    @JsonKey(name: 'new_data') Map<String, dynamic>? newData,
    @JsonKey(name: 'change_details') String? changeDetails,
    @JsonKey(name: 'ip_address') String? ipAddress,
    @JsonKey(name: 'user_agent') String? userAgent,
  }) = _SaleAudit;

  factory SaleAudit.fromJson(Map<String, dynamic> json) => _$SaleAuditFromJson(json);
}
