import 'package:duxbe/features/home/home.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';

class LowStocksWidget extends ConsumerWidget {
  const LowStocksWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardProvider = ref.watch(homeNotifierProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 26),
      decoration: AppStyles.boxDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.lowStocks,
                style: AppText.xLargeSB.copyWith(color: AppColors.red),
              ),
              TextButton(
                onPressed: () {
                  context.goNamed(AppRouter.reports,
                    queryParameters: {'tab_index': '3'},
                  );
                },
                child: Text(
                  context.l10n.viewAllStocks,
                  style:
                      AppText.mediumSB.copyWith(color: AppColors.primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (dashboardProvider.dashboardData.lowStockItems.isEmpty)
            Text(context.l10n.nA,
              style: AppText.mediumM.copyWith(color: AppColors.greyText),
            )
          else
            Column(
              children: [
                for (int index = 0; index < dashboardProvider.dashboardData.lowStockItems.length; index++) ...[
                  if (index > 0) const Divider(color: AppColors.divider),
                  Builder(
                    builder: (context) {
                      final product = dashboardProvider.dashboardData.lowStockItems[index];
                      final style = AppText.mediumM.copyWith(color: AppColors.greyText);
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: style,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${product.stockLeft}',
                            style: style,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class LowStocksWidgetMobile extends ConsumerWidget {
  const LowStocksWidgetMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardProvider = ref.watch(homeNotifierProvider);
    final itemCount = dashboardProvider.dashboardData.lowStockItems.length;
    final rows = (itemCount / 2).ceil();
    if (itemCount > 0) {
      return ColoredBox(
        color: AppColors.white,
        child: Table(
          border: TableBorder.all(
            // border: 1px solid #EAEAF6
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xffEAEAF6),
          ),
          children: [
            for (int i = 0; i < rows; i++)
              TableRow(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dashboardProvider
                              .dashboardData.lowStockItems[i * 2].name,
                          style: AppText.smallN,
                        ),
                        Text(
                          '${dashboardProvider.dashboardData.lowStockItems[i * 2].stockLeft}',
                          style: AppText.largeSB.copyWith(
                            color: AppColors.stormyBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i * 2 + 1 < itemCount)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dashboardProvider
                                .dashboardData.lowStockItems[i * 2 + 1].name,
                            style: AppText.smallN,
                          ),
                          Text(
                            '${dashboardProvider.dashboardData.lowStockItems[i * 2 + 1].stockLeft}',
                            style: AppText.largeSB.copyWith(
                              color: AppColors.stormyBlue,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                ],
              ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
