import 'package:duxbe/features/reports/reports.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'reports_mobile.dart';
export 'reports_web.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: ResponsiveWidget(
        smallScreen: ReportsScreenMobile(),
        largeScreen: ReportsScreenWeb(),
      ),
    );
  }
}
