part of 'customer_notifier.dart';

enum CustomerStatus {
  initial,
  loading,
  success,
  error,
}

@freezed
class CustomerState with _$CustomerState {
  factory CustomerState({
    @Default(CustomerStatus.initial) CustomerStatus status,
    @Default([]) List<Customer> customers,
    @Default('') String error,
    PlutoGridStateManager? stateManager,
    @Default('') String query,
    @Default(10) int pageSize,
    @Default(1) int pageNumber,
    @Default(0) int count,
    PagingController<int, Customer>? pagingController,
  }) = _CustomerState;

  factory CustomerState.initial() => CustomerState();

  CustomerState._();

  bool get isLoading => status == CustomerStatus.loading;
}
