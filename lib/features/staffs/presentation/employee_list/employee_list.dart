import 'package:duxbe/features/staffs/staffs.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'employee_list_mobile.dart';
export 'employee_list_web.dart';

class EmployeeListScreen extends ConsumerWidget {
  const EmployeeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: ResponsiveWidget(
        smallScreen: EmployeeListScreenMobile(),
        largeScreen: EmployeeListScreenWeb(),
      ),
    );
  }
}
