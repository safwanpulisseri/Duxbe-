import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/shared/shared.dart';

abstract class IExpenseRepository {
  Future<Expense?> getExpenseWithId({required String expenseId});
  Future<void> deleteExpense(String expenseTransactionId);
  Future<String> upsertExpense(Expense expense);
  Future<PaginatedResponse<Expense>> getExpenses({
    required int pageSize,
    required int pageNumber,
    String query = '',
    DateTime? fromDate,
    DateTime? toDate,
  });
  Future<num> getExpensesSum({
    DateTime? fromDate,
    DateTime? toDate,
  });
}
