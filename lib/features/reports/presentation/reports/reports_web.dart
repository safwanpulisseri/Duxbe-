import 'package:duxbe/features/reports/reports.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';

class ReportsScreenWeb extends ConsumerStatefulWidget {
  const ReportsScreenWeb({super.key});

  @override
  ConsumerState<ReportsScreenWeb> createState() => _ReportsScreenWebState();
}


class _ReportsScreenWebState extends ConsumerState<ReportsScreenWeb> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    final tabIndex = GoRouter.of(context).routerDelegate.currentConfiguration.uri.queryParameters['tab_index'];
    super.build(context);
    final tabs = {
      context.l10n.sale: const SalesReportScreen(),
      context.l10n.purchase: const PurchaseReportScreen(),
      context.l10n.due: const DueReportScreen(),
      context.l10n.currentStock: const StockReportScreen(),
      context.l10n.dailyTransaction: const DailyTransactionReportScreen(),
      context.l10n.employeeSales: const EmployeeSalesScreen(),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: DefaultTabController(
        initialIndex: int.tryParse(tabIndex ?? '0') ?? 0,
        length: tabs.length,
        child: Column(
          children: [
            TabBar(
              indicator: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(8)),
              labelStyle: AppText.largeSB.copyWith(color: AppColors.white),
              splashFactory: NoSplash.splashFactory,
              splashBorderRadius: BorderRadius.circular(8),
              unselectedLabelStyle: AppText.largeSB.copyWith(color: AppColors.stormyBlue),
              tabAlignment: TabAlignment.fill,
              overlayColor: WidgetStateColor.resolveWith(
                (states) => AppColors.lightPurple,
              ),
              tabs: tabs.keys.map((e) => Tab(text: e)).toList(),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                children: tabs.values.toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
