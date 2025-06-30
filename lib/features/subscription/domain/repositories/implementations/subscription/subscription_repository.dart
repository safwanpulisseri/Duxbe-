import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/subscription/subscription.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'subscription_repository.g.dart';

@Riverpod(keepAlive: true)
ISubscriptionRepository subscriptionRepo(SubscriptionRepoRef ref) => SubscriptionRepository(ref);

class SubscriptionRepository implements ISubscriptionRepository {
  SubscriptionRepository(this.ref) : _supabaseClient = ref.watch(supabaseProvider);
  final SubscriptionRepoRef ref;
  final SupabaseClient _supabaseClient;

  @override
  Future<List<PlanDetail>> getPromotionalPlanDetails(String countryCode) async {
    try {
      final response = await _supabaseClient.rpc<PostgrestList>(
        RPCConstants.getPromotionalPlanDetails,
        params: {'p_country_code': countryCode},
      ).withConverter((data) => data.map(PlanDetail.fromJson).toList());
      return response;
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  @override
  Future<SubscriptionResponse> createSubscription({
    required String countryCode,
    int? planId,
    int? addonId,
    String? billingCycle,
    int? quantity,
  }) async {
    try {
      final orgId = ref.watch(businessNotifierProvider)?.orgId;
      if (orgId == null) {
        throw const AppException('Organization ID not found');
      }
      final response = await _supabaseClient.functions.invoke(
        'subscriptions/create-subscription',
        body: {
          'plan_id': planId,
          'addon_id': addonId,
          'country_code': countryCode,
          'org_id': orgId,
          'billing_cycle': billingCycle ?? 'annually',
          'quantity': quantity ?? 1,
          'item_type': addonId != null ? 'addon' : 'plan',
        },
      ).then((value) => SubscriptionResponse.fromJson(value.data as Map<String, dynamic>));

      return response;
    } on FunctionException catch (e) {
      // Attempt to parse the error details if they exist
      var errorMessage = 'Failed to create subscription.';
      final dynamic errorDetails = e.details; // Keep it dynamic initially

      // Check if details contain a structured error (like the one from Hono)
      if (errorDetails is Map<String, dynamic> && errorDetails.containsKey('error')) {
        // Try to extract a more specific message if available
        final errorContent = errorDetails['error'];
        if (errorContent is Map<String, dynamic> && errorContent.containsKey('message')) {
          errorMessage = errorContent['message'].toString();
        } else if (errorContent is String) {
          errorMessage = errorContent;
        }
      } else if (e.details != null) {
        // Fallback to raw details if not the expected structure
        errorMessage = e.details.toString();
      }

      throw AppException(errorMessage, details: errorMessage);
    } catch (e) {
      throw AppException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<PaginatedResponse<Subscription>> getAllActiveSubscriptions({
    required int pageSize,
    required int pageNumber,
    String query = '',
  }) async {
    try {
      final orgId = ref.watch(businessNotifierProvider)?.orgId;
      if (orgId == null) {
        throw const AppException('Organization ID not found');
      }
      final offset = (pageNumber - 1) * pageSize;
      final response = await _supabaseClient
          .from('subscriptions')
          .select('*, plans(*), addons(*)')
          .eq('org_id', orgId)
          .range(offset, pageSize + offset - 1)
          .count(CountOption.exact);
      return PaginatedResponse(
        data: response.data.map(Subscription.fromJson).toList(),
        count: response.count,
      );
    } catch (e) {
      throw AppException('An unexpected error occurred while fetching active subscriptions: $e');
    }
  }

  @override
  Future<PaginatedResponse<SubscriptionInvoice>> getSubscriptionInvoices({
    required int pageSize,
    required int pageNumber,
    String query = '',
  }) async {
    try {
      final orgId = ref.watch(businessNotifierProvider)?.orgId;
      if (orgId == null) {
        throw const AppException('Organization ID not found');
      }
      final offset = (pageNumber - 1) * pageSize;

      final response = await _supabaseClient
          .from('subscription_invoices')
          .select()
          .eq('org_id', orgId)
          .range(offset, pageSize + offset - 1)
          .count(CountOption.exact);
      return PaginatedResponse(
        data: response.data.map(SubscriptionInvoice.fromJson).toList(),
        count: response.count,
      );
    } on PostgrestException catch (e) {
      throw AppException('An unexpected error occurred while fetching subscription invoices: $e');
    }
  }

  @override
  Future<List<AddonDetail>> getAddons(String countryCode) async {
    try {
      final response = await _supabaseClient.rpc<PostgrestList>(
        RPCConstants.getPromotionalAddonDetails,
        params: {'p_country_code': countryCode},
      ).withConverter((data) => data.map(AddonDetail.fromJson).toList());
      return response;
    } on PostgrestException catch (e) {
      throw AppException('An unexpected error occurred while fetching addons: $e');
    }
  }
}
