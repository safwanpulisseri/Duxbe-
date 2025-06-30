import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'chart_of_accounts_repository.g.dart';

@Riverpod(keepAlive: true)
IChartOfAccountsRepository chartOfAccountsRepo(ChartOfAccountsRepoRef ref) => ChartOfAccountsRepository(ref);

class ChartOfAccountsRepository implements IChartOfAccountsRepository {
  ChartOfAccountsRepository(this.ref) : _supabaseClient = ref.watch(supabaseProvider);
  final ChartOfAccountsRepoRef ref;
  final SupabaseClient _supabaseClient;

  @override
  Future<List<ChartOfAccounts>> getChartOfAccountsTree() async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      final response = await _supabaseClient.rpc<PostgrestList>(
        RPCConstants.getChartOfAccountsTree,
        params: {
          'p_business_id': businessId,
        },
      );
      return response.map(ChartOfAccounts.fromJson).toList();
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }
  
  @override
  Future<ProfitAndLoss> getProfitAndLoss({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      final response = await _supabaseClient.rpc<PostgrestMap>(
        RPCConstants.getProfitAndLoss,
        params: {
          'p_business_id': businessId, // Replace with actual business ID
          'p_start_date': startDate.toIso8601String(), // Replace with actual start date
          'p_end_date': endDate.toIso8601String(), // Replace with actual end date
        },
      );
      return ProfitAndLoss.fromJson(response);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }


}
