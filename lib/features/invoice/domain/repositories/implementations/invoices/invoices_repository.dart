import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/invoice/invoice.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'invoices_repository.g.dart';

@Riverpod(keepAlive: true)
IInvoicesRepository invoicesRepo(Ref ref) => InvoicesRepository(ref);

class InvoicesRepository implements IInvoicesRepository {
  InvoicesRepository(this.ref) : _supabaseClient = ref.watch(supabaseProvider);
  final Ref ref;
  final SupabaseClient _supabaseClient;

  @override
  Future<void> createInvoice(Map<String, dynamic> invoice) async {
    try {
      await _supabaseClient.rpc<void>(
        RPCConstants.createInvoice,
        params: {'p_invoice_json': invoice},
      ).single();
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<Invoice?> getInvoiceWithId({required String invoiceId}) async {
    try {
      return await _supabaseClient
          .from(DbConstants.invoiceDetails)
          .select()
          .eq('invoice_id', invoiceId)
          .single()
          .withConverter(Invoice.fromJson);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<String> getNextInvoiceCode() async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      final response = await _supabaseClient.rpc<String>(
        'get_next_invoice_code',
        params: {'p_business_id': businessId},
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
  Future<PaginatedResponse<Invoice>> getInvoices({
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
      var queryBuilder = _supabaseClient
          .from(DbConstants.invoiceView)
          .select()
          .or('invoice_code.ilike.%$query%,customer_name.ilike.%$query%')
          .neq('invoice_status', QuoteFormStatus.deleted.name)
          .eq('business_id', businessId);
      if (fromDate != null) {
        queryBuilder = queryBuilder.gte('invoice_date', fromDate.toIso8601String());
      }
      if (toDate != null) {
        queryBuilder = queryBuilder.lte('invoice_date', toDate.toIso8601String());
      }

      final response =
          await queryBuilder.range(offset, pageSize + offset - 1).order('created_at').count(CountOption.exact);
      print(response.data);
      print(response.data);
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
  Future<PaginatedResponse<Invoice>> getInvoicesDetails({
    required int pageSize,
    required int pageNumber,
    String? query,
  }) async {
    try {
      final businessId = ref.read(businessNotifierProvider)?.businessId;
      if (businessId == null) return PaginatedResponse.empty();
      final offset = (pageNumber - 1) * pageSize;
      final queryBuilder = _supabaseClient
          .from(DbConstants.invoiceDetails)
          .select()
          .or('invoice_code.ilike.%$query%,customer->>name.ilike.%$query%')
          .neq('invoice_status', QuoteFormStatus.deleted.name)
          .eq('business_id', businessId);
      // if (fromDate != null) {
      //   queryBuilder = queryBuilder.gte('quote_date', fromDate.toIso8601String());
      // }
      // if (toDate != null) {
      //   queryBuilder = queryBuilder.lte('quote_date', toDate.toIso8601String());
      // }

      final response =
          await queryBuilder.range(offset, pageSize + offset - 1).order('invoice_created_at').count(CountOption.exact);
      // print(JsonEncoder.withIndent('  ').convert(response.data[0]));
      // print(response.data);
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
    } catch (e) {
      print(e);
      throw AppException(
        e.toString(),
        code: '500',
        details: e.toString(),
      );
    }
  }

  @override
  Future<void> updateInvoice({
    required Map<String, dynamic> invoice,
    required String invoiceId,
  }) async {
    try {
      await _supabaseClient.rpc(
        RPCConstants.updateInvoice,
        params: {
          'p_invoice_id': invoiceId,
          'p_update_json': invoice,
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
  Future<void> deleteInvoice({required String invoiceId}) async {
    try {
      await _supabaseClient.rpc(
        RPCConstants.deleteInvoice,
        params: {
          'p_invoice_id': invoiceId,
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
  Future<void> updateInvoiceStatus({
    required String invoiceId,
    required String status,
  }) async {
    try {
      await _supabaseClient
          .from(DbConstants.invoices)
          // .update({'status': status}).eq('quote_id', quoteId);
          .update({'status': status}).eq('invoice_id', invoiceId);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }
}
