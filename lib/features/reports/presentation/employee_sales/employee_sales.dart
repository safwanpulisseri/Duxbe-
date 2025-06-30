import 'package:duxbe/features/reports/reports.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'employee_sales_mobile.dart';
export 'employee_sales_web.dart';

class EmployeeSalesScreen extends ConsumerWidget {
  const EmployeeSalesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: ResponsiveWidget(
        smallScreen: EmployeeSalesScreenMobile(),
        largeScreen: EmployeeSalesScreenWeb(),
      ),
    );
  }
}
