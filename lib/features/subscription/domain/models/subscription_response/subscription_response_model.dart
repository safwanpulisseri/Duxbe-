import 'package:duxbe/features/subscription/subscription.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_response_model.freezed.dart';
part 'subscription_response_model.g.dart';

@freezed
class SubscriptionResponse with _$SubscriptionResponse {
  const factory SubscriptionResponse({
    @JsonKey(name: 'payment_url') String? paymentUrl,
    @JsonKey(name: 'message') String? message,
    @JsonKey(name: 'error') String? error,
    @JsonKey(name: 'status') int? status,
  }) = _SubscriptionResponse;

  factory SubscriptionResponse.fromJson(Map<String, dynamic> json) => _$SubscriptionResponseFromJson(json);
}

@freezed
class SubscriptionInvoice with _$SubscriptionInvoice {
  const factory SubscriptionInvoice({
    @JsonKey(name: 'subscription_invoice_id') required String subscriptionInvoiceId,
    @JsonKey(name: 'org_id') required String orgId,
    @JsonKey(name: 'payment_provider_invoice_id') required String paymentProviderInvoiceId,
    @JsonKey(name: 'payment_provider', defaultValue: 'razorpay') required String paymentProvider,
    @JsonKey(name: 'status', defaultValue: 'issued') required String status,
    required double amount,
    required String currency,
    @JsonKey(name: 'issued_at') required DateTime issuedAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'subscription_id') String? subscriptionId,
    @JsonKey(name: 'payment_provider_subscription_id') String? paymentProviderSubscriptionId,
    @JsonKey(name: 'payment_provider_order_id') String? paymentProviderOrderId,
    @JsonKey(name: 'payment_provider_payment_id') String? paymentProviderPaymentId,
    @JsonKey(name: 'amount_paid') double? amountPaid,
    @JsonKey(name: 'amount_due') double? amountDue,
    @JsonKey(name: 'due_date') DateTime? dueDate,
    @JsonKey(name: 'paid_at') DateTime? paidAt,
    @JsonKey(name: 'line_items') List<Map<String, dynamic>>? lineItems,
    String? notes,
    @JsonKey(name: 'pdf_url') String? pdfUrl,
    Map<String, dynamic>? metadata,
    @JsonKey(name: 'payment_url') String? paymentUrl,
  }) = _SubscriptionInvoice;

  factory SubscriptionInvoice.fromJson(Map<String, dynamic> json) => _$SubscriptionInvoiceFromJson(json);
}

@freezed
class Subscription with _$Subscription {
  const factory Subscription({
    @JsonKey(name: 'subscription_id') required String subscriptionId,
    @JsonKey(name: 'org_id') required String orgId,
    required String status,
    @JsonKey(name: 'start_date') required DateTime startDate,
    @JsonKey(name: 'cancel_at_period_end', defaultValue: false) required bool cancelAtPeriodEnd,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'plan_id') int? planId,
    @JsonKey(name: 'end_date') DateTime? endDate,
    @JsonKey(name: 'trial_end_date') DateTime? trialEndDate,
    @JsonKey(name: 'canceled_at') DateTime? canceledAt,
    @JsonKey(name: 'payment_provider_subscription_id') String? paymentProviderSubscriptionId,
    @JsonKey(name: 'addon_id') int? addonId,
    @JsonKey(name: 'payment_provider_customer_id') String? paymentProviderCustomerId,
    @JsonKey(name: 'payment_provider') String? paymentProvider,
    @JsonKey(name: 'payment_provider_plan_id') String? paymentProviderPlanId,
    @JsonKey(name: 'current_start') DateTime? currentStart,
    @JsonKey(name: 'current_end') DateTime? currentEnd,
    @JsonKey(name: 'payment_url') String? paymentUrl,
    @JsonKey(name: 'currency') String? currency,
    @JsonKey(name: 'plan_amount') double? planAmount,
    @JsonKey(name: 'total_invoice_amount') double? totalInvoiceAmount,
    @JsonKey(name: 'tax_amount') double? taxAmount,
    @JsonKey(name: 'billing_cycle') String? billingCycle,
    @JsonKey(name: 'plans') Plan? plan,
    @JsonKey(name: 'addons') Addon? addon,
  }) = _Subscription;

  factory Subscription.fromJson(Map<String, dynamic> json) => _$SubscriptionFromJson(json);
}

@freezed
class Addon with _$Addon {
  const factory Addon({
    @JsonKey(name: 'addon_id') required int addonId,
    required String name,
    required String slug,
    @JsonKey(name: 'addon_type', defaultValue: 'limit_increase') required String addonType,
    @JsonKey(name: 'is_active', defaultValue: true) required bool isActive,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    String? description,
    @JsonKey(name: 'linked_feature_id') int? linkedFeatureId,
    @JsonKey(name: 'unit_name', defaultValue: 'unit') String? unitName,
    @JsonKey(name: 'default_price_monthly') double? defaultPriceMonthly,
    @JsonKey(name: 'default_price_annual') double? defaultPriceAnnual,
    @JsonKey(name: 'default_currency') String? defaultCurrency,
    @JsonKey(name: 'default_price_one_time') double? defaultPriceOneTime,
  }) = _Addon;

  factory Addon.fromJson(Map<String, dynamic> json) => _$AddonFromJson(json);
}
