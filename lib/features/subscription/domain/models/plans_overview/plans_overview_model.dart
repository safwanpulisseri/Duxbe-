import 'package:freezed_annotation/freezed_annotation.dart';

part 'plans_overview_model.freezed.dart';
part 'plans_overview_model.g.dart';

// Enum for FeatureType (matching the database ENUM and JSON strings)
// Use @JsonValue for explicit string mapping
enum FeatureType {
  @JsonValue('boolean')
  boolean,
  @JsonValue('limit')
  limit,
  @JsonValue('metered')
  metered,
}

// Main model for a single Plan
@freezed
class PlanDetail with _$PlanDetail {
  // Factory constructor defining the fields
  @JsonSerializable(explicitToJson: true) // Needed for nested objects serialization
  const factory PlanDetail({
    @JsonKey(name: 'plan_id') required int planId,
    @JsonKey(name: 'plan_name') required String planName,
    @JsonKey(name: 'plan_slug') required String planSlug,
    @JsonKey(name: 'display_order')
    required int displayOrder, // Ensure the list is not nullable, default to empty list if JSON key is missing
    @JsonKey(name: 'features') @Default([]) List<FeatureDetail> features,
    @JsonKey(name: 'plan_description') String? planDescription, // Nullable based on DB schema
    @JsonKey(name: 'price_monthly') double? priceMonthly, // Use double for currency, nullable
    @JsonKey(name: 'price_annual') double? priceAnnual, // Use double for currency, nullable
    @JsonKey(name: 'currency') String? currency, // Nullable
    @JsonKey(name: 'trial_period_days') int? trialPeriodDays, // Nullable
  }) = _PlanDetail;
  // Private constructor is needed by freezed
  const PlanDetail._();

  // Factory constructor for JSON deserialization
  factory PlanDetail.fromJson(Map<String, dynamic> json) => _$PlanDetailFromJson(json);

  // Example getter for convenience (optional)
  String get formattedMonthlyPrice {
    if (priceMonthly == null || currency == null) return 'N/A';
    if (priceMonthly == 0) return 'Free';
    // Add more sophisticated currency formatting based on locale if needed
    return '$currency ${priceMonthly!.toStringAsFixed(2)}';
  }

  // Example getter for convenience (optional)
  String get formattedAnnualPrice {
    if (priceAnnual == null || currency == null) return 'N/A';
    if (priceAnnual == 0) return 'Free';
    // Add more sophisticated currency formatting based on locale if needed
    return '$currency ${priceAnnual!.toStringAsFixed(2)}';
  }
}

// Model for a single Feature within a Plan
@freezed
class FeatureDetail with _$FeatureDetail {
  // Factory constructor defining the fields
  const factory FeatureDetail({
    @JsonKey(name: 'feature_id') required int featureId,
    @JsonKey(name: 'feature_name') required String featureName,
    @JsonKey(name: 'feature_slug') required String featureSlug,
    @JsonKey(name: 'feature_type') required FeatureType featureType, // Use the enum
    @JsonKey(name: 'is_enabled') required bool isEnabled,
    @JsonKey(name: 'limit_value') int? limitValue, // Nullable (BIGINT maps well to int in Dart unless extremely large)
  }) = _FeatureDetail;
  // Private constructor
  const FeatureDetail._();

  // Factory constructor for JSON deserialization
  factory FeatureDetail.fromJson(Map<String, dynamic> json) => _$FeatureDetailFromJson(json);

  // Example getter for display (optional)
  String get displayLimit {
    if (featureType == FeatureType.limit && isEnabled && limitValue != null) {
      return '(Up to $limitValue)';
    }
    return '';
  }
}

@freezed
class Plan with _$Plan {
  const factory Plan({
    @JsonKey(name: 'plan_id') required int planId,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'slug') required String slug,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'default_price_monthly') double? defaultPriceMonthly,
    @JsonKey(name: 'default_price_annual') double? defaultPriceAnnual,
    @JsonKey(name: 'default_currency') @Default('INR') String defaultCurrency,
    @JsonKey(name: 'trial_period_days') int? trialPeriodDays,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'display_order') @Default(0) int displayOrder,
  }) = _Plan;

  factory Plan.fromJson(Map<String, dynamic> json) => _$PlanFromJson(json);
}

@freezed
class LinkedFeature with _$LinkedFeature {
  const factory LinkedFeature({
    @JsonKey(name: 'feature_id') required int featureId,
    @JsonKey(name: 'feature_name') required String featureName,
    @JsonKey(name: 'feature_slug') required String featureSlug,
  }) = _LinkedFeature;

  factory LinkedFeature.fromJson(Map<String, dynamic> json) => _$LinkedFeatureFromJson(json);
}

@freezed
class AddonDetail with _$AddonDetail {
  factory AddonDetail({
    @JsonKey(name: 'addon_id') required int addonId,
    @JsonKey(name: 'currency') required String currency,
    @JsonKey(name: 'unit_name') required String unitName,
    @JsonKey(name: 'addon_name') required String addonName,
    @JsonKey(name: 'addon_slug') required String addonSlug,
    @JsonKey(name: 'addon_type') required String addonType, // Consider using an enum for addon_type in the future
    @JsonKey(name: 'price_annual') double? priceAnnual,
    @JsonKey(name: 'price_monthly') double? priceMonthly,
    @JsonKey(name: 'linked_feature') LinkedFeature? linkedFeature,
    @JsonKey(name: 'price_one_time') double? priceOneTime,
    @JsonKey(name: 'addon_description') String? addonDescription,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
  }) = _AddonDetail;

  AddonDetail._();

  factory AddonDetail.fromJson(Map<String, dynamic> json) => _$AddonDetailFromJson(json);

  // Example getter for convenience (optional)
  String get formattedMonthlyPrice {
    if (priceMonthly == null) return 'N/A';
    if (priceMonthly == 0) return 'Free';
    // Add more sophisticated currency formatting based on locale if needed
    return '$currency ${priceMonthly!.toStringAsFixed(2)}';
  }

  // Example getter for convenience (optional)
  String get formattedAnnualPrice {
    if (priceAnnual == null) return 'N/A';
    if (priceAnnual == 0) return 'Free';
    // Add more sophisticated currency formatting based on locale if needed
    return '$currency ${priceAnnual!.toStringAsFixed(2)}';
  }

  String get formattedOneTimePrice {
    if (priceOneTime == null) return 'N/A';
    if (priceOneTime == 0) return 'Free';
    return '$currency ${priceOneTime!.toStringAsFixed(2)}';
  }
}
