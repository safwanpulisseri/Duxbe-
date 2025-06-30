import 'package:duxbe/features/reports/reports.dart';
import 'package:duxbe/shared/shared.dart';

abstract class IReportRepository {
  Future<PaginatedResponse<Due>> getDueReport({
    required int pageSize,
    required int pageNumber,
    String query = '',
    bool? salesOrPurchase,
    DateTime? fromDate,
    DateTime? toDate,
  });
  Future<PaginatedResponse<DailyTransaction>> getDailyTransactionReport({
    required int pageSize,
    required int pageNumber,
    String query = '',
    bool? payIn,
    DateTime? fromDate,
    DateTime? toDate,
  });
  Future<SalesSummary> getSalesSummary({
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<DailyTransactionSummary> getDailyTransactionSummary({
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<PurchaseSummary> getPurchaseSummary({
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<TotalDuesSummary> getTotalDuesSummary({
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<List<EmployeeSales>> getEmployeeSalesReport({
    required int pageSize,
    required int pageNumber,
    String query = '',
    DateTime? fromDate,
    DateTime? toDate,
  });

  Future<EmployeeSalesSummary> getEmployeeSalesSummary({
  required int pageSize,
    required int pageNumber,
    String query = '',
    DateTime? fromDate,
    DateTime? toDate,
});
}
