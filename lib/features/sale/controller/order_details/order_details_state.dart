part of 'order_details_notifier.dart';

enum OrderDetailsStatus {
  initial,
  loading,
  success,
  error,
}

@freezed
class OrderDetailsState with _$OrderDetailsState {
  const factory OrderDetailsState({
    @Default(OrderDetailsStatus.initial) OrderDetailsStatus status,
  }) = _OrderDetailsState;

  factory OrderDetailsState.initial() => const OrderDetailsState();
}
