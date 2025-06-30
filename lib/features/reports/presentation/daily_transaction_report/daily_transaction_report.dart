import 'package:duxbe/features/reports/reports.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'daily_transaction_report_mobile.dart';
export 'daily_transaction_report_web.dart';

class DailyTransactionReportScreen extends ConsumerWidget {
  const DailyTransactionReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: ResponsiveWidget(
        smallScreen: DailyTransactionReportScreenMobile(),
        largeScreen: DailyTransactionReportScreenWeb(),
      ),
    );
  }
}
