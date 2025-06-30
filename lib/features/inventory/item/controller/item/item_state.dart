part of 'item_notifier.dart';

enum ItemStatus {
  initial,
  loading,
  success,
  error,
}

@freezed
class ItemState with _$ItemState {
  const factory ItemState({
    @Default(ItemStatus.initial) ItemStatus status,
    @Default([]) List<Item> items,
    @Default([]) List<CustomField> customFields,
    @Default('') String error,
    PlutoGridStateManager? stateManager,
    @Default('') String query,
    @Default(10) int pageSize,
    @Default(1) int pageNumber,
    @Default(null) ItemType? itemType,
    @Default(0) int count,
    PagingController<int, Item>? pagingController,
    PagingController<int, Item>? goodsPagingController,
    PagingController<int, Item>? servicesPagingController,
  }) = _ItemState;

  factory ItemState.initial() => const ItemState();
}
