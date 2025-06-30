import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/shared/shared.dart';

abstract class IExpenseCategoryRepository {
  Future<TransactionCategory?> getExpenseCategoryWithId({required String expenseCategoryId});
  Future<void> deleteExpenseCategory(String expenseCategoryId);
  Future<TransactionCategory> upsertExpenseCategory(TransactionCategory expenseCategory);
  Future<PaginatedResponse<TransactionCategory>> getExpenseCategories({
    required int pageSize,
    required int pageNumber,
    String query = '',
  });
}
