import 'package:duxbe/features/organization/controller/organization_notifier.dart';
import 'package:duxbe/features/subscription/presentation/subscription_plans/widgets/plan_details.dart';
import 'package:duxbe/features/subscription/subscription.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionPlansScreenMobile extends ConsumerStatefulWidget {
  const SubscriptionPlansScreenMobile({super.key});

  @override
  ConsumerState<SubscriptionPlansScreenMobile> createState() => _SubscriptionPlansScreenMobileState();
}

class _SubscriptionPlansScreenMobileState extends ConsumerState<SubscriptionPlansScreenMobile>
    with TickerProviderStateMixin {
  int get _tabLength {
    final planId = ref.read(organizationNotifierProvider)?.activeSubscriptionDetails?.planId;
    return (planId == 1) ? 3 : 4;
  }

  late TabController _tabController;
  int _currentTabLength = 4; // default

  @override
  void initState() {
    super.initState();
    _currentTabLength = _tabLength;
    _tabController = TabController(length: _currentTabLength, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final countryCode = ref.watch(ipConfigProvider).value?.country ?? 'IN';
    final plansAsync = ref.watch(plansListProvider(countryCode));
    final addonsAsync = ref.watch(addonsListProvider(countryCode));

    final subInvoicesState = ref.watch(subInvoicesNotifierProvider);

    final subscriptionState = ref.watch(subscriptionNotifierProvider);
    ref.listen(organizationNotifierProvider, (previous, next) {
      final newLength = _tabLength;
      if (newLength != _currentTabLength) {
        setState(() {
          _currentTabLength = newLength;
          _tabController.dispose();
          _tabController = TabController(length: _currentTabLength, vsync: this);
        });
      }
    });
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(context.l10n.subscriptionPlans),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 0,
            child: Offstage(
              child: PagedListView(
                pagingController: subInvoicesState.pagingController!,
                builderDelegate: PagedChildBuilderDelegate(
                  itemBuilder: (context, item, index) => const SizedBox(),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 0,
            child: Offstage(
              child: PagedListView(
                pagingController: subscriptionState.pagingController!,
                builderDelegate: PagedChildBuilderDelegate(
                  itemBuilder: (context, item, index) => const SizedBox(),
                ),
              ),
            ),
          ),
          Expanded(
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          context.l10n.simplePricingForYourBusiness,
                          style: AppText.heading5.copyWith(color: AppColors.primaryColor),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.l10n.plansCarefullyCrafted,
                          style: AppText.smallN.copyWith(color: AppColors.primaryColor),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarSliverDelegate(
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      indicator: const BoxDecoration(
                        color: Colors.transparent,
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.brandViolet,
                            width: 2,
                          ),
                        ),
                      ),
                      labelColor: AppColors.black,
                      tabs: [
                        Tab(text: context.l10n.subscriptionPlan),
                        if (ref.watch(organizationNotifierProvider)?.activeSubscriptionDetails?.planId != 1)
                          Tab(text: context.l10n.addons),
                        Tab(text: context.l10n.billing),
                        Tab(text: context.l10n.invoices),
                      ],
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildPricingCards(plansAsync.value ?? []),
                  if (ref.watch(organizationNotifierProvider)?.activeSubscriptionDetails?.planId != 1)
                    _buildAddonCards(addonsAsync.value ?? []),
                  _buildSubscriptionTable(subscriptionState.pagingController?.itemList ?? []),
                  _buildInvoiceTable(subInvoicesState.pagingController?.itemList ?? []),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCards(List<PlanDetail> plans) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: plans.map((plan) {
          final isFreePlan = plan.priceMonthly == null || plan.priceMonthly == 0;
          final organizationState = ref.watch(organizationNotifierProvider);
          final currentPlan = organizationState?.activeSubscriptionDetails;
          final isCurrentPlan = plan.planId == currentPlan?.planId;
          final isUpgradable = plan.planId > (currentPlan?.planId ?? 1);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: _PricingCard(
              title: plan.planName,
              price: plan.formattedMonthlyPrice,
              billingPeriod: isFreePlan ? null : context.l10n.perMonthly,
              billingNote: isFreePlan ? null : '${plan.formattedAnnualPrice}, ${context.l10n.billedAnnually}',
              features: plan.features
                  .where((feature) => feature.isEnabled)
                  .map((feature) => '${feature.featureName}${feature.displayLimit}')
                  .toList(),
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
                  setState(() => _tabController.animateTo(0));
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAddonCards(List<AddonDetail> addons) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: addons.map((addon) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
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
                final currentPlan = organizationState?.activeSubscriptionDetails;
                // if the current plan is trial, then alert the user that they need to purchase the plan to add this addon
                if (currentPlan?.status == 'trialing' &&
                    currentPlan?.trialEndDate != null &&
                    currentPlan!.trialEndDate!.isAfter(DateTime.now())) {
                  Alert.showSnackBar(context.l10n.purchasePlanToAddAddon);
                  return;
                }
                await showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return AddonDetailsDialog(addon: addon);
                  },
                ).then((value) {
                  setState(() => _tabController.animateTo(1));
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubscriptionTable(List<Subscription> subscriptions) {
    if (subscriptions.isEmpty) {
      return const NoDataViewWidget();
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Theme(
          data: Theme.of(context).copyWith(
            cardTheme: const CardThemeData(
              margin: EdgeInsets.zero,
              color: Colors.white,
            ),
          ),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppColors.lightPurple),
            headingRowHeight: 40,
            border: const TableBorder(),
            dataRowColor: WidgetStateProperty.all(AppColors.lightPurple.withOpacity(0.5)),
            dividerThickness: 0,
            columns: [
              DataColumn(label: Text(context.l10n.plan)),
              DataColumn(label: Text(context.l10n.amount)),
              DataColumn(label: Text(context.l10n.status)),
              DataColumn(label: Text(context.l10n.nextBillingDate)),
            ],
            rows: [
              ...subscriptions.mapIndexed((index, sub) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        sub.plan != null
                            ? sub.plan!.name
                            : sub.addon != null
                                ? sub.addon!.name
                                : 'N/A',
                      ),
                    ),
                    DataCell(Text(sub.planAmount?.toStringAsFixed(2) ?? 'N/A')),
                    DataCell(Text(sub.status.displayCase)),
                    DataCell(Text(sub.currentEnd?.toLocal().toString().substring(0, 10) ?? 'N/A')),
                  ],
                );
              }),
            ],
            columnSpacing: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceTable(List<SubscriptionInvoice> invoices) {
    if (invoices.isEmpty) {
      return const NoDataViewWidget();
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Theme(
          data: Theme.of(context).copyWith(
            cardTheme: const CardThemeData(
              margin: EdgeInsets.zero,
              color: Colors.white,
            ),
          ),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppColors.lightPurple),
            headingRowHeight: 40,
            border: const TableBorder(),
            dataRowColor: WidgetStateProperty.all(AppColors.lightPurple.withOpacity(0.5)),
            dividerThickness: 0,
            columns: [
              DataColumn(label: Text(context.l10n.slNo)),
              DataColumn(label: Text(context.l10n.date)),
              DataColumn(label: Text(context.l10n.amount)),
              DataColumn(label: Text(context.l10n.status)),
              DataColumn(label: Text(context.l10n.invoiceId)),
              DataColumn(label: Text(context.l10n.action)),
            ],
            rows: [
              ...invoices.mapIndexed((index, item) {
                return DataRow(
                  cells: [
                    DataCell(Text('${index + 1}')),
                    DataCell(Text(item.createdAt.toLocal().toString().substring(0, 10))),
                    DataCell(Text('${item.currency} ${item.amount.toStringAsFixed(2)}')),
                    DataCell(Text(item.status)),
                    DataCell(Text(item.paymentProviderInvoiceId)),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.download_for_offline, color: AppColors.primaryColor),
                        tooltip: 'Download Invoice',
                        // Assumes SubscriptionInvoice has .shortUrl, and it's nullable
                        onPressed: item.pdfUrl != null && item.pdfUrl!.isNotEmpty
                            ? () async {
                                final uri = Uri.tryParse(item.pdfUrl!);
                                if (uri != null && await canLaunchUrl(uri)) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                } else {
                                  Alert.showSnackBar(context.l10n.couldNotOpenInvoiceLink, type: SnackBarType.error);
                                }
                              }
                            : null,
                      ),
                    ),
                  ],
                );
              }),
            ],
            columnSpacing: 12,
          ),
        ),
      ),
    );
  }
}

class _PricingCard extends StatelessWidget {
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
  @override
  Widget build(BuildContext context) {
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
            SizedBox(
              width: double.infinity,
              child: AppButton(
                isLoading: isLoading,
                onPress: enabled ? onPress : null,
                style: isCurrentPlan ? ButtonStyles.secondary : ButtonStyles.primary,
                label: Text(buttonText),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Features',
              style: TextStyle(
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

class _TabBarSliverDelegate extends SliverPersistentHeaderDelegate {
  _TabBarSliverDelegate(this.tabBar);
  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ColoredBox(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}
