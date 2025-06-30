import 'package:duxbe/features/auth/auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'organization.freezed.dart';
part 'organization.g.dart';

// Assuming you have or will define these enums elsewhere,
// otherwise, you can use String and handle conversion manually.
// enum SubscriptionStatusEnum { trialing, active, past_due, inactive, canceled }
// enum BusinessTypeEnum { retail, service, manufacturing, others }
// enum BillingCycleEnum { monthly, annually } // Added for clarity

@freezed
class OrganizationDetails with _$OrganizationDetails {
  @JsonSerializable(explicitToJson: true)
  const factory OrganizationDetails({
    @JsonKey(name: 'org_id') required String orgId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'businesses_list', defaultValue: []) required List<Business> businessesList,
    @JsonKey(name: 'name') String? organizationName,
    @JsonKey(name: 'created_by') String? createdBy,
    @JsonKey(name: 'active_subscription_details') ActiveSubscriptionDetails? activeSubscriptionDetails,
    @JsonKey(name: 'active_addons_list', defaultValue: []) List<ActiveAddonSubscription>? activeAddonsList,
    @JsonKey(name: 'trial_activated') bool? trialActivated,
    @JsonKey(name: 'trial_end_date') DateTime? trialEndDate,
  }) = _OrganizationDetails;

  factory OrganizationDetails.fromJson(Map<String, dynamic> json) => _$OrganizationDetailsFromJson(json);
}

@freezed
class ActiveSubscriptionDetails with _$ActiveSubscriptionDetails {
  @JsonSerializable(explicitToJson: true)
  const factory ActiveSubscriptionDetails({
    @JsonKey(name: 'subscription_id') required String subscriptionId,
    required String status,
    @JsonKey(name: 'cancel_at_period_end') required bool cancelAtPeriodEnd,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'start_date') DateTime? startDate, // Made nullable to match potential DB values
    @JsonKey(name: 'plan_id') int? planId,
    @JsonKey(name: 'end_date') DateTime? endDate,
    @JsonKey(name: 'trial_end_date') DateTime? trialEndDate,
    @JsonKey(name: 'canceled_at') DateTime? canceledAt,
    @JsonKey(name: 'payment_provider_subscription_id') String? paymentProviderSubscriptionId,
    @JsonKey(name: 'addon_id') int? addonId, // This is for an addon potentially linked to a plan subscription
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
    @JsonKey(name: 'billing_cycle') String? billingCycle, // Assuming BillingCycleEnum or String
    @JsonKey(name: 'metadata') Map<String, dynamic>? metadata,
    @JsonKey(name: 'plan_details') PlanDetails? planDetails, // Renamed from 'plan' for clarity
    @JsonKey(name: 'addon_details_on_plan_sub') AddonDetails? addonDetailsOnPlanSub, // Renamed from 'addon'
  }) = _ActiveSubscriptionDetails;

  factory ActiveSubscriptionDetails.fromJson(Map<String, dynamic> json) => _$ActiveSubscriptionDetailsFromJson(json);
}

@freezed
class ActiveAddonSubscription with _$ActiveAddonSubscription {
  @JsonSerializable(explicitToJson: true)
  const factory ActiveAddonSubscription({
    @JsonKey(name: 'subscription_id') required String subscriptionId,
    @JsonKey(name: 'addon_id') required int addonId,
    required String status,
    @JsonKey(name: 'cancel_at_period_end') required bool cancelAtPeriodEnd,
    @JsonKey(name: 'billing_cycle')
    required String
        billingCycle, // Assuming BillingCycleEnum or String, @JsonKey(name: 'created_at') required DateTime createdAt, @JsonKey(name: 'updated_at') required DateTime updatedAt, @JsonKey(name: 'addon_details') required AddonDetails addonDetails, @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
    @JsonKey(name: 'trial_end_date') DateTime? trialEndDate,
    @JsonKey(name: 'canceled_at') DateTime? canceledAt,
    @JsonKey(name: 'payment_provider_subscription_id') String? paymentProviderSubscriptionId,
    @JsonKey(name: 'payment_provider_customer_id') String? paymentProviderCustomerId,
    @JsonKey(name: 'payment_provider') String? paymentProvider,
    @JsonKey(name: 'payment_provider_plan_id') String? paymentProviderPlanId, // ID from provider for the item
    @JsonKey(name: 'current_start') DateTime? currentStart,
    @JsonKey(name: 'current_end') DateTime? currentEnd,
    @JsonKey(name: 'payment_url') String? paymentUrl,
    @JsonKey(name: 'currency') String? currency,
    @JsonKey(name: 'subscribed_amount') double? subscribedAmount, // Price of the addon for this sub
    @JsonKey(name: 'total_invoice_amount') double? totalInvoiceAmount,
    @JsonKey(name: 'tax_amount') double? taxAmount,
    @JsonKey(name: 'metadata') Map<String, dynamic>? metadata,
  }) = _ActiveAddonSubscription;

  factory ActiveAddonSubscription.fromJson(Map<String, dynamic> json) => _$ActiveAddonSubscriptionFromJson(json);
}

@freezed
class PlanDetails with _$PlanDetails {
  @JsonSerializable(explicitToJson: true)
  const factory PlanDetails({
    @JsonKey(name: 'plan_id') required int planId,
    required String name,
    required String slug,
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'display_order') required int displayOrder,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    String? description,
    @JsonKey(name: 'default_price_monthly') double? defaultPriceMonthly, // numeric(10,2) -> String
    @JsonKey(name: 'default_price_annual') double? defaultPriceAnnual, // numeric(10,2) -> String
    @JsonKey(name: 'default_currency') String? defaultCurrency,
    @JsonKey(name: 'trial_period_days') int? trialPeriodDays,
  }) = _PlanDetails;

  factory PlanDetails.fromJson(Map<String, dynamic> json) => _$PlanDetailsFromJson(json);
}

@freezed
class AddonDetails with _$AddonDetails {
  @JsonSerializable(explicitToJson: true)
  const factory AddonDetails({
    @JsonKey(name: 'addon_id') required int addonId,
    required String name,
    required String slug,
    // If addon_type is an enum in Dart:
    // @JsonKey(name: 'addon_type') required AddonTypeEnum addonType,
    // Otherwise, as a String:
    @JsonKey(name: 'addon_type') required String addonType,
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    String? description,
    @JsonKey(name: 'linked_feature_id') int? linkedFeatureId,
    @JsonKey(name: 'unit_name') String? unitName,
    @JsonKey(name: 'default_price_monthly') String? defaultPriceMonthly, // numeric(10,2) -> String
    @JsonKey(name: 'default_price_annual') String? defaultPriceAnnual, // numeric(10,2) -> String
    @JsonKey(name: 'default_currency') String? defaultCurrency,
  }) = _AddonDetails;

  factory AddonDetails.fromJson(Map<String, dynamic> json) => _$AddonDetailsFromJson(json);
}
