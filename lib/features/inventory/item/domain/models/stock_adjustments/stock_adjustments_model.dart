import 'package:duxbe/features/inventory/inventory.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'stock_adjustments_model.freezed.dart';
part 'stock_adjustments_model.g.dart';

@freezed
class StockAdjustments with _$StockAdjustments {
  const factory StockAdjustments({
    @JsonKey(name: 'reason') required String reason,
    @JsonKey(name: 'reference') required String reference,
    @JsonKey(name: 'performed_at') required DateTime performedAt,
    @JsonKey(name: 'performed_by') required String performedBy,
    @JsonKey(name: 'performed_user') required String performedUser,
    @JsonKey(name: 'business_id') required String businessId,
    @JsonKey(name: 'org_id') required String orgId,
    @Default([]) @JsonKey(name: 'adjusted_items') List<AdjustedItems> adjustedItems,
    @JsonKey(name: 'adjustment_id', includeIfNull: false) String? adjustmentId,
  }) = _StockAdjustments;

  factory StockAdjustments.fromJson(Map<String, dynamic> json) => _$StockAdjustmentsFromJson(json);
}

@unfreezed
class AdjustedItems with _$AdjustedItems {
  factory AdjustedItems({
    @JsonKey(name: 'quantity_adjusted') double? quantityAdjusted,
    @JsonKey(name: 'previous_quantity') double? previousQuantity,
    @JsonKey(name: 'new_quantity') double? newQuantity,
    @JsonKey(name: 'item_id') String? itemId,
    @JsonKey(name: 'item') Item? item,
    @JsonKey(name: 'adjustment_item_id', includeIfNull: false) String? adjustmentItemId,
  }) = _AdjustedItems;

  factory AdjustedItems.fromJson(Map<String, dynamic> json) => _$AdjustedItemsFromJson(json);
  factory AdjustedItems.empty() => AdjustedItems(
        adjustmentItemId: const Uuid().v4(),
      );
}
