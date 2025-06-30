import 'dart:convert';

import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/staffs/staffs.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'staff_roles_repository.g.dart';

@Riverpod(keepAlive: true)
IStaffRolesRepository staffRolesRepo(StaffRolesRepoRef ref) => StaffRolesRepository(ref);

class StaffRolesRepository implements IStaffRolesRepository {
  StaffRolesRepository(this.ref) : _supabaseClient = ref.watch(supabaseProvider);

  final StaffRolesRepoRef ref;
  final SupabaseClient _supabaseClient;

  @override
  Future<void> deleteStaffRole(String staffRoleId) async {
    try {
      await _supabaseClient.from(DbConstants.employeeRoles).delete().eq('employee_role_id', staffRoleId);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<PaginatedResponse<StaffRole>> getStaffRoles({
    required int pageSize,
    required int pageNumber,
    String query = '',
  }) async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      final offset = (pageNumber - 1) * pageSize;
      final response = await _supabaseClient
          .from(DbConstants.employeeRoles)
          .select()
          .or('business_id.eq.$businessId,business_id.is.null')
          .ilike('name', '%$query%')
          .range(offset, pageSize + offset - 1)
          .count(CountOption.exact);
      return PaginatedResponse(
        data: response.data.map(StaffRole.fromJson).toList(),
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
  Future<StaffRole?> getStaffRoleWithId({required String staffRoleId}) async {
    try {
      return await _supabaseClient
          .from(DbConstants.employeeRoles)
          .select()
          .eq('employee_role_id', staffRoleId)
          .single()
          .withConverter(StaffRole.fromJson);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<List<Module>> getRolePermissions({String? staffRoleId}) async {
    try {
      final response = await _supabaseClient.rpc<PostgrestList>(
        RPCConstants.getRolePermissions,
        params: {'role_id': staffRoleId},
      );
      return response.map(Module.fromJson).toList();
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<void> updateUserRole({
    required String userRoleDetails,
  }) async {
    try {
      final _ = await _supabaseClient.rpc<void>(
        RPCConstants.upsertEmployeeRole,
        params: {
          'employee_role_json': {
            ...jsonDecode(userRoleDetails) as Map<String, dynamic>,
            'business_id': ref.read(businessNotifierProvider)!.businessId,
          },
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

  @override
  Future<bool> checkUniqueEmployeeRoleName({
    required String employeeRoleName,
  }) async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      return (await _supabaseClient.from(DbConstants.employeeRoles).select().or('name.eq.$employeeRoleName').eq('business_id', businessId)).isEmpty;
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }
}
