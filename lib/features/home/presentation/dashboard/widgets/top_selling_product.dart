import 'package:duxbe/features/home/home.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';

class TopSellingProductWidget extends ConsumerWidget {
  const TopSellingProductWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardProvider = ref.watch(homeNotifierProvider);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 26),
      decoration: AppStyles.boxDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.topSellingProducts, style: AppText.xLargeSB),
          const SizedBox(height: 24),
          if (dashboardProvider.dashboardData.topSellingItems.isEmpty)
            Text(context.l10n.nA,
              style: AppText.mediumM.copyWith(color: AppColors.greyText),
            )
          else
            Column(
              children: [
                for (int index = 0; index < dashboardProvider.dashboardData.topSellingItems.length; index++) ...[
                  if (index > 0) const Divider(color: AppColors.divider),
                  Builder(
                    builder: (context) {
                      final product = dashboardProvider.dashboardData.topSellingItems[index];
                      final style = AppText.mediumM.copyWith(color: AppColors.greyText);
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Wrap the Text with an Expanded or Flexible widget to avoid overflow
                          Expanded(
                            child: Text(
                              product.name,
                              style: style,
                              overflow: TextOverflow.ellipsis, // Ensures the text doesn't overflow
                              maxLines: 3, // Limits the number of lines
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text('${product.soldCount}', style: style),
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
