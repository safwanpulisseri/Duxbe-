import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';

abstract class IItemCategoryRepository {
  Future<ItemCategory?> getItemCategoryWithId({required String itemCategoryId});
  Future<void> deleteItemCategory(String itemCategoryId);
  Future<ItemCategory> upsertItemCategory(ItemCategory itemCategory);
  Future<PaginatedResponse<ItemCategory>> getItemCategories({
    required int pageSize,
    required int pageNumber,
    String query = '',
  });
}
