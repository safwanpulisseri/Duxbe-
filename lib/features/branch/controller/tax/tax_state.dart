part of 'tax_notifier.dart';

enum TaxStatus {
  initial,
  loading,
  success,
  error,
}

@freezed
class TaxState with _$TaxState {
  const factory TaxState({
    @Default(TaxStatus.initial) TaxStatus status,
    @Default([]) List<Tax> taxes,
    @Default('') String error,
  }) = _TaxState;

  factory TaxState.initial() => const TaxState();
}
