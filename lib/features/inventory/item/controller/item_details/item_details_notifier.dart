import 'package:duxbe/features/inventory/inventory.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'item_details_notifier.freezed.dart';
part 'item_details_notifier.g.dart';
part 'item_details_state.dart';

@Riverpod(keepAlive: false)
class ItemDetailsNotifier extends _$ItemDetailsNotifier {
  @override
  ItemDetailsState build() => ItemDetailsState.initial();

  void toggleBasicInfo() => state = state.copyWith(isBasicInfoExpanded: !state.isBasicInfoExpanded);
  void toggleQuantity() => state = state.copyWith(isQuantityExpanded: !state.isQuantityExpanded);
  void toggleSalesInfo() => state = state.copyWith(isSalesInfoExpanded: !state.isSalesInfoExpanded);
  void togglePurchaseInfo() => state = state.copyWith(isPurchaseInfoExpanded: !state.isPurchaseInfoExpanded);
  void toggleInventoryInfo() => state = state.copyWith(isInventoryInfoExpanded: !state.isInventoryInfoExpanded);
  void toggleSerialNumber() => state = state.copyWith(isSerialNumberExpanded: !state.isSerialNumberExpanded);
  void setItemType({required bool isGoods}) => state = state.copyWith(selectedItemTypeIsGoods: isGoods);
  void addImage(ItemImage image) => state = state.copyWith(images: [...state.images, image]);
  void removeImage(int index) {
    final newImages = [...state.images]..removeAt(index);
    state = state.copyWith(images: newImages);
  }
}
