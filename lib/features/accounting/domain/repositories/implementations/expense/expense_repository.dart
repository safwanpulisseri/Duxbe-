import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'expense_repository.g.dart';

@Riverpod(keepAlive: true)
IExpenseRepository expenseRepo(ExpenseRepoRef ref) => ExpenseRepository(ref);

class ExpenseRepository implements IExpenseRepository {
  ExpenseRepository(this.ref) : _supabaseClient = ref.watch(supabaseProvider);
  final ExpenseRepoRef ref;
  final SupabaseClient _supabaseClient;

  @override
  Future<void> deleteExpense(String expenseTransactionId) async {
    try {
      return await _supabaseClient.rpc(
        RPCConstants.reverseTransaction,
        params: {
          'p_original_transaction_id': expenseTransactionId,
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
  Future<Expense?> getExpenseWithId({required String expenseId}) async {
    try {
      return await _supabaseClient
          .from(DbConstants.expenses)
          .select('*, category:expense_category_id(*)')
          .eq('expense_id', expenseId)
          .single()
          .withConverter(Expense.fromJson);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<PaginatedResponse<Expense>> getExpenses({
    required int pageSize,
    required int pageNumber,
    String query = '',
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final business = ref.read(businessNotifierProvider);
      if (business == null) {
        return const PaginatedResponse(
          data: [],
          count: 0,
        );
      }
      final businessId = business.businessId;
      final offset = (pageNumber - 1) * pageSize;

      var queryBuilder = _supabaseClient
          .from(DbConstants.expenses)
          .select('*, category:expense_category_id(*)')
          .eq('business_id', businessId)
          .eq('status', 'ACTIVE')
          .ilike('expense_for', '%$query%');

      if (fromDate != null) {
        queryBuilder = queryBuilder.gt('date', fromDate);
      }
      if (toDate != null) {
        queryBuilder = queryBuilder.lte('date', toDate);
      }
      final response = await queryBuilder
          .range(offset, pageSize + offset - 1)
          .order('created_at', ascending: false)
          .count(CountOption.exact);
      final sum = await getExpensesSum(fromDate: fromDate, toDate: toDate);
      return PaginatedResponse(
        data: response.data.map(Expense.fromJson).toList(),
        count: response.count,
        json: {
          'amount_sum': sum,
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
  Future<String> upsertExpense(Expense expense) async {
    try {
      final business = ref.read(businessNotifierProvider);
      if (business == null) {
        throw AppException('User has no active business. Please login again.');
      }
      return await _supabaseClient.rpc<String>(
        RPCConstants.upsertExpense,
        params: {
          'p_expense_data': expense.copyWith(businessId: business.businessId).toJson()
            ..addAll({
              'org_id': business.orgId,
            }),
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
  Future<num> getExpensesSum({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final businessId = ref.read(businessNotifierProvider)?.businessId;
      if (businessId == null) return 0;
      var queryBuilder = _supabaseClient
          .from(DbConstants.expenses)
          .select('amount.sum()')
          .eq('status', 'ACTIVE')
          .eq('business_id', businessId);

      if (fromDate != null) {
        queryBuilder = queryBuilder.gt('date', fromDate);
      }
      if (toDate != null) {
        queryBuilder = queryBuilder.lte('date', toDate);
      }
      final response = await queryBuilder;
      return response.firstOrNull?['sum'] as num? ?? 0;
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }
}
