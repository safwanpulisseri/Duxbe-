part of 'party_details_notifier.dart';

enum PartyDetailsStatus {
  initial,
  loading,
  success,
  error,
}

@freezed
class PartyDetailsState with _$PartyDetailsState {
  const factory PartyDetailsState({
    @Default(PartyDetailsStatus.initial) PartyDetailsStatus status,
    @Default('') String error,
    @Default([]) List<SaleView> sales,
    @Default([]) List<PurchaseView> purchases,
    PlutoGridStateManager? stateManager,
    @Default(10) int pageSize,
    @Default(1) int pageNumber,
    @Default(0) int count,
    PagingController<int, SaleView>? salesPagingController,
    PagingController<int, PurchaseView>? purchasesPagingController,
    Customer? customer,
    Supplier? supplier,
    @Default('') String query,
    @Default(PartyDetails()) PartyDetails partyDetails,
  }) = _PartyDetailsState;

  factory PartyDetailsState.initial() => const PartyDetailsState();
}
