part of 'item_details_notifier.dart';

enum ItemDetailsStatus {
  initial,
  loading,
  success,
  error,
}

extension ItemDetailsStatusExtension on ItemDetailsStatus {
  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function() success,
    required R Function() error,
  }) {
    switch (this) {
      case ItemDetailsStatus.initial:
        return initial();
      case ItemDetailsStatus.loading:
        return loading();
      case ItemDetailsStatus.success:
        return success();
      case ItemDetailsStatus.error:
        return error();
    }
  }
}

@freezed
class ItemDetailsState with _$ItemDetailsState {
  const factory ItemDetailsState({
    @Default(ItemDetailsStatus.initial) ItemDetailsStatus status,
    @Default(true) bool isBasicInfoExpanded,
    @Default(false) bool isQuantityExpanded,
    @Default(false) bool isSalesInfoExpanded,
    @Default(false) bool isPurchaseInfoExpanded,
    @Default(false) bool isInventoryInfoExpanded,
    @Default(false) bool isSerialNumberExpanded,
    @Default(false) bool selectedItemTypeIsGoods,
    @Default([]) List<ItemImage> images,
  }) = _ItemDetailsState;

  factory ItemDetailsState.initial() => const ItemDetailsState();
}
