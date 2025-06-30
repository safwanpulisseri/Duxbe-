import 'package:duxbe/features/home/home.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hancod_theme/hancod_theme.dart';

class CategoryStatusContainer extends StatelessWidget {
  const CategoryStatusContainer({required this.stats, super.key});

  final List<CategoryStat> stats;

  static List<Color> colors = [
    const Color(0xFF56CCF2),
    const Color(0xFFBB6BD9),
    const Color(0xFF28C76F),
    const Color(0xFFFFE66F),
    const Color(0xFFFF9F43),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 30,
        horizontal: 26,
      ),
      decoration: AppStyles.boxDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.categoryStatus,
                style: AppText.xLargeSB,
              ),
              Text(
                context.l10n.inLast30Days,
                style: AppText.mediumN.copyWith(
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: stats
                    .map(
                      (e) => PieChartSectionData(
                        color: colors[stats.indexWhere(
                              (en) => en.categoryName == e.categoryName,
                            ) %
                            5],
                        showTitle: false,
                        value: e.percentage,
                        radius: 40,
                      ),
                    )
                    .toList(),
                borderData: FlBorderData(show: false),
                // centerSpaceRadius: 60,
                sectionsSpace: 0,
              ),
            ),
          ),
          const SizedBox(height: 20),
          IfWrapper(
            condition: ResponsiveWidget.isLargeScreen(context),
            child: Column(
              children: [
                ...stats.map(
                  (e) => SizedBox(
                    height: 40,
                    child: Row(
                      children: [
                        Container(
                          decoration: ShapeDecoration(
                            shape: const CircleBorder(),
                            color: colors[stats.indexWhere(
                                      (en) => en.categoryName == e.categoryName,
                                    ) %
                                    colors.length]
                                .withOpacity(0.12),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            (e.iconInfo != null)
                                ? IconData(
                                    e.iconInfo!.code!,
                                    fontFamily: e.iconInfo!.family,
                                    fontPackage: e.iconInfo!.package,
                                  )
                                : const IconData(
                                    62602,
                                    fontFamily: 'CupertinoIcons',
                                    fontPackage: 'cupertino_icons',
                                  ),
                            color: colors[stats.indexWhere(
                                  (en) => en.categoryName == e.categoryName,
                                ) %
                                colors.length],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          e.categoryName,
                          style: AppText.xLargeN.copyWith(
                            color: AppColors.black,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${e.percentage.toStringAsFixed(2)}%',
                          style: AppText.mediumN.copyWith(
                            color: AppColors.greyText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            builder: (context, child) => Expanded(child: child),
          ),
        ],
      ),
    );
  }
}
