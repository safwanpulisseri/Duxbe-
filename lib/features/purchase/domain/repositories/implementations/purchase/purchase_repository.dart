import 'dart:convert';
import 'dart:developer';

import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/features/purchase/purchase.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'purchase_repository.g.dart';

@Riverpod(keepAlive: true)
IPurchaseRepository purchaseRepo(PurchaseRepoRef ref) => PurchaseRepository(ref);

class PurchaseRepository implements IPurchaseRepository {
  PurchaseRepository(this.ref) : _supabaseClient = ref.watch(supabaseProvider);
  final PurchaseRepoRef ref;
  final SupabaseClient _supabaseClient;

  @override
  Future<PurchaseView> createPurchaseTransaction(PurchasePageData data) async {
    try {
      String? url;
      if (data.file != null) {
        final businessId = ref.read(businessNotifierProvider)!.businessId;
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        url = await ref.read(supabaseStorageProvider).uploadPlatformFile(
              businessId: businessId,
              fileName: '$fileName${data.file!.extension != null ? '.${data.file!.extension}' : ''}',
              filePath: 'purchase_invoice',
              file: data.file!,
            );
      }

      final business = ref.read(businessNotifierProvider);
      log(
        JsonEncoder.withIndent(' ' * 2).convert(
          data
              .copyWith(
                businessId: business!.businessId,
                attachment: url,
              )
              .toCreateModel()
              .toJson(),
        ),
      );
      return await _supabaseClient.rpc<Map<String, dynamic>>(
        RPCConstants.createPurchase,
        params: {
          'p_purchase_json': data
              .copyWith(
                businessId: business.businessId,
                attachment: url,
              )
              .toCreateModel()
              .toJson()
            ..addAll({
              'org_id': business.orgId,
            }),
        },
      ).then(PurchaseView.fromJson);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<void> deletePurchaseTransaction(String purchaseId) {
    throw UnimplementedError();
  }

  @override
  Future<PurchaseView?> getPurchaseWithId({required String purchaseId}) async {
    try {
      return await _supabaseClient
          .from(DbConstants.purchaseView)
          .select()
          .eq('purchase_id', purchaseId)
          .single()
          .withConverter(PurchaseView.fromJson);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<PaginatedResponse<PurchaseView>> getPurchases({
    required int pageSize,
    required int pageNumber,
    String query = '',
    String? supplierId,
    bool? paidOrDueList,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final businessId = ref.read(businessNotifierProvider)?.businessId;
      if (businessId == null) return PaginatedResponse.empty();
      final offset = (pageNumber - 1) * pageSize;
      var queryBuilder = _supabaseClient
          .from(DbConstants.purchaseView)
          .select()
          .or('purchase_invoice.ilike.%$query%,supplier->>name.ilike.%$query%,invoice_no.ilike.%$query%')
          .eq('business_id', businessId);

      if (supplierId != null) queryBuilder = queryBuilder.eq('supplier_id', supplierId);
      if (paidOrDueList != null) {
        if (!paidOrDueList) {
          queryBuilder = queryBuilder.gt('due_amount', 0);
        } else {
          queryBuilder = queryBuilder.lte('due_amount', 0);
        }
      }
      if (fromDate != null) {
        queryBuilder = queryBuilder.gte('purchase_date', fromDate.toIso8601String());
      }
      if (toDate != null) {
        queryBuilder = queryBuilder.lte('purchase_date', toDate.toIso8601String());
      }

      final response =
          await queryBuilder.range(offset, pageSize + offset - 1).order('created_at').count(CountOption.exact);
      return PaginatedResponse(
        data: response.data.map(PurchaseView.fromJson).toList(),
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
  Future<List<CustomField>> getCustomFields() async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      final response =
          await _supabaseClient.from(DbConstants.purchaseCustomFieldDefinitions).select().eq('business_id', businessId);
      return response.map(CustomField.fromJson).toList();
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<List<PurchaseView>> getDuePurchasesWithSupplierId({required String supplierId, String query = ''}) async {
    try {
      return await _supabaseClient
          .from(DbConstants.purchaseView)
          .select()
          .eq('supplier_id', supplierId)
          .gt('due_amount', 0)
          .ilike('purchase_invoice', '%$query%')
          .order('created_at', ascending: false)
          .limit(100)
          .withConverter((data) => data.map(PurchaseView.fromJson).toList());
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<void> settlePurchase({
    required String purchaseId,
    required double amount,
    required PaymentMode mode,
    required DateTime date,
    required String supplierId,
  }) async {
    try {
      final business = ref.read(businessNotifierProvider);
      log(
        JsonEncoder.withIndent(' ' * 2).convert(
          {
            'p_purchase_id': purchaseId,
            'p_amount': amount,
            'p_mode': mode.name,
            'p_business_id': business!.businessId,
            'p_date': date.toIso8601String(),
            'p_supplier_id': supplierId,
          },
        ),
      );
      await _supabaseClient.rpc<void>(
        RPCConstants.settlePurchasePayment,
        params: {
          'p_purchase_id': purchaseId,
          'p_amount': amount,
          'p_payment_mode': mode.name,
          'p_payment_date': date.toIso8601String(),
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
  Future<String> getNextPurchaseReturnCode() async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      final response = await _supabaseClient.rpc<String>(
        RPCConstants.getNextPurchaseReturnCode,
        params: {'business_id': businessId},
      );
      return response;
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<PurchaseReturn?> getPurchaseReturnWithId({required String purchaseReturnId}) async {
    try {
      return await _supabaseClient
          .from(DbConstants.vPurchaseReturns)
          .select()
          .eq('return_id', purchaseReturnId)
          .single()
          .withConverter(PurchaseReturn.fromJson);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<PaginatedResponse<PurchaseReturn>> getPurchaseReturns({
    required int pageSize,
    required int pageNumber,
    String query = '',
  }) async {
    try {
      final businessId = ref.read(businessNotifierProvider)?.businessId;
      if (businessId == null) return PaginatedResponse.empty();
      final offset = (pageNumber - 1) * pageSize;
      final response = await _supabaseClient
          .from(DbConstants.vPurchaseReturns)
          .select()
          .or('return_invoice.ilike.%$query%')
          .eq('business_id', businessId)
          .range(offset, pageSize + offset - 1)
          .count(CountOption.exact);
      return PaginatedResponse(
        data: response.data.map(PurchaseReturn.fromJson).toList(),
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
  Future<void> createPurchaseReturnTransaction(CreatePurchaseReturn data) async {
    try {
      await _supabaseClient.rpc<void>(
        RPCConstants.createPurchaseReturn,
        params: {'p_data': data.toJson()},
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
  Future<List<PurchaseAudit>> getPurchaseAudits(String purchaseId) async {
    try {
      final businessId = ref.read(businessNotifierProvider)?.businessId;
      if (businessId == null) return [];

      final response = await _supabaseClient.from(DbConstants.purchaseAudits).select().eq('purchase_id', purchaseId);

      return response.map(PurchaseAudit.fromJson).toList();
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }
}
