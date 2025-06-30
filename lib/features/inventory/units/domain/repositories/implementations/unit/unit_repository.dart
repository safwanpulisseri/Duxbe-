import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'unit_repository.g.dart';

@Riverpod(keepAlive: true)
IUnitRepository unitRepo(UnitRepoRef ref) => UnitRepository(ref);

class UnitRepository implements IUnitRepository {
  UnitRepository(this.ref) : _supabaseClient = ref.watch(supabaseProvider);

  final UnitRepoRef ref;
  final SupabaseClient _supabaseClient;

  @override
  Future<void> deleteUnit(String unitId) async {
    try {
      return await _supabaseClient.from(DbConstants.units).delete().eq('unit_id', unitId);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<Unit?> getUnitWithId({required String unitId}) async {
    try {
      return await _supabaseClient.from(DbConstants.units).select().eq('unit_id', unitId).single().withConverter(Unit.fromJson);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<PaginatedResponse<Unit>> getUnits({
    required int pageSize,
    required int pageNumber,
    String query = '',
  }) async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      final offset = (pageNumber - 1) * pageSize;
      final response = await _supabaseClient
          .from(DbConstants.units)
          .select()
          .ilike('name', '%$query%')
          .eq('business_id', businessId)
          .range(offset, pageSize + offset - 1)
          .count(CountOption.exact);
      return PaginatedResponse(
        data: response.data.map(Unit.fromJson).toList(),
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
  Future<Unit> upsertUnit(Unit unit) async {
    try {
      final business = ref.read(businessNotifierProvider)!;
      return await _supabaseClient
          .from(DbConstants.units)
          .upsert(
            unit
                .copyWith(
                  businessId: business.businessId,
                  orgId: business.orgId,
                )
                .toJson(),
          )
          .select()
          .single()
          .withConverter(Unit.fromJson);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }
}
