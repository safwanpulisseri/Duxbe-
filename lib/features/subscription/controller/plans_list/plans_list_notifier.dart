import 'package:duxbe/features/organization/controller/organization_notifier.dart';
import 'package:duxbe/features/subscription/subscription.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'plans_list_notifier.freezed.dart';
part 'plans_list_notifier.g.dart';
part 'plans_list_state.dart';

@Riverpod(keepAlive: true)
Future<List<PlanDetail>> plansList(
  PlansListRef ref,
  String countryCode,
) async =>
    ref.watch(subscriptionRepoProvider).getPromotionalPlanDetails(countryCode);

@Riverpod(keepAlive: true)
Future<List<AddonDetail>> addonsList(
  AddonsListRef ref,
  String countryCode,
) async =>
    ref.watch(subscriptionRepoProvider).getAddons(countryCode);

@Riverpod(keepAlive: true)
class SubscriptionPlansNotifier extends _$SubscriptionPlansNotifier {
  late ISubscriptionRepository _subscriptionRepository;

  @override
  SubscriptionPlansState build() {
    _subscriptionRepository = ref.watch(subscriptionRepoProvider);
    return const SubscriptionPlansState();
  }

  Future<SubscriptionResponse> createSubscription({required int planId, required String countryCode}) async {
    state = state.copyWith(status: SubscriptionPlansStatus.loading);
    try {
      final subscription = await _subscriptionRepository.createSubscription(planId: planId, countryCode: countryCode);
      if (subscription.paymentUrl != null) {
        state = state.copyWith(status: SubscriptionPlansStatus.success);
        Alert.showSnackBar(subscription.message ?? 'Subscription created successfully');
        ref.read(organizationNotifierProvider.notifier).build();
        return subscription;
      } else {
        state = state.copyWith(status: SubscriptionPlansStatus.error);
        throw AppException(subscription.error ?? 'Error while creating subscription');
      }
    } catch (e) {
      Alert.showSnackBar(e.toString());
      state = state.copyWith(status: SubscriptionPlansStatus.error);
      rethrow;
    }
  }
}
