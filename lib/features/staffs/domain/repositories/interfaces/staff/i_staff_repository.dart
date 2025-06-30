import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/shared/shared.dart';

abstract class IStaffRepository {
  Future<PaginatedResponse<EmployeeModel>> getEmployees({
    required int pageSize,
    required int pageNumber,
    String query = '',
    bool fromOtherBranch = false,
  });
  Future<EmployeeModel> getEmployeeFromId({required String employeeId});
  Future<void> createEmployee(Map<String, dynamic> employee);
  Future<void> deleteEmployee(String employeeId);
  Future<void> resetEmployeePassword(String email);
  Future<void> updateEmployee(Map<String, dynamic> employee);
  Future<void> updateEmployeeBranchAccess(String employeeId);
  Future<void> removeEmployeeBranchAccess(String employeeId);
}
