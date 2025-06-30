import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/shared/shared.dart';

abstract class IIncomeCategoryRepository {
  Future<TransactionCategory?> getIncomeCategoryWithId({required String incomeCategoryId});
  Future<void> deleteIncomeCategory(String incomeCategoryId);
  Future<TransactionCategory> upsertIncomeCategory(TransactionCategory incomeCategory);
  Future<PaginatedResponse<TransactionCategory>> getIncomeCategories({
    required int pageSize,
    required int pageNumber,
    String query = '',
  });
}
