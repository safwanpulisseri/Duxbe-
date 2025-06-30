import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'brand_repository.g.dart';

@Riverpod(keepAlive: true)
IBrandRepository brandRepo(BrandRepoRef ref) => BrandRepository(ref);

class BrandRepository implements IBrandRepository {
  BrandRepository(this.ref) : _supabaseClient = ref.watch(supabaseProvider);
  final BrandRepoRef ref;
  final SupabaseClient _supabaseClient;

  @override
  Future<void> deleteBrand(String brandId) async {
    try {
      return await _supabaseClient.from(DbConstants.brands).delete().eq('brand_id', brandId);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<Brand?> getBrandWithId({required String brandId}) async {
    try {
      return await _supabaseClient.from(DbConstants.brands).select().eq('brand_id', brandId).single().withConverter(Brand.fromJson);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<PaginatedResponse<Brand>> getBrands({
    required int pageSize,
    required int pageNumber,
    String query = '',
  }) async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      final offset = (pageNumber - 1) * pageSize;
      final response = await _supabaseClient
          .from(DbConstants.brands)
          .select()
          .ilike('name', '%$query%')
          .eq('business_id', businessId)
          .range(offset, pageSize + offset - 1)
          .count(CountOption.exact);
      return PaginatedResponse(
        data: response.data.map(Brand.fromJson).toList(),
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
  Future<Brand> upsertBrand(Brand brand) async {
    try {
      final business = ref.read(businessNotifierProvider)!;
      return await _supabaseClient
          .from(DbConstants.brands)
          .upsert(
            brand
                .copyWith(
                  businessId: business.businessId,
                  orgId: business.orgId,
                )
                .toJson(),
          )
          .select()
          .single()
          .withConverter(Brand.fromJson);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }
}
