import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'item_category_repository.g.dart';

@Riverpod(keepAlive: true)
IItemCategoryRepository itemCategoryRepo(ItemCategoryRepoRef ref) => ItemCategoryRepository(ref);

class ItemCategoryRepository implements IItemCategoryRepository {
  ItemCategoryRepository(this.ref) : _supabaseClient = ref.watch(supabaseProvider);

  final ItemCategoryRepoRef ref;
  final SupabaseClient _supabaseClient;

  @override
  Future<void> deleteItemCategory(String itemCategoryId) async {
    try {
      return await _supabaseClient.from(DbConstants.itemCategories).delete().eq('item_category_id', itemCategoryId);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<ItemCategory?> getItemCategoryWithId({
    required String itemCategoryId,
  }) async {
    try {
      return await _supabaseClient
          .from(DbConstants.itemCategories)
          .select()
          .eq('item_category_id', itemCategoryId)
          .single()
          .withConverter(ItemCategory.fromJson);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<PaginatedResponse<ItemCategory>> getItemCategories({
    required int pageSize,
    required int pageNumber,
    String query = '',
  }) async {
    try {
      final businessId = ref.read(businessNotifierProvider)?.businessId;
      if (businessId == null) return const PaginatedResponse(data: [], count: 0);
      final offset = (pageNumber - 1) * pageSize;
      final response = await _supabaseClient
          .from(DbConstants.itemCategories)
          .select()
          .ilike('name', '%$query%')
          .eq('business_id', businessId)
          .range(offset, pageSize + offset - 1)
          .count(CountOption.exact);
      return PaginatedResponse(
        data: response.data.map(ItemCategory.fromJson).toList(),
        count: response.count,
      );
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<ItemCategory> upsertItemCategory(ItemCategory itemCategory) async {
    try {
      final business = ref.read(businessNotifierProvider)!;
      return await _supabaseClient
          .from(DbConstants.itemCategories)
          .upsert(
            itemCategory
                .copyWith(
                  businessId: business.businessId,
                  orgId: business.orgId,
                )
                .toJson(),
          )
          .select()
          .single()
          .withConverter(ItemCategory.fromJson);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }
}
