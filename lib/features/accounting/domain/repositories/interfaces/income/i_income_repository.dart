import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/shared/shared.dart';

abstract class IIncomeRepository {
  Future<Income?> getIncomeWithId({required String incomeId});
  Future<void> deleteIncome(String incomeTransactionId);
  Future<String> upsertIncome(Income income);
  Future<PaginatedResponse<Income>> getIncomes({
    required int pageSize,
    required int pageNumber,
    String query = '',
    DateTime? fromDate,
    DateTime? toDate,
  });
  Future<double> getIncomesSum({
    DateTime? fromDate,
    DateTime? toDate,
  });
}
