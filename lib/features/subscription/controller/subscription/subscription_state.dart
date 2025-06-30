part of 'subscription_notifier.dart';

enum SubscriptionStatus {
  initial,
  loading,
  success,
  error,
}

extension SubscriptionStatusExtension on SubscriptionStatus {
  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function() success,
    required R Function() error,
  }) {
    switch (this) {
      case SubscriptionStatus.initial:
        return initial();
      case SubscriptionStatus.loading:
        return loading();
      case SubscriptionStatus.success:
        return success();
      case SubscriptionStatus.error:
        return error();
    }
  }
}

@freezed
class SubscriptionState with _$SubscriptionState {
  const factory SubscriptionState({
    @Default(SubscriptionStatus.initial) SubscriptionStatus status,
    @Default([]) List<Subscription> subscriptions, // Current page of subscriptions
    @Default('') String error,
    PlutoGridStateManager? stateManager,
    @Default('') String query,
    @Default(10) int pageSize,
    @Default(1) int pageNumber,
    @Default(0) int count, // Total count of filtered subscriptions
    PagingController<int, Subscription>? pagingController,
  }) = _SubscriptionState;

  factory SubscriptionState.initial() => const SubscriptionState();

  const SubscriptionState._();

  bool get isLoading => status == SubscriptionStatus.loading;
}
