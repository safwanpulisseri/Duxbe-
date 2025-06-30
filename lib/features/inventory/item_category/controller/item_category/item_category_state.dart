part of 'item_category_notifier.dart';

enum ItemCategoryStatus {
  initial,
  loading,
  success,
  error,
}

@freezed
class ItemCategoryState with _$ItemCategoryState {
  factory ItemCategoryState({
    @Default(ItemCategoryStatus.initial) ItemCategoryStatus status,
    @Default([]) List<ItemCategory> itemCategories,
    @Default('') String error,
    PlutoGridStateManager? stateManager,
    @Default('') String query,
    @Default(10) int pageSize,
    @Default(1) int pageNumber,
    @Default(0) int count,
    PagingController<int, ItemCategory>? pagingController,
  }) = _ItemCategoryState;

  ItemCategoryState._();
  factory ItemCategoryState.initial() => ItemCategoryState();

  bool get isLoading => status == ItemCategoryStatus.loading;
}
