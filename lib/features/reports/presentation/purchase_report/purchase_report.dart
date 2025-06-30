import 'package:duxbe/features/reports/reports.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'purchase_report_mobile.dart';
export 'purchase_report_web.dart';

class PurchaseReportScreen extends ConsumerWidget {
  const PurchaseReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: ResponsiveWidget(
        smallScreen: PurchaseReportScreenMobile(),
        largeScreen: PurchaseReportScreenWeb(),
      ),
    );
  }
}
