part of 'refund_payments_notifier.dart';

enum RefundPaymentsStatus {
    initial,
    loading,
    success,
    error,
}

extension RefundPaymentsStatusExtension on RefundPaymentsStatus {
    R when<R>({
      required R Function() initial,
      required R Function() loading,
      required R Function() success,
      required R Function() error,
    }) {
      switch (this) {
        case RefundPaymentsStatus.initial:
          return initial();
        case RefundPaymentsStatus.loading:
          return loading();
        case RefundPaymentsStatus.success:
          return success();
        case RefundPaymentsStatus.error:
          return error();
      }
    }
  }

@freezed
class RefundPaymentsState with _$RefundPaymentsState {
    const factory RefundPaymentsState({
    @Default(RefundPaymentsStatus.initial) RefundPaymentsStatus status,
    }) = _RefundPaymentsState;

    factory RefundPaymentsState.initial() => const RefundPaymentsState();
}
