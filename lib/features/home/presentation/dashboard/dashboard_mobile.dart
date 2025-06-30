import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/home/home.dart' hide CustomAppBar;
import 'package:duxbe/features/home/presentation/dashboard/widgets/category_stats.dart';
import 'package:duxbe/features/home/presentation/dashboard/widgets/dashboard_card.dart';
import 'package:duxbe/features/home/presentation/dashboard/widgets/low_stocks.dart';
import 'package:duxbe/features/home/presentation/dashboard/widgets/online_store_bottom_sheet.dart';
import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

part 'widgets/ai_chat_mobile.dart';

class DashboardScreenMobile extends ConsumerStatefulWidget {
  const DashboardScreenMobile({super.key});

  @override
  ConsumerState<DashboardScreenMobile> createState() => _DashboardScreenMobileState();
}

class _DashboardScreenMobileState extends ConsumerState<DashboardScreenMobile> {
  static const _pageSize = 20;

  final PagingController<int, SaleView> _pagingController = PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener(_fetchPage);
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems =
          await ref.read(saleRepoProvider).getSales(pageNumber: pageKey, pageSize: _pageSize, orderMode: null);
      final isLastPage = newItems.data.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems.data);
      } else {
        final nextPageKey = pageKey + newItems.data.length;
        _pagingController.appendPage(newItems.data, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = ref.watch(homeNotifierProvider);
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MenuAnchor(
                  alignmentOffset: const Offset(40, 0),
                  builder: (context, controller, widget) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () {
                            controller.isOpen ? controller.close() : controller.open();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xffECEDF0)),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: AppColors.primaryLight,
                                  backgroundImage: ref.watch(businessNotifierProvider)?.logo != null
                                      ? NetworkImage(ref.watch(businessNotifierProvider)?.logo ?? '')
                                      : null,
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  ref.watch(businessNotifierProvider)?.name ?? '',
                                  style: AppText.mediumN.copyWith(color: AppColors.black),
                                ),
                                const SizedBox(width: 7),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  menuChildren: ref
                          .watch(authNotifierProvider)
                          .user
                          ?.accessedBrances
                          .map(
                            (e) => MenuItemButton(
                              style: MenuItemButton.styleFrom(
                                foregroundColor: AppColors.primaryColor,
                              ),
                              onPressed: () {
                                ref.read(businessNotifierProvider.notifier).setBusiness(e.businessId);
                              _pagingController.addPageRequestListener(_fetchPage);
                              },
                              child: Text(
                                e.name,
                                style: AppText.mediumN.copyWith(color: AppColors.black),
                              ),
                            ),
                          )
                          .toList() ??
                      [],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: GestureDetector(
                    onTap: () {
                      context.goNamed(AppRouter.subscriptionPlans);
                    },
                    child: Assets.icons.crown.svg(),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(
                        left: 6,
                        right: 6,
                        top: 4,
                        bottom: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.scaffoldBgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: MenuAnchor(
                        builder: (context, controller, widget) {
                          return GestureDetector(
                            onTap: () {
                              if (controller.isOpen) {
                                return controller.close();
                              }
                              controller.open();
                            },
                            child: ref.watch(localeProvider).languageCode == 'en'
                                ? Assets.icons.usCountry.svg(height: 30)
                                : Assets.icons.qatarCountry.svg(height: 30),
                          );
                        },
                        menuChildren: [
                          MenuItemButton(
                            style: MenuItemButton.styleFrom(
                              foregroundColor: AppColors.primaryColor,
                            ),
                            onPressed: () {
                              ref.read(localeProvider.notifier).state = const Locale('en');
                            },
                            child: Row(
                              children: [
                                Assets.icons.usCountry.svg(height: 30),
                                const SizedBox(width: 8),
                                Text(context.l10n.english),
                              ],
                            ),
                          ),
                          MenuItemButton(
                            style: MenuItemButton.styleFrom(
                              foregroundColor: AppColors.primaryColor,
                            ),
                            onPressed: () {
                              ref.read(localeProvider.notifier).state = const Locale('ar');
                            },
                            child: Row(
                              children: [
                                Assets.icons.qatarCountry.svg(height: 30),
                                const SizedBox(width: 8),
                                Text(context.l10n.arabic),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        context.pushNamed(AppRouter.aiChat);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.scaffoldBgColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xffECEDF0)),
                        ),
                        child: Assets.icons.aiButton.svg(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              InkWell(
                // ignore: inference_failure_on_function_invocation
                onTap: () => showModalBottomSheet(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  context: context,
                  builder: (context) => OnlineStoreBottomSheet(
                    storeUrl: 'connect.duxbe.com/${ref.watch(businessNotifierProvider)?.businessId}',
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.only(
                    left: 14,
                    right: 6,
                    top: 15,
                    bottom: 15,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xff25CCAC).withOpacity(.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xff25CCAC)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        context.l10n.goToOnlineStore,
                        style: AppText.mediumB.copyWith(color: const Color(0xff25CCAC)),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xff25CCAC), size: 16),
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  Row(
                    children: [
                      DashboardMetricMobile(
                        icon: Assets.icons.customerDash,
                        title: context.l10n.newCustomers,
                        timePeriod: '30 Days',
                        price: '${dashboardProvider.dashboardData.newCustomersPast30Days}',
                        color: AppColors.customersCard,
                      ),
                      const SizedBox(width: 10),
                      DashboardMetricMobile(
                        icon: Assets.icons.dailySales,
                        title: context.l10n.dailySales,
                        price: '$currency ${dashboardProvider.dashboardData.dailySales}',
                        color: AppColors.dailySalesCard,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      DashboardMetricMobile(
                        icon: Assets.icons.dailySales,
                        title: context.l10n.totalSales,
                        price: '$currency ${dashboardProvider.dashboardData.totalIncomesCurrentFiscalYear}',
                        color: AppColors.totalSaleCard,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      DashboardMetricMobile(
                        icon: Assets.icons.dailySales,
                        title: context.l10n.totalPurchases,
                        price: '$currency ${dashboardProvider.dashboardData.totalExpensesCurrentFiscalYear}',
                        color: AppColors.totalPurchaseCard,
                      ),
                    ],
                  ),
                ],
              ),
              if (dashboardProvider.dashboardData.lowStockItems.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.lowStocks,
                      style: AppText.xLargeSB.copyWith(
                        color: AppColors.red,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.pushNamed(AppRouter.currentStockReport);
                      },
                      child: Text(
                        context.l10n.viewAllStocks,
                        style: AppText.mediumSB.copyWith(color: AppColors.primaryColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const LowStocksWidgetMobile(),
              ],
              if (dashboardProvider.dashboardData.itemCategoryStatistics.isNotEmpty) ...[
                const SizedBox(height: 10),
                CategoryStatusContainer(
                  stats: dashboardProvider.dashboardData.itemCategoryStatistics,
                ),
              ],
              if (_pagingController.itemList?.isEmpty ?? false)
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(top: 12),
                  decoration: AppStyles.boxDecoration,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 40),
                        child: Assets.icons.emptyBox.svg(width: 200, height: 130),
                      ),
                      Text(
                        AppRouter.l10n.noRecentTransaction,
                        style: AppText.mediumB.copyWith(color: AppColors.black),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        context.l10n.pleaseAddProductsFirst,
                        style: AppText.mediumN.copyWith(color: AppColors.primaryColor),
                      ),
                      const SizedBox(height: 47),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              onPress: () {
                                context.pushNamed(AppRouter.createItem);
                              },
                              label: Text(context.l10n.addItem),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              else ...[
                const SizedBox(height: 10),
                Text(
                  'Recent Transactions',
                  style: AppText.xLargeSB.copyWith(color: AppColors.black),
                ),
                const SizedBox(height: 10),
                PagedListView<int, SaleView>(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  pagingController: _pagingController,
                  builderDelegate: PagedChildBuilderDelegate<SaleView>(
                    itemBuilder: (context, item, index) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.saleInvoice),
                      subtitle: Text(item.saleDate.toFullFormat),
                      trailing: Text(item.totalAmount.toString()),
                    ),
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}
