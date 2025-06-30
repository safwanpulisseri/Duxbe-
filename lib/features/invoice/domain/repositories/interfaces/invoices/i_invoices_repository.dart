import 'package:duxbe/features/invoice/invoice.dart';
import 'package:duxbe/shared/shared.dart';

abstract class IInvoicesRepository {
  Future<void> createInvoice(Map<String, dynamic> invoice);
  Future<String> getNextInvoiceCode();

  Future<PaginatedResponse<Invoice>> getInvoices({
    required int pageSize,
    required int pageNumber,
    String? query,
    DateTime? fromDate,
    DateTime? toDate,
  });

  Future<PaginatedResponse<Invoice>> getInvoicesDetails({
    required int pageSize,
    required int pageNumber,
    String? query,
  });

  Future<void> updateInvoiceStatus({
    required String invoiceId,
    required String status,
  });
  Future<Invoice?> getInvoiceWithId({required String invoiceId});
  Future<void> updateInvoice({
    required Map<String, dynamic> invoice,
    required String invoiceId,
  });

  Future<void> deleteInvoice({required String invoiceId});
}
