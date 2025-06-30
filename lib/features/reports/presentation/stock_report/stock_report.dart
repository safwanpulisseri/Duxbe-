import 'package:duxbe/features/reports/reports.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'stock_report_mobile.dart';
export 'stock_report_web.dart';

class StockReportScreen extends ConsumerWidget {
  const StockReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: ResponsiveWidget(
        smallScreen: StockReportScreenMobile(),
        largeScreen: StockReportScreenWeb(),
      ),
    );
  }
}
