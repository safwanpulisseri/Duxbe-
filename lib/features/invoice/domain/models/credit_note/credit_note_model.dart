import 'package:duxbe/features/invoice/domain/invoice_domain.dart';
import 'package:duxbe/features/sale/domain/models/customer/customer_model.dart';
import 'package:duxbe/shared/utils/enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'credit_note_model.freezed.dart';
part 'credit_note_model.g.dart';

enum CreditNoteFormStatus { open, closed, partiallyUsed }

class CreditNoteFormStatusConverter implements JsonConverter<CreditNoteFormStatus, String> {
  const CreditNoteFormStatusConverter();

  @override
  CreditNoteFormStatus fromJson(String json) {
    switch (json) {
      case 'open':
        return CreditNoteFormStatus.open;
      case 'closed':
        return CreditNoteFormStatus.closed;
      case 'partially_used':
        return CreditNoteFormStatus.partiallyUsed;
      default:
        throw ArgumentError('Invalid CreditNoteFormStatus value: $json');
    }
  }

  @override
  String toJson(CreditNoteFormStatus status) {
    switch (status) {
      case CreditNoteFormStatus.open:
        return 'open';
      case CreditNoteFormStatus.closed:
        return 'closed';
      case CreditNoteFormStatus.partiallyUsed:
        return 'partially_used';
    }
  }
}

@freezed
class CreditNote with _$CreditNote {
  const factory CreditNote({
    // --- Fields from the LIST VIEW (Always present) ---
    @JsonKey(name: 'credit_note_id') String? creditNoteId,
    @JsonKey(name: 'credit_note_code') String? creditNoteCode,
    @JsonKey(name: 'customer_name') String? customerName, // From the list view join
    @CreditNoteFormStatusConverter() CreditNoteFormStatus? status,
    @JsonKey(name: 'credit_note_date') DateTime? creditNoteDate,
    @JsonKey(name: 'created_at') DateTime? createdAt, // From the list view join
    @JsonKey(name: 'linked_invoice_code') String? linkedInvoiceCode,

    // --- Handling the amount field from both views ---
    // The list view has `amount`, the details view has `grand_total`.
    // We include both as nullable and provide a getter for convenience.
    double? amount, // From list_view
    @JsonKey(name: 'grand_total') double? grandTotal, // From details_view

    // --- Fields from the DETAILS VIEW (Nullable) ---
    @JsonKey(name: 'business_id') String? businessId,
    @JsonKey(name: 'customer_id') String? customerId,
    String? notes,
    @JsonKey(name: 'terms_and_conditions') String? termsAndConditions,
    String? reason,
    String? reference,
    @JsonKey(name: 'due_date') DateTime? dueDate,
    @JsonKey(name: 'sub_total') double? subTotal,
    @JsonKey(name: 'tax_total') double? taxTotal,
    @JsonKey(name: 'discount_amount') double? discountAmount,
    @JsonKey(name: 'shipping_charges') double? shippingCharges,
    @JsonKey(name: 'credit_remaining') double? creditRemaining,

    // --- Nested JSON Objects from DETAILS VIEW (Nullable) ---
    BusinessInfo? business,
    Customer? customer,
    EmployeeInfo? employee,
    @JsonKey(name: 'invoice_details') Invoice? invoiceDetails,
    @Default([]) @JsonKey(name: 'credit_note_items') List<QuoteItem>? creditNoteItems,
    @Default([]) @JsonKey(name: 'refund_details') List<RefundPaymentDetails> refundDetails,
  }) = _CreditNote;

  factory CreditNote.fromJson(Map<String, dynamic> json) => _$CreditNoteFromJson(json);
}

@freezed
class RefundPaymentDetails with _$RefundPaymentDetails {
  const factory RefundPaymentDetails({
    @JsonKey(name: 'refund_id') required String refundId,
    @JsonKey(name: 'business_id') required String businessId,
    @JsonKey(name: 'customer_id') required String customerId,
    @JsonKey(name: 'is_credit_note') required bool isCreditNote,
    @JsonKey(name: 'amount_refunded') required double amountRefunded,
    @JsonKey(name: 'refund_date') required DateTime refundDate,
    @JsonKey(name: 'payment_mode') required PaymentMode paymentMode,
    @JsonKey(name: 'deposited_to') required String depositedTo,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'invoice_id') String? invoiceId,
    @JsonKey(name: 'reference_number') String? referenceNumber,
    String? notes,
    @JsonKey(name: 'created_by') String? createdBy,
    @JsonKey(name: 'refund_status') PaymentReceivedDataStatus? refundStatus,
  }) = _RefundPaymentDetails;
  factory RefundPaymentDetails.fromJson(Map<String, dynamic> json) => _$RefundPaymentDetailsFromJson(json);
}
