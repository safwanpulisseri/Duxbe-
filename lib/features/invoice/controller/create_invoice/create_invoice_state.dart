part of 'create_invoice_notifier.dart';

enum CreateInvoiceStatus {
    initial,
    loading,
    success,
    error,
}

extension CreateInvoiceStatusExtension on CreateInvoiceStatus {
    R when<R>({
      required R Function() initial,
      required R Function() loading,
      required R Function() success,
      required R Function() error,
    }) {
      switch (this) {
        case CreateInvoiceStatus.initial:
          return initial();
        case CreateInvoiceStatus.loading:
          return loading();
        case CreateInvoiceStatus.success:
          return success();
        case CreateInvoiceStatus.error:
          return error();
      }
    }
  }

@freezed
class CreateInvoiceState with _$CreateInvoiceState {
    const factory CreateInvoiceState({
    @Default(CreateInvoiceStatus.initial) CreateInvoiceStatus status,
    @Default(null) Customer? customer,
    @Default(null) CustomerAddress? billingAddress,
    @Default(null) CustomerAddress? shippingAddress,
    }) = _CreateInvoiceState;

    factory CreateInvoiceState.initial() => const CreateInvoiceState();
}
