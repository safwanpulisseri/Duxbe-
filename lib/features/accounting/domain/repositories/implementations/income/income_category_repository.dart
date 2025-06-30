import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'income_category_repository.g.dart';

@Riverpod(keepAlive: true)
IIncomeCategoryRepository incomeCategoryRepo(IncomeCategoryRepoRef ref) => IncomeCategoryRepository(ref);

class IncomeCategoryRepository implements IIncomeCategoryRepository {
  IncomeCategoryRepository(this.ref) : _supabaseClient = ref.watch(supabaseProvider);
  final IncomeCategoryRepoRef ref;
  final SupabaseClient _supabaseClient;

  @override
  Future<void> deleteIncomeCategory(String incomeCategoryId) async {
    try {
      return await _supabaseClient.from(DbConstants.incomeCategories).delete().eq('category_id', incomeCategoryId);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<TransactionCategory?> getIncomeCategoryWithId({required String incomeCategoryId}) async {
    try {
      return await _supabaseClient
          .from(DbConstants.incomes)
          .select()
          .eq('income_category_id', incomeCategoryId)
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
  Future<PaginatedResponse<TransactionCategory>> getIncomeCategories({
    required int pageSize,
    required int pageNumber,
    String query = '',
  }) async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      final offset = (pageNumber - 1) * pageSize;
      final response = await _supabaseClient
          .from(DbConstants.incomeCategories)
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
  Future<TransactionCategory> upsertIncomeCategory(TransactionCategory incomeCategory) async {
    try {
      final business = ref.read(businessNotifierProvider);
      return await _supabaseClient
          .from(DbConstants.incomeCategories)
          .upsert(
            incomeCategory
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
