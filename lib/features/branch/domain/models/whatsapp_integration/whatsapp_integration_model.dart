import 'package:freezed_annotation/freezed_annotation.dart';

part 'whatsapp_integration_model.freezed.dart';
part 'whatsapp_integration_model.g.dart';

@freezed
class WhatsappIntegration with _$WhatsappIntegration {
  const factory WhatsappIntegration({
    @JsonKey(name: 'business_id') required String businessId,
    @JsonKey(name: 'whatsapp_number_id') String? whatsappNumberId,
    @JsonKey(name: 'whatsapp_token') String? whatsappToken,
    @Default(false) @JsonKey(name: 'customer_sale_invoice') bool customerSaleInvoice,
    @Default(false) @JsonKey(name: 'customer_payment_receipt') bool customerPaymentReceipt,
    @Default(false) @JsonKey(name: 'admin_order_assigned_alert') bool adminOrderAssignedAlert,
    @Default(false) @JsonKey(name: 'admin_stock_alert') bool adminStockAlert,
    @Default('None') @JsonKey(name: 'payment_overdue_alert') String paymentOverdueAlert,
  }) = _WhatsappIntegration;

  factory WhatsappIntegration.fromJson(Map<String, dynamic> json) => _$WhatsappIntegrationFromJson(json);
}
