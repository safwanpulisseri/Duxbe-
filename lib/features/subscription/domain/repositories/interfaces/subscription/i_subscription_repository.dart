import 'package:duxbe/features/subscription/subscription.dart';
import 'package:duxbe/shared/shared.dart';

abstract class ISubscriptionRepository {
  Future<List<PlanDetail>> getPromotionalPlanDetails(String countryCode);
  Future<SubscriptionResponse> createSubscription({
    required String countryCode,
    int? planId,
    int? addonId,
    String? billingCycle,
    int? quantity,
  });
  Future<PaginatedResponse<Subscription>> getAllActiveSubscriptions({
    required int pageSize,
    required int pageNumber,
    String query = '',
  });
  Future<PaginatedResponse<SubscriptionInvoice>> getSubscriptionInvoices({
    required int pageSize,
    required int pageNumber,
    String query = '',
  });
  Future<List<AddonDetail>> getAddons(String countryCode);
}
