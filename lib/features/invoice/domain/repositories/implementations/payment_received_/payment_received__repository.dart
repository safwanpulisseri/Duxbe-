import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/invoice/invoice.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
part 'payment_received__repository.g.dart';

@Riverpod(keepAlive: true)
IPaymentReceivedRepository paymentReceivedRepo(PaymentReceivedRepoRef ref) => PaymentReceivedRepository(ref);

class PaymentReceivedRepository implements IPaymentReceivedRepository {
  PaymentReceivedRepository(this.ref) : _supabaseClient = ref.read(supabaseProvider);
  final PaymentReceivedRepoRef ref;
  final SupabaseClient _supabaseClient;

  @override
  Future<String> getNextPaymentCode() async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      final response = await _supabaseClient.rpc<String>(
        RPCConstants.getNextPaymentCode,
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
  Future<void> createPayment(Map<String, dynamic> paymentReceived) async {
    try {
      await _supabaseClient.rpc<void>(
        RPCConstants.createPaymentReceived,
        params: {'p_payment_json': paymentReceived},
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

  @override
  Future<void> editPayment(
    String paymentId,
    Map<String, dynamic> paymentReceived,
  ) async {
    try {
      await _supabaseClient.rpc<void>(
        RPCConstants.editPaymentReceived,
        params: {
          'p_payment_id': paymentId,
          'p_update_json': paymentReceived,
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

  @override
  Future<void> deletePayment(
    String paymentId,
  ) async {
    try {
      await _supabaseClient.rpc<void>(
        RPCConstants.deletePayment,
        params: {
          'p_payment_id': paymentId,
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

  @override
  Future<PaginatedResponse<PaymentReceived>> getPaymentReceived({
    required int pageSize,
    required int pageNumber,
    String? query,
  }) async {
    try {
      final businessId = ref.read(businessNotifierProvider)?.businessId;
      if (businessId == null) return PaginatedResponse.empty();
      final offset = (pageNumber - 1) * pageSize;
      final queryBuilder = _supabaseClient
          .from(DbConstants.paymentReceivedDetails)
          .select()
          .or('payment_code.ilike.%$query%,customer->>name.ilike.%$query%')
          // .neq('quote_status', QuoteFormStatus.deleted.name)
          .eq('business_id', businessId);
      // if (fromDate != null) {
      //   queryBuilder = queryBuilder.gte('quote_date', fromDate.toIso8601String());
      // }
      // if (toDate != null) {
      //   queryBuilder = queryBuilder.lte('quote_date', toDate.toIso8601String());
      // }

      final response =
          await queryBuilder.range(offset, pageSize + offset - 1).order('payment_created_at').count(CountOption.exact);
      return PaginatedResponse(
        data: response.data.map(PaymentReceived.fromJson).toList(),
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
  Future<PaymentReceived?> getPaymentReceivedWithId({required String paymentId}) async {
    try {
      return await _supabaseClient
          .from(DbConstants.paymentReceivedDetails)
          .select()
          .eq('payment_id', paymentId)
          .single()
          .withConverter(PaymentReceived.fromJson);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<void> createRefund(Map<String, dynamic> refund) async {
    try {
      await _supabaseClient.rpc<void>(
        RPCConstants.createRefund,
        params: {'p_refund_json': refund},
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
