import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/invoice/invoice.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
part 'credit_note_repository.g.dart';

@Riverpod(keepAlive: true)
ICreditNoteRepository creditNoteRepo(CreditNoteRepoRef ref) => CreditNoteRepository(ref);

class CreditNoteRepository implements ICreditNoteRepository {
  CreditNoteRepository(this.ref) : _supabaseClient = ref.watch(supabaseProvider);
  final CreditNoteRepoRef ref;
  final SupabaseClient _supabaseClient;

  @override
  Future<PaginatedResponse<Invoice>> getInvoices({
    required int pageSize,
    required int pageNumber,
    String query = '',
    String? customerId,
    bool? paidOrDueList,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final businessId = ref.read(businessNotifierProvider)?.businessId;
      if (businessId == null) return PaginatedResponse.empty();
      final offset = (pageNumber - 1) * pageSize;
      var queryBuilder = _supabaseClient
          .from(DbConstants.invoiceDetails)
          .select()
          .or('invoice_code.ilike.%$query%,customer->>name.ilike.%$query%')
          .eq('business_id', businessId);
      if (customerId != null) {
        queryBuilder = queryBuilder.eq('customer_id', customerId);
      }

      // if (fromDate != null) {
      //   queryBuilder = queryBuilder.gte('purchase_date', fromDate.toIso8601String());
      // }
      // if (toDate != null) {
      //   queryBuilder = queryBuilder.lte('purchase_date', toDate.toIso8601String());
      // }

      final response =
          await queryBuilder.range(offset, pageSize + offset - 1).order('invoice_created_at').count(CountOption.exact);
      return PaginatedResponse(
        data: response.data.map(Invoice.fromJson).toList(),
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
  Future<void> createCredit(Map<String, dynamic> credit) async {
    try {
      // The key here, 'p_credit_note_json', MUST match the argument name in your SQL function.
      await _supabaseClient.rpc<void>(
        RPCConstants.createCredit, // Or RPCConstants.createCredit
        params: {
          'p_credit_note_json': credit,
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
  Future<void> editCredit(Map<String, dynamic> credit, String creditId) async {
    try {
      // The key here, 'p_credit_note_json', MUST match the argument name in your SQL function.
      await _supabaseClient.rpc<void>(
        RPCConstants.editCreditNote, // Or RPCConstants.createCredit
        params: {
          'p_credit_note_id': creditId,
          'p_update_json': credit,
        },
      );
    } on PostgrestException catch (e) {
      debugPrint(e.message);
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<void> deleteCredit(String credit) async {
    try {
      await _supabaseClient.rpc<void>(
        RPCConstants.deleteCreditNote,
        params: {
          'p_credit_note_id': credit,
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
  Future<CreditNote?> getCreditWithId({required String creditId}) async {
    try {
      return await _supabaseClient
          .from(DbConstants.creditNoteDetails)
          .select()
          .eq('credit_note_id', creditId)
          .single()
          .withConverter(CreditNote.fromJson);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<PaginatedResponse<CreditNote>> getCreditDetails({
    required int pageSize,
    required int pageNumber,
    String? query,
  }) async {
    try {
      final businessId = ref.read(businessNotifierProvider)?.businessId;
      if (businessId == null) return PaginatedResponse.empty();
      final offset = (pageNumber - 1) * pageSize;
      var queryBuilder = _supabaseClient
          .from(DbConstants.creditNoteDetails)
          .select()
          // .neq('status', QuoteFormStatus.deleted.name)
          .eq('business_id', businessId);
      if (query != null && query.isNotEmpty) {
        // 2. Remove the trailing comma from the string
        final orFilter = 'credit_note_code.ilike.%$query%,customer->>name.ilike.%$query%';
        queryBuilder = queryBuilder.or(orFilter);
      }
      // if (fromDate != null) {
      //   queryBuilder = queryBuilder.gte('quote_date', fromDate.toIso8601String());
      // }
      // if (toDate != null) {
      //   queryBuilder = queryBuilder.lte('quote_date', toDate.toIso8601String());
      // }

      final response =
          await queryBuilder.range(offset, pageSize + offset - 1).order('created_at').count(CountOption.exact);
      return PaginatedResponse(
        data: response.data.map(CreditNote.fromJson).toList(),
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
  Future<PaginatedResponse<CreditNote>> getcreditNotesLists({
    required int pageSize,
    required int pageNumber,
    String? query,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final businessId = ref.read(businessNotifierProvider)?.businessId;
      if (businessId == null) return PaginatedResponse.empty();

      final offset = (pageNumber - 1) * pageSize;

      // Start with the base query
      var queryBuilder = _supabaseClient
          .from(DbConstants.creditNotesListView)
          .select()
          // .neq('status', QuoteFormStatus.deleted.name)
          .eq('business_id', businessId);

      // 1. Conditionally apply the search filter
      if (query != null && query.isNotEmpty) {
        // 2. Remove the trailing comma from the string
        final orFilter =
            'credit_note_code.ilike.%$query%,customer_name.ilike.%$query%,linked_invoice_code.ilike.%$query%';
        queryBuilder = queryBuilder.or(orFilter);
      }

      // Conditionally apply date filters
      if (fromDate != null) {
        queryBuilder = queryBuilder.gte('credit_note_date', fromDate.toIso8601String());
      }
      if (toDate != null) {
        queryBuilder = queryBuilder.lte('credit_note_date', toDate.toIso8601String());
      }

      // Execute the final query
      final response = await queryBuilder
          .range(offset, pageSize + offset - 1)
          .order(
            'created_at',
            ascending: false,
          ) // Usually you want the latest first
          .count(CountOption.exact);
      print(response.data);
      return PaginatedResponse(
        data: response.data.map(CreditNote.fromJson).toList(),
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
  Future<String> getNextCreditNotCode() async {
    try {
      final businessId = ref.read(businessNotifierProvider)?.businessId;
      final code = _supabaseClient.rpc<String>(
        RPCConstants.getNextCreditNoteCode,
        params: {
          'business_id': businessId,
        },
      );
      print(code);
      return code;
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<void> deleteRefund(String refund) async {
    try {
      await _supabaseClient.rpc<void>(
        RPCConstants.deleteRefund,
        params: {
          'p_refund_id': refund,
        },
      );
    } on PostgrestException catch (e) {
      debugPrint(e.code.toString());
      debugPrint(e.message);
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }
}
