part of 'brand_notifier.dart';

enum BrandStatus {
  initial,
  loading,
  success,
  error,
}

@freezed
class BrandState with _$BrandState {
  factory BrandState({
    @Default(BrandStatus.initial) BrandStatus status,
    @Default([]) List<Brand> brands,
    @Default('') String error,
    PlutoGridStateManager? stateManager,
    @Default('') String query,
    @Default(10) int pageSize,
    @Default(1) int pageNumber,
    @Default(0) int count,
    PagingController<int, Brand>? pagingController,
  }) = _BrandState;
  BrandState._();

  factory BrandState.initial() => BrandState();

  bool get isLoading => status == BrandStatus.loading;
}
