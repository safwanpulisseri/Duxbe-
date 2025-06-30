import 'package:duxbe/features/invoice/invoice.dart';
import 'package:duxbe/shared/shared.dart';

abstract class IQuoteRepository {
  Future<CustomerAddress> insertNewAddress({
    required CustomerAddress address,
    required String customerId,
  });
  Future<void> insertNewQuote({required Map<String, dynamic> quote});
  Future<Quote?> getQuoteWithId({required String quoteId});
  Future<PaginatedResponse<Quote>> getQuotes({
    required int pageSize,
    required int pageNumber,
    String? query,
    DateTime? fromDate,
    DateTime? toDate,
  });

  Future<PaginatedResponse<Quote>> getQuotesDetails({
    required int pageSize,
    required int pageNumber,
    String? query,
  });
  Future<List<CustomerAddress>> getCustomerAddresses({required String customerId});
  Future<void> deleteQuote({required String quoteId, required String status});
  Future<void> updateQuote({required Map<String, dynamic> quote, required String quoteId});
  Future<String> getNextQuoteCode();
}
