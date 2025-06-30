import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'expense_category_repository.g.dart';

@Riverpod(keepAlive: true)
IExpenseCategoryRepository expenseCategoryRepo(ExpenseCategoryRepoRef ref) => ExpenseCategoryRepository(ref);

class ExpenseCategoryRepository implements IExpenseCategoryRepository {
  ExpenseCategoryRepository(this.ref) : _supabaseClient = ref.watch(supabaseProvider);
  final ExpenseCategoryRepoRef ref;
  final SupabaseClient _supabaseClient;

  @override
  Future<void> deleteExpenseCategory(String expenseCategoryId) async {
    try {
      return await _supabaseClient.from(DbConstants.expenseCategories).delete().eq('category_id', expenseCategoryId);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<TransactionCategory?> getExpenseCategoryWithId({required String expenseCategoryId}) async {
    try {
      return await _supabaseClient
          .from(DbConstants.expenseCategories)
          .select()
          .eq('expense_category_id', expenseCategoryId)
          .single()
          .withConverter(TransactionCategory.fromJson);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<PaginatedResponse<TransactionCategory>> getExpenseCategories({
    required int pageSize,
    required int pageNumber,
    String query = '',
  }) async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      final offset = (pageNumber - 1) * pageSize;
      final response = await _supabaseClient
          .from(DbConstants.expenseCategories)
          .select()
          .ilike('name', '%$query%')
          .eq('business_id', businessId)
          .range(offset, pageSize + offset - 1)
          .count(CountOption.exact);
      return PaginatedResponse(
        data: response.data.map(TransactionCategory.fromJson).toList(),
        count: response.count,
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
  Future<TransactionCategory> upsertExpenseCategory(TransactionCategory expenseCategory) async {
    try {
      final business = ref.read(businessNotifierProvider);
      return await _supabaseClient
          .from(DbConstants.expenseCategories)
          .upsert(
            expenseCategory
                .copyWith(
                  businessId: business!.businessId,
                )
                .toJson(),
          )
          .select()
          .single()
          .withConverter(TransactionCategory.fromJson);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }
}
