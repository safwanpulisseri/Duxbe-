import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/shared/shared.dart';

abstract class ISaleRepository {
  Future<SaleView> createSaleTransaction(SalePageData data);
  Future<void> deleteSaleTransaction(String saleId);
  Future<SaleView?> getSaleWithId({required String saleId});
  Future<PaginatedResponse<SaleView>> getSales({
    required int pageSize,
    required int pageNumber,
    String query = '',
    bool? orderMode = false,
    String? customerId,
    bool? paidOrDueList,
    DateTime? fromDate,
    DateTime? toDate,
  });
  Future<List<CustomField>> getCustomFields();
  Future<List<SaleView>> getDueSalesWithCustomerId({required String customerId, String query = ''});
  Future<void> settleSale({
    required String saleId,
    required double amount,
    required PaymentMode mode,
    required DateTime date,
    required String customerId,
  });
  Future<SaleReturn?> getSaleReturnWithId({required String saleReturnId});
  Future<PaginatedResponse<SaleReturn>> getSaleReturns({
    required int pageSize,
    required int pageNumber,
    String query = '',
  });
  Future<String> getNextSaleReturnCode();
  Future<void> createSaleReturnTransaction(CreateSaleReturn data);
  Future<List<SaleAudit>> getSaleAudits(String saleId);
  Future<List<Status>> getSaleStatuses();
  Future<void> updateSaleStatus(String saleId, String statusId);
  Future<void> updateSale(SaleView sale, Map<String, dynamic> data);
  Future<void> updateSaleEmployee(String saleId, String employeeId);
}
