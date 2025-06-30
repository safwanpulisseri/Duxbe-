import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/home/home.dart';
import 'package:duxbe/features/home/presentation/dashboard/widgets/category_stats.dart';
import 'package:duxbe/features/home/presentation/dashboard/widgets/dashboard_card.dart';
import 'package:duxbe/features/home/presentation/dashboard/widgets/low_stocks.dart';
import 'package:duxbe/features/home/presentation/dashboard/widgets/top_selling_product.dart';
import 'package:duxbe/features/home/presentation/dashboard/widgets/transaction_card.dart';
import 'package:duxbe/features/home/presentation/dashboard/widgets/weekly_report_container.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreenWeb extends ConsumerWidget {
  const DashboardScreenWeb({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardProvider = ref.watch(homeNotifierProvider);
    final currency = ref.watch(currencyProvider);

    return switch (ref.watch(authNotifierProvider).status) {
      AuthStatus.success => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DashboardMetric(
                  icon: Assets.icons.dailySales,
                  title: context.l10n.dailySales,
                  price: '$currency ${dashboardProvider.dashboardData.dailySales}',
                ),
                const SizedBox(width: 20),
                DashboardMetric(
                  icon: Assets.icons.dashSales,
                  title: context.l10n.totalSales,
                  price: '$currency ${dashboardProvider.dashboardData.totalIncomesCurrentFiscalYear}',
                ),
                const SizedBox(width: 20),
                DashboardMetric(
                  icon: Assets.icons.dashPurchases,
                  title: context.l10n.totalPurchases,
                  price: '$currency ${dashboardProvider.dashboardData.totalExpensesCurrentFiscalYear}',
                ),
                const SizedBox(width: 20),
                DashboardMetric(
                  icon: Assets.icons.dashNewCustomers,
                  title: context.l10n.newCustomers,
                  timePeriod: '30 Dadfdys',
                  price: '${dashboardProvider.dashboardData.newCustomersPast30Days}',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Expanded(
                    flex: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(child: TopSellingProductWidget()),
                              SizedBox(width: 20),
                              Expanded(child: LowStocksWidget()),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Expanded(
                          child: TransactionCard(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const WeeklyReportContainer(),
                        const SizedBox(height: 20),
                        if (dashboardProvider.dashboardData.itemCategoryStatistics.isNotEmpty)
                          IntrinsicHeight(
                            child: CategoryStatusContainer(
                              stats: dashboardProvider.dashboardData.itemCategoryStatistics,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      _ => const SizedBox(),
    };
  }
}
