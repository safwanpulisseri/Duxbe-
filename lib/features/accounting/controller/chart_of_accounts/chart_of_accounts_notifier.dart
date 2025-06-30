import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chart_of_accounts_notifier.freezed.dart';
part 'chart_of_accounts_notifier.g.dart';
part 'chart_of_accounts_state.dart';

@Riverpod(keepAlive: false)
class ChartOfAccountsNotifier extends _$ChartOfAccountsNotifier {
  @override
  ChartOfAccountsState build() {
    Future.microtask(getChartOfAccountsTree);
    return ChartOfAccountsState.initial();
  }

  Future<void> getChartOfAccountsTree() async {
    state = state.copyWith(status: ChartOfAccountsStatus.loading);
    try {
      final chartOfAccounts = await ref.read(chartOfAccountsRepoProvider).getChartOfAccountsTree();
      state = state.copyWith(status: ChartOfAccountsStatus.success, chartOfAccounts: chartOfAccounts);
    } catch (e) {
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      state = state.copyWith(status: ChartOfAccountsStatus.error, error: e.toString());
    }
  }

  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(List<ChartOfAccounts> chartOfAccounts) success,
    required R Function() error,
  }) {
    switch (state.status) {
      case ChartOfAccountsStatus.initial:
        return initial();
      case ChartOfAccountsStatus.loading:
        return loading();
      case ChartOfAccountsStatus.success:
        return success(state.chartOfAccounts);
      case ChartOfAccountsStatus.error:
        return error();
    }
  }
}
