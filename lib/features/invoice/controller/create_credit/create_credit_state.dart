part of 'create_credit_notifier.dart';

enum CreateCreditStatus {
    initial,
    loading,
    success,
    error,
}

extension CreateCreditStatusExtension on CreateCreditStatus {
    R when<R>({
      required R Function() initial,
      required R Function() loading,
      required R Function() success,
      required R Function() error,
    }) {
      switch (this) {
        case CreateCreditStatus.initial:
          return initial();
        case CreateCreditStatus.loading:
          return loading();
        case CreateCreditStatus.success:
          return success();
        case CreateCreditStatus.error:
          return error();
      }
    }
  }

@freezed
class CreateCreditState with _$CreateCreditState {
    const factory CreateCreditState({
    @Default(CreateCreditStatus.initial) CreateCreditStatus status,
    Customer? customer,
    @Default(null) CustomerAddress? billingAddress,
    @Default(null) CustomerAddress? shippingAddress,
    }) = _CreateCreditState;

    factory CreateCreditState.initial() => const CreateCreditState();
}
