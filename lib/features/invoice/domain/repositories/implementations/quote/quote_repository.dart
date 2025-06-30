import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/invoice/invoice.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'quote_repository.g.dart';

@Riverpod(keepAlive: true)
IQuoteRepository quoteRepo(QuoteRepoRef ref) => QuoteRepository(ref);

class QuoteRepository implements IQuoteRepository {
  QuoteRepository(this.ref) : _supabaseClient = ref.watch(supabaseProvider);
  final QuoteRepoRef ref;
  final SupabaseClient _supabaseClient;

  @override
  Future<CustomerAddress> insertNewAddress({
    required CustomerAddress address,
    required String customerId,
  }) async {
    try {
      final response = await _supabaseClient.from(DbConstants.customerAddresses).insert({
        'address': address.address,
        'city': address.city,
        'state': address.state,
        'zipcode': address.zipcode,
        'country': address.country,
        'customer_id': customerId,
      }).select();

      final data = response as List;
      final res = data[0] as Map<String, dynamic>;
      final custommerAddress = CustomerAddress.fromJson(res);
      return custommerAddress;
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    } catch (e) {
      throw AppException(
        e.toString(),
        code: 'unknown',
        details: 'unknown',
      );
    }
  }

  @override
  Future<Quote?> getQuoteWithId({required String quoteId}) async {
    try {
      return await _supabaseClient
          .from(DbConstants.quoteDetails)
          .select()
          .eq('quote_id', quoteId)
          .single()
          .withConverter(Quote.fromJson);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<void> insertNewQuote({required Map<String, dynamic> quote}) async {
    try {
      await _supabaseClient.rpc(
        RPCConstants.createQuote,
        params: {
          'p_quote_json': quote,
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
  Future<void> updateQuote({
    required Map<String, dynamic> quote,
    required String quoteId,
  }) async {
    try {
      await _supabaseClient.rpc(
        RPCConstants.updateQuote,
        params: {
          'p_quote_id_to_update': quoteId,
          'p_update_json': quote,
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

  ///MARK: - Get Next Quote Code

  @override
  Future<String> getNextQuoteCode() async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      final response = await _supabaseClient.rpc<String>(
        RPCConstants.getNextQuoteCode,
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
  Future<List<CustomerAddress>> getCustomerAddresses({
    required String customerId,
  }) async {
    try {
      if (customerId.isEmpty) return [];
      final response = await _supabaseClient.from(DbConstants.customerAddresses).select().eq('customer_id', customerId);
      return response.map(CustomerAddress.fromJson).toList();
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    } catch (e) {
      throw AppException(
        e.toString(),
        code: 'unknown',
        details: 'unknown',
      );
    }
  }

  @override
  Future<PaginatedResponse<Quote>> getQuotes({
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
          .from(DbConstants.quotes)
          .select()
          .or('quote_code.ilike.%$query%,customer_name.ilike.%$query%')
          .neq('quote_status', QuoteFormStatus.deleted.name)
          .eq('business_id', businessId);
      if (fromDate != null) {
        queryBuilder = queryBuilder.gte('quote_date', fromDate.toIso8601String());
      }
      if (toDate != null) {
        queryBuilder = queryBuilder.lte('quote_date', toDate.toIso8601String());
      }

      final response =
          await queryBuilder.range(offset, pageSize + offset - 1).order('created_at').count(CountOption.exact);
      return PaginatedResponse(
        data: response.data.map(Quote.fromJson).toList(),
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
  Future<void> deleteQuote({
    required String quoteId,
    required String status,
  }) async {
    try {
      await _supabaseClient.from(DbConstants.quotesTable).update({'status': status}).eq('quote_id', quoteId);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<PaginatedResponse<Quote>> getQuotesDetails({
    required int pageSize,
    required int pageNumber,
    String? query,
  }) async {
    try {
      final businessId = ref.read(businessNotifierProvider)?.businessId;
      if (businessId == null) return PaginatedResponse.empty();
      final offset = (pageNumber - 1) * pageSize;
      final queryBuilder = _supabaseClient
          .from(DbConstants.quoteDetails)
          .select()
          .or('quote_code.ilike.%$query%,customer->>name.ilike.%$query%')
          .neq('quote_status', QuoteFormStatus.deleted.name)
          .eq('business_id', businessId);
      // if (fromDate != null) {
      //   queryBuilder = queryBuilder.gte('quote_date', fromDate.toIso8601String());
      // }
      // if (toDate != null) {
      //   queryBuilder = queryBuilder.lte('quote_date', toDate.toIso8601String());
      // }

      final response =
          await queryBuilder.range(offset, pageSize + offset - 1).order('quote_created_at').count(CountOption.exact);
      return PaginatedResponse(
        data: response.data.map(Quote.fromJson).toList(),
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
}
