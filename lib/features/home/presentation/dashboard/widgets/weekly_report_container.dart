import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';

class WeeklyReportContainer extends StatelessWidget {
  const WeeklyReportContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 24),
      decoration: AppStyles.boxDecoration,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.hereIsYourWeeklyOverviewReport,
                  style: AppText.largeN.copyWith(color: AppColors.greyText),
                ),
                const SizedBox(height: 14),
                AppButton(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  height: 36,
                  style: ButtonStyles.secondary,
                  onPress: () {
                    context.goNamed(AppRouter.reports);
                  },
                  label: Text(context.l10n.viewReport),
                ),
              ],
            ),
          ),
          Expanded(child: Assets.images.reportCard.image(height: 100)),
        ],
      ),
    );
  }
}
