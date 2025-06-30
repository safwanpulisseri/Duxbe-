import 'package:duxbe/features/reports/reports.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'due_report_mobile.dart';
export 'due_report_web.dart';

class DueReportScreen extends ConsumerWidget {
  const DueReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: ResponsiveWidget(
        smallScreen: DueReportScreenMobile(),
        largeScreen: DueReportScreenWeb(),
      ),
    );
  }
}
