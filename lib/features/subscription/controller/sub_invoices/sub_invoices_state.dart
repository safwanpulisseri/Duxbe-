part of 'sub_invoices_notifier.dart';

enum SubInvoicesStatus {
  initial,
  loading,
  success,
  error,
}

extension SubInvoicesStatusExtension on SubInvoicesStatus {
  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function() success,
    required R Function() error,
  }) {
    switch (this) {
      case SubInvoicesStatus.initial:
        return initial();
      case SubInvoicesStatus.loading:
        return loading();
      case SubInvoicesStatus.success:
        return success();
      case SubInvoicesStatus.error:
        return error();
    }
  }
}

@freezed
class SubInvoicesState with _$SubInvoicesState {
  const factory SubInvoicesState({
    @Default(SubInvoicesStatus.initial) SubInvoicesStatus status,
    @Default([]) List<SubscriptionInvoice> invoices,
    @Default('') String error,
    PlutoGridStateManager? stateManager,
    @Default('') String query,
    @Default(10) int pageSize,
    @Default(1) int pageNumber,
    @Default(0) int count,
    PagingController<int, SubscriptionInvoice>? pagingController,
  }) = _SubInvoicesState;

  factory SubInvoicesState.initial() => const SubInvoicesState();

  const SubInvoicesState._();

  bool get isLoading => status == SubInvoicesStatus.loading;
}
