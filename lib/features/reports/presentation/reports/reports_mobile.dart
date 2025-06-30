import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';

class ReportsScreenMobile extends ConsumerStatefulWidget {
  const ReportsScreenMobile({super.key});

  @override
  ConsumerState<ReportsScreenMobile> createState() => _ReportsScreenMobileState();
}

class _ReportsScreenMobileState extends ConsumerState<ReportsScreenMobile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(context.l10n.reports),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        children: [
          _ReportTile(
            icon: Assets.icons.dailyTransactionReport.svg(
              height: 25,
              width: 25,
              colorFilter: const ColorFilter.mode(AppColors.black, BlendMode.srcIn),
            ),
            onTap: () {
              context.pushNamed(AppRouter.dailyTransactions);
            },
            title: context.l10n.dailyTransaction,
          ),
          _ReportTile(
            icon: Assets.icons.saleReport.svg(
              height: 25,
              width: 25,
              colorFilter: const ColorFilter.mode(AppColors.black, BlendMode.srcIn),
            ),
            onTap: () {
              context.pushNamed(AppRouter.salesReport);
            },
            title: context.l10n.sale,
          ),
          _ReportTile(
            icon: Assets.icons.purchaseReport.svg(
              height: 25,
              width: 25,
              colorFilter: const ColorFilter.mode(AppColors.black, BlendMode.srcIn),
            ),
            onTap: () {
              context.pushNamed(AppRouter.purchaseReport);
            },
            title: context.l10n.purchase,
          ),
          _ReportTile(
            icon: Assets.icons.dueReport.svg(
              height: 25,
              width: 25,
              colorFilter: const ColorFilter.mode(AppColors.black, BlendMode.srcIn),
            ),
            onTap: () {
              context.pushNamed(AppRouter.dueReport);
            },
            title: context.l10n.due,
          ),
          _ReportTile(
            icon: Assets.icons.stockReport.svg(
              height: 25,
              width: 25,
              colorFilter: const ColorFilter.mode(AppColors.black, BlendMode.srcIn),
            ),
            onTap: () {
              context.pushNamed(AppRouter.currentStockReport);
            },
            title: context.l10n.currentStock,
          ),
          _ReportTile(
            icon: Assets.icons.teamReport.svg(
              height: 25,
              width: 25,
              colorFilter: const ColorFilter.mode(AppColors.black, BlendMode.srcIn),
            ),
            onTap: () {
              context.pushNamed(AppRouter.teamSalesReport);
            },
            title: context.l10n.teamSalesReport,
          ),
        ],
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final Widget icon;
  final void Function() onTap;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: AppStyles.boxDecoration.borderRadius!.resolve(TextDirection.ltr),
        splashColor: Colors.transparent,
        onTap: onTap,
        child: Ink(
          decoration: AppStyles.boxDecoration,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.lightBlue,
                  ),
                  child: icon,
                ),
                const SizedBox(width: 15),
                Text(title, style: AppText.mediumSB.copyWith(color: AppColors.black)),
                const Spacer(),
                Transform.scale(
                  scale: 1.5,
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.brandViolet,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
