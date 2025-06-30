import 'package:duxbe/features/invoice/domain/invoice_domain.dart';
import 'package:duxbe/shared/shared.dart';

abstract class ICreditNoteRepository {
  Future<PaginatedResponse<Invoice>> getInvoices({
    required int pageSize,
    required int pageNumber,
    String query = '',
    String? customerId,
  });

  Future<void> createCredit(Map<String, dynamic> credit);
  Future<void> deleteCredit(String credit);
  Future<void> editCredit(Map<String, dynamic> credit, String creditId);
  Future<String> getNextCreditNotCode();

  Future<CreditNote?> getCreditWithId({required String creditId});
  Future<PaginatedResponse<CreditNote>> getCreditDetails({
    required int pageSize,
    required int pageNumber,
    String? query,
  });
  Future<PaginatedResponse<CreditNote>> getcreditNotesLists({
    required int pageSize,
    required int pageNumber,
    String? query,
    DateTime? fromDate,
    DateTime? toDate,
  });
  Future<void> deleteRefund(String refund);
}
