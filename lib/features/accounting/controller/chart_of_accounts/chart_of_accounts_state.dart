part of 'chart_of_accounts_notifier.dart';

enum ChartOfAccountsStatus {
  initial,
  loading,
  success,
  error,
}

@freezed
class ChartOfAccountsState with _$ChartOfAccountsState {
  const factory ChartOfAccountsState({
    @Default(ChartOfAccountsStatus.initial) ChartOfAccountsStatus status,
    @Default([]) List<ChartOfAccounts> chartOfAccounts,
    @Default('') String error,
  }) = _ChartOfAccountsState;

  factory ChartOfAccountsState.initial() => const ChartOfAccountsState();
}
