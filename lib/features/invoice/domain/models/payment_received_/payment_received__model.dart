import 'package:duxbe/features/invoice/invoice.dart';
import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/shared/utils/enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_received__model.freezed.dart';
part 'payment_received__model.g.dart';

enum PaymentReceivedDataStatus { paid, partiallyPaid, completed, refund, partiallyRefund }

@freezed
class PaymentReceived with _$PaymentReceived {
  const factory PaymentReceived({
    @JsonKey(name: 'payment_id') String? paymentId,
    @JsonKey(name: 'business_id') String? businessId,
    @JsonKey(name: 'customer_id') String? customerId,
    @JsonKey(name: 'invoice_id') String? invoiceId,
    @JsonKey(name: 'payment_code') String? paymentCode,
    @JsonKey(name: 'amount_received', fromJson: parseDoubleSafe) double? amountReceived,
    @JsonKey(name: 'payment_date', fromJson: dateTimeFromString) DateTime? paymentDate,
    @JsonKey(name: 'payment_mode') PaymentMode? paymentMode,
    @JsonKey(name: 'deposited_to') String? depositedTo,
    @JsonKey(name: 'reference_number') String? referenceNumber,
    @JsonKey(name: 'payment_notes') String? paymentNotes,
    @JsonKey(name: 'payment_created_at', fromJson: dateTimeFromString) DateTime? paymentCreatedAt,
    @JsonKey(name: 'created_by') String? createdBy,
    @JsonKey(name: 'payment_status') PaymentReceivedDataStatus? paymentStatus,
    BusinessInfo? business,
    Customer? customer,
    EmployeeInfo? employee,
    @JsonKey(name: 'invoice_details') Invoice? invoiceDetails,
    @Default([]) @JsonKey(name: 'refund_details') List<RefundPaymentDetails> refundDetails,
  }) = _PaymentReceived;

  factory PaymentReceived.fromJson(Map<String, dynamic> json) => _$PaymentReceivedFromJson(json);
}
