part of 'create_quote_notifier.dart';

enum CreateQuoteStatus {
    initial,
    loading,
    success,
    error,
}

extension CreateQuoteStatusExtension on CreateQuoteStatus {
    R when<R>({
      required R Function() initial,
      required R Function() loading,
      required R Function() success,
      required R Function() error,
    }) {
      switch (this) {
        case CreateQuoteStatus.initial:
          return initial();
        case CreateQuoteStatus.loading:
          return loading();
        case CreateQuoteStatus.success:
          return success();
        case CreateQuoteStatus.error:
          return error();
      }
    }
  }

@freezed
class CreateQuoteState with _$CreateQuoteState {
    const factory CreateQuoteState({
    @Default(CreateQuoteStatus.initial) CreateQuoteStatus status,
    Customer? customer,
    @Default(null) CustomerAddress? billingAddress,
    @Default(null) CustomerAddress? shippingAddress,
    @Default(null) Quote? editQuoteData,
    }) = _CreateQuoteState;

    factory CreateQuoteState.initial() => const CreateQuoteState();
}
