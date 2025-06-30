// ignore_for_file: constant_identifier_names

import 'package:freezed_annotation/freezed_annotation.dart';

part 'purchase_audit_model.g.dart';
part 'purchase_audit_model.freezed.dart';

/// Enum for purchase audit actions
enum PurchaseAuditAction {
  CREATED,
  UPDATED,
  PAYMENT_ADDED,
  STATUS_CHANGED,
  CANCELED,
  ITEM_ADDED,
  ITEM_REMOVED,
  ITEM_QUANTITY_CHANGED,
  RETURN_CREATED
}

@freezed
class PurchaseAudit with _$PurchaseAudit {
  const factory PurchaseAudit({
    @JsonKey(name: 'audit_id') required String auditId,
    @JsonKey(name: 'purchase_id') required String purchaseId,
    @JsonKey(name: 'transaction_id') required String transactionId,
    @JsonKey(name: 'action_type') required PurchaseAuditAction actionType,
    @JsonKey(name: 'action_timestamp') required DateTime actionTimestamp,
    @JsonKey(name: 'performed_by') required String performedBy,
    @JsonKey(name: 'old_data') Map<String, dynamic>? oldData,
    @JsonKey(name: 'new_data') Map<String, dynamic>? newData,
    @JsonKey(name: 'change_details') String? changeDetails,
    @JsonKey(name: 'ip_address') String? ipAddress,
    @JsonKey(name: 'user_agent') String? userAgent,
  }) = _PurchaseAudit;

  factory PurchaseAudit.fromJson(Map<String, dynamic> json) => _$PurchaseAuditFromJson(json);
}
