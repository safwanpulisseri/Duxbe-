import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/home/home.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'dashboard_repository.g.dart';

@Riverpod(keepAlive: true)
IDashboardRepository dashboardRepo(DashboardRepoRef ref) => DashboardRepository(ref);

class DashboardRepository implements IDashboardRepository {
  DashboardRepository(this.ref) : _supabaseClient = ref.watch(supabaseProvider);
  final DashboardRepoRef ref;
  final SupabaseClient _supabaseClient;

  @override
  Future<HomeModel> getDashboard() async {
    try {
      final businessId = ref.read(businessNotifierProvider)?.businessId;
      if (businessId == null) return HomeModel.empty();
      return await _supabaseClient.rpc<Map<String, dynamic>>(
        RPCConstants.getDashboardData,
        params: {
          'p_business_id': businessId,
        },
      ).then(HomeModel.fromJson);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }
}
