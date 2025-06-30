part of 'print_barcode_notifier.dart';

enum PrintBarcodeStatus {
  initial,
  loading,
  success,
  error,
}

@freezed
class PrintBarcodeState with _$PrintBarcodeState {
  const factory PrintBarcodeState({
    @Default(PrintBarcodeStatus.initial) PrintBarcodeStatus status,
    @Default('') String error,
    @Default('') String query,
    @Default(10) int pageSize,
    @Default(1) int pageNumber,
    @Default(0) int count,
    PagingController<int, Item>? pagingController,
  }) = _PrintBarcodeState;

  factory PrintBarcodeState.initial() => const PrintBarcodeState();
}
