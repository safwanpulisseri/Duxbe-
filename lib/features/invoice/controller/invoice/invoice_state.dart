part of 'invoice_notifier.dart';

enum InvoiceStatus {
    initial,
    loading,
    success,
    error,
}

extension InvoiceStatusExtension on InvoiceStatus {
    R when<R>({
      required R Function() initial,
      required R Function() loading,
      required R Function() success,
      required R Function() error,
    }) {
      switch (this) {
        case InvoiceStatus.initial:
          return initial();
        case InvoiceStatus.loading:
          return loading();
        case InvoiceStatus.success:
          return success();
        case InvoiceStatus.error:
          return error();
      }
    }
  }

@freezed
class InvoiceState with _$InvoiceState {
    const factory InvoiceState({
    @Default(InvoiceStatus.initial) InvoiceStatus status,
    @Default([]) List<Invoice> invoices,
    @Default(0) int count,
    @Default(1) int pageNumber,
    @Default(10) int pageSize,
    PlutoGridStateManager? stateManager,
    String? query,
    ItemType? selectedItemType,
    List<ItemCategory>? selectedCategories,
    DateTime? startDate,
    DateTime? endDate,
    PagingController<int, Invoice>? pagingController,
    PagingController<int, Invoice>? invoiceDetailsPagingController,
    String? selectedInvoiceId,
  }) = _InvoiceState;

    factory InvoiceState.initial() => const InvoiceState();
}
