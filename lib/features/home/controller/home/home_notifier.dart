import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/home/home.dart';
import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_notifier.freezed.dart';
part 'home_notifier.g.dart';
part 'home_state.dart';

@Riverpod(keepAlive: false)
class HomeNotifier extends _$HomeNotifier {
  late IDashboardRepository _dashboardRepository;

  @override
  HomeState build() {
    _dashboardRepository = ref.watch(dashboardRepoProvider);
    // Use microtask to ensure it runs after initialization
    Future.microtask(getDashboard);
    ref.listen(businessNotifierProvider, (previous, next) {
      if (previous != next) {
        // Use microtask to prevent ordering issues
        Future.microtask(() {
          // Refresh the paging controller when business changes
          state.pagingController?.refresh();
          getDashboard();
        });
      }
    });
    return HomeState.initial();
  }

  /// Fetches the dashboard data from the repository, and updates the state accordingly.
  /// If any error occurs, it will be caught and the state will be updated with the error.
  /// The error will also be shown as a snackbar.
  ///
  Future<HomeModel> getDashboard() async {
    try {
      state = state.copyWith(status: HomeStatus.loading);
      final dashboardData = await _dashboardRepository.getDashboard();
      state = state.copyWith(status: HomeStatus.success, dashboardData: dashboardData);
      return dashboardData;
    } catch (e) {
      state = state.copyWith(
        status: HomeStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }
}
