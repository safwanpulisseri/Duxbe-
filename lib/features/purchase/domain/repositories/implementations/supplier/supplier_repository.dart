import 'dart:typed_data';

import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/purchase/purchase.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supplier_repository.g.dart';

@Riverpod(keepAlive: true)
ISupplierRepository supplierRepo(SupplierRepoRef ref) => SupplierRepository(ref);

class SupplierRepository implements ISupplierRepository {
  SupplierRepository(this.ref) : _supabaseClient = ref.watch(supabaseProvider);
  final SupplierRepoRef ref;
  final SupabaseClient _supabaseClient;

  @override
  Future<void> deleteSupplier(String supplierId) async {
    try {
      return await _supabaseClient.rpc(
        RPCConstants.archiveSupplier,
        params: {
          'p_supplier_id': supplierId,
          'p_business_id': ref.read(businessNotifierProvider)!.businessId,
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
  Future<Supplier?> getSupplierWithId({required String supplierId}) async {
    try {
      return await _supabaseClient
          .from(DbConstants.suppliers)
          .select()
          .eq('supplier_id', supplierId)
          .single()
          .withConverter(Supplier.fromJson);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<PaginatedResponse<Supplier>> getSuppliers({
    required int pageSize,
    required int pageNumber,
    String query = '',
  }) async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      final queryFiltered = query.replaceAll(RegExp('[^a-zA-Z0-9-]'), '');

      final offset = (pageNumber - 1) * pageSize;
      final response = await _supabaseClient
          .from(DbConstants.suppliers)
          .select()
          .or(
            'name.ilike.%$queryFiltered%,email.ilike.%$queryFiltered%,phone.ilike.%$queryFiltered%',
          )
          .eq('business_id', businessId)
          .eq('is_active', true)
          .range(offset, pageSize + offset - 1)
          .count(CountOption.exact);
      return PaginatedResponse(
        data: response.data.map(Supplier.fromJson).toList(),
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
  Future<Supplier> upsertSupplier(Supplier supplier, {dynamic image}) async {
    try {
      String? url;
      if (image is Uint8List) {
        final businessId = ref.read(businessNotifierProvider)!.businessId;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
        url = await ref.read(supabaseStorageProvider).uploadImage(
              businessId: businessId,
              fileName: fileName,
              filePath: 'supplier',
              file: image,
            );
      }

      final business = ref.read(businessNotifierProvider);
      final supplierId = await _supabaseClient.rpc<String>(
        RPCConstants.upsertSupplier,
        params: {
          'p_supplier_data': supplier
              .copyWith(
                businessId: business!.businessId,
                image: url,
                orgId: business.orgId,
              )
              .toJson(),
        },
      );
      return supplier.copyWith(supplierId: supplierId);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }
}
