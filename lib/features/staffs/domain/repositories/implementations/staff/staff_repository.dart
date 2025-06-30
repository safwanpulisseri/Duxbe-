import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/staffs/staffs.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'staff_repository.g.dart';

@Riverpod(keepAlive: true)
IStaffRepository staffRepo(StaffRepoRef ref) => StaffRepository(ref);

class StaffRepository implements IStaffRepository {
  StaffRepository(this.ref) : _supabaseClient = ref.watch(supabaseProvider);

  final StaffRepoRef ref;
  final SupabaseClient _supabaseClient;

  @override
  Future<void> createEmployee(Map<String, dynamic> employee) async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      final orgId = ref.read(businessNotifierProvider)!.orgId;

      final usersWithEmail = await _supabaseClient
          .from(DbConstants.employeeView)
          .select()
          .or('email.eq.${employee['email']},phone.eq.${employee['phone'].toString().replaceAll('+', '')}');
      if (usersWithEmail.isEmpty) {
        await _supabaseClient.functions.invoke(
          'employees/create-employee',
          body: Map<String, dynamic>.from(employee)
            ..addEntries([MapEntry('business_id', businessId), MapEntry('org_id', orgId)]),
        );
      } else {
        throw AppException(AppRouter.l10n.thisEmailIsAlreadyRegistered);
      }
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<void> updateEmployee(Map<String, dynamic> employee) async {
    try {
      // employee only has name, roles
      await _supabaseClient.from(DbConstants.employees).update(
        {
          'name': employee['name'],
        },
      ).eq(
        'employee_id',
        employee['employee_id'].toString(),
      );
      await _supabaseClient.from(DbConstants.rolesOfEmployees).delete().eq(
            'employee_id',
            employee['employee_id'].toString(),
          );
      for (final role in employee['roles'] as List<String>) {
        await _supabaseClient.from(DbConstants.rolesOfEmployees).insert({
          'employee_id': employee['employee_id'].toString(),
          'employee_role_id': role,
        });
      }
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<void> deleteEmployee(String employeeId) async {
    try {
      return await _supabaseClient.from(DbConstants.employees).delete().eq('employee_id', employeeId);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<EmployeeModel> getEmployeeFromId({required String employeeId}) async {
    try {
      return await _supabaseClient
          .from(DbConstants.employeeView)
          .select()
          .eq('employee_id', employeeId)
          .single()
          .withConverter(EmployeeModel.fromJson);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<PaginatedResponse<EmployeeModel>> getEmployees({
    required int pageSize,
    required int pageNumber,
    String query = '',
    bool fromOtherBranch = false,
  }) async {
    try {
      final business = ref.read(businessNotifierProvider);
      final offset = (pageNumber - 1) * pageSize;
      var queryBuilder = _supabaseClient
          .from(DbConstants.employeeView)
          .select('*,organizations!employees_org_id_fkey(*)')
          .or('name.ilike.%$query%,email.ilike.%$query%,phone.ilike.%$query%');
      if (fromOtherBranch) {
        queryBuilder = queryBuilder.not('business_ids', 'cs', [business!.businessId]).eq('org_id', business.orgId);
      } else {
        queryBuilder = queryBuilder.contains('business_ids', [business!.businessId]);
      }

      final response = await queryBuilder.range(offset, pageSize + offset - 1).count(CountOption.exact);
      return PaginatedResponse(
        data: response.data.map(EmployeeModel.fromJson).toList(),
        count: response.count,
      );
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<void> updateEmployeeBranchAccess(String employeeId) async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      final _ = await _supabaseClient
          .from(DbConstants.employeeBranchAccess)
          .upsert({'employee_id': employeeId, 'business_id': businessId});
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<void> removeEmployeeBranchAccess(String employeeId) async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      final _ = await _supabaseClient
          .from(DbConstants.employeeBranchAccess)
          .delete()
          .eq('employee_id', employeeId)
          .eq('business_id', businessId);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<void> resetEmployeePassword(String email) async {
    try {
      await _supabaseClient.functions.invoke(
        'employees/reset-employee-password',
        body: {
          'email': email,
        },
      );
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }
}
