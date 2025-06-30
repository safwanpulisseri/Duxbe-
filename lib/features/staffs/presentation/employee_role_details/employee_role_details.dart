import 'package:duxbe/features/staffs/staffs.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'employee_role_details_mobile.dart';
export 'employee_role_details_web.dart';

class EmployeeRoleDetailsScreen extends ConsumerWidget {
  const EmployeeRoleDetailsScreen({super.key, this.employeeRoleId});
  final String? employeeRoleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ref.watch(employeeRoleProvider(employeeRoleId)).when(
            data: (employeeRole) => ResponsiveWidget(
              smallScreen: EmployeeRoleDetailsScreenMobile(employeeRole: employeeRole),
              largeScreen: EmployeeRoleDetailsScreenWeb(employeeRole: employeeRole),
            ),
            error: (error, stackTrace) => Center(child: Text(error.toString())),
            loading: Loader.new,
          ),
    );
  }
}
