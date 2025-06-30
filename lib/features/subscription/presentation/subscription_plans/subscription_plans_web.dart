import 'package:duxbe/features/organization/controller/organization_notifier.dart';
import 'package:duxbe/features/subscription/presentation/subscription_plans/widgets/plan_details.dart';
import 'package:duxbe/features/subscription/subscription.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

class SubscriptionPlansScreenWeb extends ConsumerStatefulWidget {
  const SubscriptionPlansScreenWeb({super.key});

  @override
  ConsumerState<SubscriptionPlansScreenWeb> createState() => _SubscriptionPlansScreenWebState();
}

class _SubscriptionPlansScreenWebState extends ConsumerState<SubscriptionPlansScreenWeb> {
  int _selectedTabIndex = 0;
  bool _isPlanDetailsVisible = false;

  @override
  Widget build(BuildContext context) {
    final countryCode = ref.watch(ipConfigProvider).value?.country ?? 'IN';
    final plansAsync = ref.watch(plansListProvider(countryCode));
    final addonsAsync = ref.watch(addonsListProvider(countryCode));

    final subInvoicesNotifier = ref.watch(subInvoicesNotifierProvider.notifier);
    final subInvoicesState = ref.watch(subInvoicesNotifierProvider);

    final subscriptionNotifier = ref.watch(subscriptionNotifierProvider.notifier);
    final subscriptionState = ref.watch(subscriptionNotifierProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.simplePricingForYourBusiness,
              style: AppText.b32.copyWith(color: AppColors.primaryColor),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.plansCarefullyCrafted,
              style: AppText.largeB.copyWith(color: AppColors.primaryColor),
            ),
            const SizedBox(height: 24),
            _buildTabBar(),
            const SizedBox(height: 32),
            Expanded(
              child: switch (_selectedTabIndex) {
                0 => SingleChildScrollView(
                    child: Column(
                      children: [
                        plansAsync.when(
                          data: _buildPricingCards,
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (error, stackTrace) => Center(
                            child: Text(
                              'Error loading plans: $error',
                              style: AppText.mediumM.copyWith(color: Colors.red),
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        plansAsync.when(
                          data: _buildPlanDetailsSection,
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                1 => addonsAsync.when(
                    data: _buildAddonCards,
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) => Center(
                      child: Text(
                        'Error loading addons: $error',
                        style: AppText.mediumM.copyWith(color: Colors.red),
                      ),
                    ),
                  ),
                2 => Column(
                    children: [
                      Expanded(
                        child: PlutoGrid(
                          key: const Key('subscription_grid'),
                          mode: PlutoGridMode.readOnly,
                          columns: subscriptionNotifier.subscriptionColumns,
                          // ignore: prefer_const_literals_to_create_immutables
                          rows: [],
                          onLoaded: (PlutoGridOnLoadedEvent event) {
                            subscriptionNotifier.setStateManager(
                              stateManager: event.stateManager,
                            );
                          },
                          configuration: AppStylesX.dataTableConfig,
                          noRowsWidget: const NoDataViewWidget(),
                        ),
                      ),
                      PaginationFooter(
                        onPageChanged: (value) {
                          subscriptionNotifier.getSubscriptions(pageNumberOverride: value);
                        },
                        totalPages: (subscriptionState.count / subscriptionState.pageSize).ceil(),
                        currentPage: subscriptionState.pageNumber,
                      ),
                    ],
                  ),
                3 => Column(
                    children: [
                      Expanded(
                        child: PlutoGrid(
                          key: const Key('invoice_grid'),
                          mode: PlutoGridMode.readOnly,
                          columns: subInvoicesNotifier.invoiceColumns,
                          // ignore: prefer_const_literals_to_create_immutables
                          rows: [],
                          onLoaded: (PlutoGridOnLoadedEvent event) {
                            subInvoicesNotifier.setStateManager(
                              stateManager: event.stateManager,
                            );
                          },
                          configuration: AppStylesX.dataTableConfig,
                          noRowsWidget: const NoDataViewWidget(),
                        ),
                      ),
                      PaginationFooter(
                        onPageChanged: (value) {
                          subInvoicesNotifier.getInvoices(pageNumberOverride: value);
                        },
                        totalPages: (subInvoicesState.count / subInvoicesState.pageSize).ceil(),
                        currentPage: subInvoicesState.pageNumber,
                      ),
                    ],
                  ),
                _ => const SizedBox(),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xfff2f2f2),
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTab(context.l10n.subscriptionPlan, 0),
              if (ref.watch(organizationNotifierProvider)?.activeSubscriptionDetails?.planId != 1)
                _buildTab(context.l10n.addons, 1),
              // if (ref.watch(subscriptionNotifierProvider).subscriptions.isNotEmpty)
              _buildTab(context.l10n.billing, 2),
              // if (ref.watch(subInvoicesNotifierProvider).invoices.isNotEmpty)
              _buildTab(context.l10n.invoices, 3),
            ],
          ).withSpacing(spacing: 8),
        ),
      ],
    );
  }

  Widget _buildTab(String text, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? null : AppColors.white,
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    Color(0xff315EE7),
                    Color(0xff6246EA),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isSelected ? Colors.transparent : AppColors.grey),
        ),
        child: Text(
          text,
          style: AppText.mediumM.copyWith(color: isSelected ? AppColors.white : AppColors.grey),
        ),
      ),
    );
  }

  Widget _buildPricingCards(List<PlanDetail> plans) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: plans.map((plan) {
          final isFreePlan = plan.priceMonthly == null || plan.priceMonthly == 0;
          final organizationState = ref.watch(organizationNotifierProvider);
          final onTrialPeriod = organizationState?.trialEndDate?.isAfter(DateTime.now()) ?? false;
          final currentPlan = organizationState?.activeSubscriptionDetails;
          final isCurrentPlan = plan.planId == currentPlan?.planId;
          final isUpgradable = plan.planId > (currentPlan?.planId ?? 1);
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _PricingCard(
                title: plan.planName,
                price: plan.formattedMonthlyPrice,
                billingPeriod: isFreePlan ? null : context.l10n.perMonthly,
                billingNote: isFreePlan ? null : '${plan.formattedAnnualPrice}, ${context.l10n.billedAnnually}',
                features: plan.features
                    .where((feature) => feature.isEnabled)
                    .map((feature) => '${feature.featureName}${feature.displayLimit}')
                    .toList(),
                showButton: !(plan.planId == 1 && onTrialPeriod),
                buttonText: isCurrentPlan
                    ? context.l10n.currentPlan
                    : isUpgradable
                        ? context.l10n.upgrade
                        : context.l10n.downgrade,
                isCurrentPlan: isCurrentPlan,
                backgroundColor: isFreePlan ? null : const Color(0xFFF5F3FF),
                isLoading: ref.watch(
                  subscriptionPlansNotifierProvider.select((state) => state.status == SubscriptionPlansStatus.loading),
                ),
                enabled: !isCurrentPlan,
                onPress: () async {
                  // if the current plan is free, and there is active addon subscriptions then try to cancel the addon subscriptions
                  if (currentPlan?.planId == 1 && (organizationState?.activeAddonsList?.isNotEmpty ?? false)) {
                    Alert.showSnackBar(context.l10n.cancelActiveAddonsBeforeChangingPlan);
                    return;
                  }
                  await showDialog<void>(
                    context: context,
                    builder: (context) => PlanDetailsDialog(plan: plan),
                  ).then((value) {
                    setState(() => _selectedTabIndex = 3);
                  });
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAddonCards(List<AddonDetail> addons) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: addons.where((element) => element.isActive).map((addon) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _PricingCard(
                title: addon.addonName,
                price: (addon.priceMonthly == null ? addon.formattedOneTimePrice : addon.formattedMonthlyPrice),
                billingPeriod: addon.addonType == 'metered_quota'
                    ? context.l10n.per100Credits
                    : addon.priceAnnual == null || addon.priceMonthly == null
                        ? null
                        : addon.priceMonthly != null
                            ? context.l10n.perMonthly
                            : context.l10n.perYearly,
                billingNote: addon.priceAnnual == null || addon.priceMonthly == null
                    ? ''
                    : '${addon.formattedAnnualPrice}, ${context.l10n.billedAnnually}',
                features: [addon.addonDescription ?? ''],
                buttonText: context.l10n.addon,
                isLoading: ref.watch(
                  subscriptionPlansNotifierProvider.select((state) => state.status == SubscriptionPlansStatus.loading),
                ),
                onPress: () async {
                  final organizationState = ref.watch(organizationNotifierProvider);
                  // if the current plan is trial, then alert the user that they need to purchase the plan to add this addon
                  if (organizationState?.trialEndDate != null &&
                          organizationState!.trialEndDate!.isAfter(DateTime.now()) ||
                      organizationState?.activeSubscriptionDetails == null) {
                    Alert.showSnackBar(context.l10n.purchasePlanToAddAddon);
                    return;
                  }
                  await showDialog<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return AddonDetailsDialog(addon: addon);
                    },
                  ).then((value) {
                    setState(() => _selectedTabIndex = 1);
                  });
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPlanDetailsSection(List<PlanDetail> plans) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _isPlanDetailsVisible = !_isPlanDetailsVisible),
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.planDetails,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: _isPlanDetailsVisible ? 0.5 : 0,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          firstChild: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              _buildComparisonTable(plans),
            ],
          ),
          secondChild: const SizedBox.shrink(),
          crossFadeState: _isPlanDetailsVisible ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        ),
      ],
    );
  }

  Widget _buildComparisonTable(List<PlanDetail> plans) {
    // Get all unique features across all plans
    final allFeatures = plans.expand((plan) => plan.features).fold<List<FeatureDetail>>([], (unique, feature) {
      if (!unique.any((f) => f.featureName == feature.featureName)) {
        unique.add(feature);
      }
      return unique;
    });

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DataTable(
        columns: [
          DataColumn(label: Text(context.l10n.benefits)),
          ...plans.map((plan) => DataColumn(label: Text(plan.planName))),
        ],
        rows: allFeatures.map((feature) {
          return DataRow(
            cells: [
              DataCell(Text(feature.featureName)),
              ...plans.map((plan) {
                final planFeature = plan.features.firstWhere(
                  (f) => f.featureId == feature.featureId,
                  orElse: () => feature,
                );
                return DataCell(_buildCheckmark(planFeature.isEnabled));
              }),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCheckmark(bool isIncluded) {
    return Icon(
      isIncluded ? Icons.check : Icons.close,
      color: isIncluded ? Colors.green : Colors.red,
      size: 20,
    );
  }
}

class _PricingCard extends ConsumerWidget {
  const _PricingCard({
    required this.title,
    required this.price,
    required this.features,
    required this.buttonText,
    this.billingPeriod,
    this.billingNote,
    this.isCurrentPlan = false,
    this.backgroundColor,
    this.onPress,
    this.isLoading = false,
    this.enabled = true,
    this.showButton = true,
  });
  final String title;
  final String price;
  final String? billingPeriod;
  final String? billingNote;
  final List<String> features;
  final String buttonText;
  final bool isCurrentPlan;
  final Color? backgroundColor;
  final VoidCallback? onPress;
  final bool isLoading;
  final bool enabled;
  final bool showButton;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IntrinsicHeight(
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          // color: backgroundColor ?? Colors.white,
          gradient: switch (title) {
            'Free' => const LinearGradient(
                colors: [
                  Color(0xffF9F9FA),
                  Color(0xffFFFFFF),
                ],
              ),
            'Pro' => const LinearGradient(
                colors: [
                  Color(0xffFBFAFF),
                  Color(0xffEEEAFF),
                ],
              ),
            'Genius' => const LinearGradient(
                colors: [
                  Color(0xffDCDCFB),
                  Color(0xffF7F7FF),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            _ => const LinearGradient(
                colors: [
                  Color(0xffDCDCFB),
                  Color(0xffF7F7FF),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
          },
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  price == 'N/A' ? context.l10n.freeForever : price,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (billingPeriod != null)
                  Text(
                    billingPeriod!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
            Text(
              billingNote ?? '',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            // if (!(ref
            //             .watch(organizationNotifierProvider)
            //             ?.activeSubscriptionDetails
            //             ?.trialEndDate
            //             ?.isAfter(DateTime.now()) ??
            //         true) ||
            //     isCurrentPlan) ...[
            if (showButton) ...[
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  isLoading: isLoading,
                  onPress: enabled ? onPress : null,
                  style: isCurrentPlan ? ButtonStyles.secondary : ButtonStyles.primary,
                  label: Text(buttonText),
                ),
              )
            ],
            const SizedBox(height: 24),
            Text(
              context.l10n.features,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check,
                      size: 20,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(feature)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
