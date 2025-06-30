import 'package:duxbe/features/organization/controller/organization_notifier.dart';
import 'package:duxbe/features/subscription/subscription.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'addon_details_controller.freezed.dart';
part 'addon_details_controller.g.dart';

enum AddonPurchaseStatus { initial, loading, success, error }

@freezed
class AddonPurchaseState with _$AddonPurchaseState {
  const factory AddonPurchaseState({
    @Default(AddonPurchaseStatus.initial) AddonPurchaseStatus status,
    String? error,
  }) = _AddonPurchaseState;
}

@Riverpod(keepAlive: true)
class AddonPurchaseNotifier extends _$AddonPurchaseNotifier {
  late ISubscriptionRepository _subscriptionRepository;

  @override
  AddonPurchaseState build() {
    _subscriptionRepository = ref.watch(subscriptionRepoProvider);
    return const AddonPurchaseState();
  }

  Future<SubscriptionResponse> createAddonSubscription({
    required int addonId,
    required int quantity, // Assuming quantity might be used by the repository
    required BillingCycle billingCycle,
    required String countryCode,
    required Map<String, dynamic> billingDetails, // Assuming billingDetails might be used
  }) async {
    state = state.copyWith(status: AddonPurchaseStatus.loading, error: null);
    try {
      // Replace with your actual API call to create addon subscription
      // The existing createSubscription method in ISubscriptionRepository
      // seems to handle both plans and addons based on whether addonId is provided.
      // We might need to adjust ISubscriptionRepository or use a specific method if available.
      // For now, using the existing createSubscription method.
      final response = await _subscriptionRepository.createSubscription(
        addonId: addonId,
        countryCode: countryCode,
        quantity: quantity, // Pass quantity if your repository method supports it
        billingCycle: billingCycle.name, // Pass billingCycle if repository supports it
      );

      if (response.paymentUrl != null) {
        state = state.copyWith(status: AddonPurchaseStatus.success);
        Alert.showSnackBar(response.message ?? 'Addon subscription created successfully');
        ref.read(organizationNotifierProvider.notifier).build(); // Refresh organization data
        return response;
      } else {
        state = state.copyWith(status: AddonPurchaseStatus.error, error: response.error);
        throw AppException(response.error ?? 'Error while creating addon subscription');
      }
    } catch (e) {
      state = state.copyWith(status: AddonPurchaseStatus.error, error: e.toString());
      Alert.showSnackBar(e.toString());
      rethrow;
    }
  }
}
