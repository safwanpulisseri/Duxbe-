import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/staffs/staffs.dart';
import 'package:duxbe/shared/shared.dart';

abstract class IStaffRolesRepository {
  Future<PaginatedResponse<StaffRole>> getStaffRoles({
    required int pageSize,
    required int pageNumber,
    String query = '',
  });
  Future<void> deleteStaffRole(String staffRoleId);
  Future<StaffRole?> getStaffRoleWithId({required String staffRoleId});
  Future<List<Module>> getRolePermissions({String? staffRoleId});
  Future<void> updateUserRole({required String userRoleDetails});
  Future<bool> checkUniqueEmployeeRoleName({required String employeeRoleName});
}
