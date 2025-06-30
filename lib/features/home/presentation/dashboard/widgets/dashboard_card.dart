import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:hancod_theme/hancod_theme.dart';

class DashboardMetric extends StatelessWidget {
  const DashboardMetric({
    required this.icon,
    required this.title,
    required this.price,
    super.key,
    this.timePeriod,
  });
  final SvgGenImage icon;
  final String title;
  final String price;
  final String? timePeriod;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: AppStyles.boxDecoration,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: AppText.mediumSB),
                    if (timePeriod != null)
                      Opacity(
                        opacity: .3,
                        child: Text(
                          ' $timePeriod',
                          style: AppText.mediumN,
                        ),
                      ),
                  ],
                ),
                Text(price, style: AppText.heading5),
              ],
            ),
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(14),
              child: icon.svg(height: 40, width: 40),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardMetricMobile extends StatelessWidget {
  const DashboardMetricMobile({
    required this.icon,
    required this.title,
    required this.price,
    super.key,
    this.timePeriod,
    this.color,
  });
  final SvgGenImage icon;
  final String title;
  final String price;
  final String? timePeriod;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: const Color(0xffEAEAF6)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: icon.svg(height: 14, colorFilter: const ColorFilter.mode(AppColors.black, BlendMode.srcIn)),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    style: AppText.smallSB.copyWith(overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    price,
                    style: AppText.largeB,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (timePeriod != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: color,
                    ),
                    child: Text(
                      ' $timePeriod',
                      style: AppText.xSmallM.copyWith(
                        color: color?.withRed(100),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
