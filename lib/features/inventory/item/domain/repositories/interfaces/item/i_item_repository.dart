import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';

abstract class IItemRepository {
  Future<Item?> getItemWithId({required String itemId});
  Future<void> deleteItem(String itemId);
  Future<void> deleteStockAdjustment(String adjustmentId);
  Future<void> upsertItem(
    Map<String, dynamic> item,
    List<ItemImage> images, {
    List<ItemImage> initialImages = const [],
  });
  Future<void> adjustStock(Map<String, dynamic> adjustments);
  Future<List<CustomField>> getCustomFields();
  Future<PaginatedResponse<Item>> getItems({
    required int pageSize,
    required int pageNumber,
    String query = '',
    bool? salesEnabled,
    bool? purchaseEnabled,
    String? itemType,
    List<ItemCategory>? categories,
    String? stockStatus,
    bool? excludeCurrentBusiness,
  });
  Future<PaginatedResponse<StockAdjustments>> getStockAdjustments({
    required int pageSize,
    required int pageNumber,
    String query = '',
  });
  Future<String> getNextItemCode();
  Future<void> createBulkItem(List<Map<String, dynamic>> data, {required bool skipDuplicates});
  Future<num> getTotalStockValue();
  Future<StockAdjustments?> getStockAdjustmentWithId({required String adjustmentId});
}
