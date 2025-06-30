part of 'ledger_notifier.dart';

enum LedgerStatus {
  initial,
  loading,
  success,
  error,
}

@freezed
class LedgerState with _$LedgerState {
  const factory LedgerState({
    @Default(LedgerStatus.initial) LedgerStatus status,
    @Default(Ledger()) Ledger ledger,
    @Default([]) List<Party> parties,
    @Default('') String error,
    PlutoGridStateManager? stateManager,
    @Default('') String query,
    @Default(10) int pageSize,
    @Default(1) int pageNumber,
    @Default(0) int count,
    @Default(TransactionParty.all) TransactionParty party,
    PagingController<int, Party>? pagingController,
  }) = _LedgerState;

  factory LedgerState.initial() => const LedgerState();
}
