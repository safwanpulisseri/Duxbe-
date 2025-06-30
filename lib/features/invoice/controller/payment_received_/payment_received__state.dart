part of 'payment_received__notifier.dart';

enum PaymentReceivedStatus {
  initial,
  loading,
  success,
  error,
}

extension PaymentReceivedStatusExtension on PaymentReceivedStatus {
  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function() success,
    required R Function() error,
  }) {
    switch (this) {
      case PaymentReceivedStatus.initial:
        return initial();
      case PaymentReceivedStatus.loading:
        return loading();
      case PaymentReceivedStatus.success:
        return success();
      case PaymentReceivedStatus.error:
        return error();
    }
  }
}

@freezed
class PaymentReceivedState with _$PaymentReceivedState {
  const factory PaymentReceivedState({
    @Default(PaymentReceivedStatus.initial) PaymentReceivedStatus status,
    Customer? customer,
    // @Default(null) CustomerAddress? billingAddress,
    // @Default(null) CustomerAddress? shippingAddress,
    @Default(null) PaymentReceived? editPaymentReceivedData,
    PagingController<int, PaymentReceived>? paymentReceivedPagingController,
    @Default(0) int count,
    @Default(1) int pageNumber,
    @Default(10) int pageSize,
    String? query,
    String? selectedPaymentReceivedId,
  }) = _PaymentReceivedState;

  factory PaymentReceivedState.initial() => const PaymentReceivedState();
}
