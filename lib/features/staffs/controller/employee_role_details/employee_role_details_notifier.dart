import 'dart:async';
import 'dart:convert';

import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/staffs/staffs.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'employee_role_details_notifier.freezed.dart';
part 'employee_role_details_notifier.g.dart';
part 'employee_role_details_state.dart';

@Riverpod(keepAlive: false)
class EmployeeRoleDetailsNotifier extends _$EmployeeRoleDetailsNotifier {
  late IStaffRolesRepository _staffRoleRepository;

  @override
  EmployeeRoleDetailsState build({StaffRole? role}) {
    _staffRoleRepository = ref.watch(staffRolesRepoProvider);
    state = EmployeeRoleDetailsState.initial();
    getModules();
    return state;
  }

  Future<void> getModules() async {
    try {
      state = state.copyWith(status: EmployeeRoleDetailsStatus.loading);
      final modules = await _staffRoleRepository.getRolePermissions(
        staffRoleId: role?.employeeRoleId,
      );
      state = state.copyWith(
        status: EmployeeRoleDetailsStatus.success,
        modules: modules,
      );
    } catch (e) {
      state = state.copyWith(
        status: EmployeeRoleDetailsStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
    }
  }

  Future<void> saveRole({required String roleName}) async {
    try {
      state = state.copyWith(status: EmployeeRoleDetailsStatus.loading);
      await _staffRoleRepository.updateUserRole(
        userRoleDetails: jsonEncode({
          'employee_role_id': role?.employeeRoleId,
          'name': roleName,
          'description': role?.description,
          'permissions': state.modules,
        }),
      );

      ref.read(employeeRoleNotifierProvider.notifier).setFilter(pageNumber: 1);
      state = state.copyWith(status: EmployeeRoleDetailsStatus.success);
    } catch (e) {
      state = state.copyWith(
        status: EmployeeRoleDetailsStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
    }
  }
}
