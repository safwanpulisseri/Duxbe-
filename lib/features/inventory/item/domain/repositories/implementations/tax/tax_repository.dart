import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'tax_repository.g.dart';

@Riverpod(keepAlive: true)
ITaxRepository taxRepo(TaxRepoRef ref) => TaxRepository(ref);

class TaxRepository implements ITaxRepository {
  TaxRepository(this.ref) : _supabaseClient = ref.watch(supabaseProvider);

  final TaxRepoRef ref;
  final SupabaseClient _supabaseClient;

  @override
  Future<void> deleteTax(String taxId) async {
    try {
      return await _supabaseClient.from(DbConstants.taxes).delete().eq('tax_id', taxId);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<Tax?> getTaxWithId({required String taxId}) async {
    try {
      return await _supabaseClient.from(DbConstants.taxes).select().eq('tax_id', taxId).single().withConverter(Tax.fromJson);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<PaginatedResponse<Tax>> getTaxes({
    required int pageSize,
    required int pageNumber,
    String query = '',
    String? businessId,
  }) async {
    try {
      final business = businessId ?? ref.read(businessNotifierProvider)!.businessId;
      final offset = (pageNumber - 1) * pageSize;
      final response = await _supabaseClient
          .from(DbConstants.taxes)
          .select()
          .ilike('name', '%$query%')
          .eq('business_id', business)
          .range(offset, pageSize + offset - 1)
          .count(CountOption.exact);
      return PaginatedResponse(
        data: response.data.map(Tax.fromJson).toList(),
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
  Future<Tax> upsertTax(Tax tax) async {
    try {
      return await _supabaseClient.from(DbConstants.taxes).upsert(tax.toJson()).select().single().withConverter(Tax.fromJson);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }
}
