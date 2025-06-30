import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'income_repository.g.dart';

@Riverpod(keepAlive: true)
IIncomeRepository incomeRepo(IncomeRepoRef ref) => IncomeRepository(ref);

class IncomeRepository implements IIncomeRepository {
  IncomeRepository(this.ref) : _supabaseClient = ref.watch(supabaseProvider);
  final IncomeRepoRef ref;
  final SupabaseClient _supabaseClient;

  @override
  Future<void> deleteIncome(String incomeTransactionId) async {
    try {
      return await _supabaseClient.rpc(
        RPCConstants.reverseTransaction,
        params: {
          'p_original_transaction_id': incomeTransactionId,
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
  Future<Income?> getIncomeWithId({required String incomeId}) async {
    try {
      return await _supabaseClient
          .from(DbConstants.incomes)
          .select('*, category:income_category_id(*), amount.sum()')
          .eq('income_id', incomeId)
          .single()
          .withConverter(Income.fromJson);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<PaginatedResponse<Income>> getIncomes({
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
          .from(DbConstants.incomes)
          .select('*, category:income_category_id(*), amount.sum()')
          .eq('business_id', businessId)
          .eq('status', 'ACTIVE')
          .ilike('income_for', '%$query%');

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
      final sum = await getIncomesSum(fromDate: fromDate, toDate: toDate);
      return PaginatedResponse(
        data: response.data.map(Income.fromJson).toList(),
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
  Future<String> upsertIncome(Income income) async {
    try {
      final business = ref.read(businessNotifierProvider);
      if (business == null) {
        throw AppException('User has no active business. Please login again.');
      }
      print(income.copyWith(businessId: business.businessId).toJson());
      return await _supabaseClient.rpc<String>(
        RPCConstants.upsertIncome,
        params: {
          'p_income_data': income.copyWith(businessId: business.businessId).toJson()
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
  Future<double> getIncomesSum({
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
      return (response.firstOrNull?['sum'] as num?)?.toDouble() ?? 0.0;
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }
}
