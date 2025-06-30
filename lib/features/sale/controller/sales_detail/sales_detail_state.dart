part of 'sales_detail_notifier.dart';

enum SalesDetailStatus {
  initial,
  loading,
  success,
  error,
}

@freezed
class SalesDetailState with _$SalesDetailState {
  const factory SalesDetailState({
    @Default(SalesDetailStatus.initial) SalesDetailStatus status,
  }) = _SalesDetailState;

  factory SalesDetailState.initial() => const SalesDetailState();
}
