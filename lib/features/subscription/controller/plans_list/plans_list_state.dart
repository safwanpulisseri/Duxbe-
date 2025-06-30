part of 'plans_list_notifier.dart';

enum PlansListStatus {
  initial,
  loading,
  success,
  error,
}

extension PlansListStatusExtension on PlansListStatus {
  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function() success,
    required R Function() error,
  }) {
    switch (this) {
      case PlansListStatus.initial:
        return initial();
      case PlansListStatus.loading:
        return loading();
      case PlansListStatus.success:
        return success();
      case PlansListStatus.error:
        return error();
    }
  }
}

@freezed
class PlansListState with _$PlansListState {
  const factory PlansListState({
    @Default(PlansListStatus.initial) PlansListStatus status,
  }) = _PlansListState;

  factory PlansListState.initial() => const PlansListState();
}

@freezed
class SubscriptionPlansState with _$SubscriptionPlansState {
  const factory SubscriptionPlansState({
    @Default(SubscriptionPlansStatus.initial) SubscriptionPlansStatus status,
  }) = _SubscriptionPlansState;

  factory SubscriptionPlansState.initial() => const SubscriptionPlansState();
}

enum SubscriptionPlansStatus {
  initial,
  loading,
  success,
  error,
}
