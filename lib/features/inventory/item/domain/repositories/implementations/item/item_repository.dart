import 'dart:convert';

import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'item_repository.g.dart';

@Riverpod(keepAlive: true)
IItemRepository itemRepo(ItemRepoRef ref) => ItemRepository(ref);

class ItemRepository implements IItemRepository {
  ItemRepository(this.ref) : _supabaseClient = ref.watch(supabaseProvider);

  final ItemRepoRef ref;
  final SupabaseClient _supabaseClient;

  @override
  Future<void> deleteItem(String itemId) async {
    try {
      final businessId = ref.read(businessNotifierProvider)?.businessId;
      if (businessId == null) return;
      await _supabaseClient.rpc<void>(
        RPCConstants.archiveItem,
        params: {
          'p_item_id': itemId,
          'p_business_id': businessId,
        },
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
  Future<void> createBulkItem(
    List<Map<String, dynamic>> data, {
    required bool skipDuplicates,
  }) async {
    try {
      final businessId = ref.read(businessNotifierProvider)?.businessId;
      if (businessId == null) return;
      await _supabaseClient.rpc<void>(
        RPCConstants.bulkInsertItems,
        params: {
          'p_import_data': {
            'p_items': data,
            'p_business_id': businessId,
            'p_skip_duplicates': skipDuplicates,
          },
        },
      );
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    }
  }

  @override
  Future<Item?> getItemWithId({required String itemId}) async {
    try {
      return await _supabaseClient
          .from(DbConstants.vwItems)
          .select()
          .eq('item_id', itemId)
          .single()
          .withConverter(Item.fromJson);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<PaginatedResponse<Item>> getItems({
    required int pageSize,
    required int pageNumber,
    String query = '',
    String? itemType,
    bool? salesEnabled,
    bool? purchaseEnabled,
    List<ItemCategory>? categories,
    String? stockStatus,
    bool? excludeCurrentBusiness,
    bool? isActive,
  }) async {
    try {
      final businessId = ref.read(businessNotifierProvider)?.businessId;
      if (businessId == null) return const PaginatedResponse(data: [], count: 0);
      final offset = (pageNumber - 1) * pageSize;
      final queryFiltered = query.replaceAll(RegExp(r'[^a-zA-Z0-9\s-]'), '');
      var queryBuilder = _supabaseClient
          .from(DbConstants.vwItems)
          .select()
          // .textSearch(
          //       'search_text',
          //       queryFiltered,
          //     );
          .or(
        '''name.ilike.%$queryFiltered%, item_code.ilike.%$queryFiltered%, item_category->>name.ilike.%$queryFiltered%, serial_nos.cs.{"$queryFiltered"}''',
      );

      if (itemType?.isNotEmpty ?? false) {
        queryBuilder = queryBuilder.eq('item_type', itemType!);
      }
      if (salesEnabled ?? false) {
        queryBuilder = queryBuilder.eq('sales_enabled', true);
      }
      if (purchaseEnabled ?? false) {
        queryBuilder = queryBuilder.eq('purchase_enabled', true);
      }
      if (isActive != null) {
        queryBuilder = queryBuilder.eq('is_active', isActive);
      } else {
        queryBuilder = queryBuilder.eq('is_active', true);
      }
      if (categories != null && categories.isNotEmpty) {
        queryBuilder = queryBuilder.inFilter(
          'item_category_id',
          categories.map((e) => e.itemCategoryId).toList(),
        );
      }
      if (stockStatus != null) {
        queryBuilder = queryBuilder.eq('stock_status', stockStatus);
      }

      if (excludeCurrentBusiness ?? false) {
        queryBuilder =
            queryBuilder.neq('business_id', businessId).eq('org_id', ref.read(businessNotifierProvider)!.orgId);
      } else {
        queryBuilder = queryBuilder.eq('business_id', businessId);
      }

      final response = await queryBuilder.range(offset, pageSize + offset - 1).count(CountOption.exact);
      return PaginatedResponse(
        data: response.data.map(Item.fromJson).toList(),
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
  Future<void> upsertItem(
    Map<String, dynamic> item,
    List<ItemImage> images, {
    List<ItemImage> initialImages = const [],
  }) async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      final itemImages = await upsertItemImages(initialImages, images, businessId);

      debugPrint(
        jsonEncode({
          ...item,
          'business_id': ref.read(businessNotifierProvider)!.businessId,
          'org_id': ref.read(businessNotifierProvider)!.orgId,
          'images': itemImages.map((e) => e.toJson()).toList(),
        }),
      );

      await _supabaseClient.rpc<String>(
        RPCConstants.upsertItem,
        params: {
          'item_json': {
            ...item,
            'business_id': ref.read(businessNotifierProvider)!.businessId,
            'org_id': ref.read(businessNotifierProvider)!.orgId,
            'images': itemImages.map((e) => e.toJson()).toList(),
          },
        },
      );

      return;
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  Future<List<ItemImage>> upsertItemImages(
    List<ItemImage> initialImages,
    List<ItemImage> images,
    String businessId,
  ) async {
    final oldImageUrls = initialImages.where((element) => element.url != null).map((e) => e.url!).toList();

    final newUploads = images.map((element) async {
      if (element.bytes == null) {
        return element;
      }
      final fileName = '${DateTime.now().toIso8601String()}.png';
      final url = ref.read(supabaseStorageProvider).uploadImage(
            businessId: businessId,
            fileName: fileName,
            filePath: 'item_images',
            file: element.bytes!,
          );
      element.url = await url;
      return element;
    });

    final newImages = (await Future.wait(newUploads)).toList();
    final newImageUrls = newImages.where((element) => element.url != null).map((e) => e.url!).toList();

    // Delete old images that are not in the new list
    for (final oldImage in oldImageUrls) {
      if (!newImageUrls.contains(oldImage)) {
        await ref.read(supabaseStorageProvider).deleteImage(
              businessId: businessId,
              fileName: oldImage.split('/').last,
              filePath: 'item_images',
            );
      }
    }
    return newImages;
  }

  @override
  Future<List<CustomField>> getCustomFields() async {
    try {
      final businessId = ref.read(businessNotifierProvider)?.businessId;
      if (businessId == null) return [];
      final response =
          await _supabaseClient.from(DbConstants.itemCustomFieldDefinitions).select().eq('business_id', businessId);
      return response.map(CustomField.fromJson).toList();
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<String> getNextItemCode() async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      final response = await _supabaseClient.rpc<String>(
        RPCConstants.getNextItemCode,
        params: {'business_id': businessId},
      );
      return response;
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<PaginatedResponse<StockAdjustments>> getStockAdjustments({
    required int pageSize,
    required int pageNumber,
    String query = '',
  }) async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      final offset = (pageNumber - 1) * pageSize;
      final response = await _supabaseClient
          .from(DbConstants.vwStockAdjustments)
          .select()
          .ilike('reference', '%$query%')
          .eq('business_id', businessId)
          .range(offset, pageSize + offset - 1)
          .count(CountOption.exact);
      return PaginatedResponse(
        data: response.data.map(StockAdjustments.fromJson).toList(),
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
  Future<StockAdjustments?> getStockAdjustmentWithId({
    required String adjustmentId,
  }) async {
    try {
      return await _supabaseClient
          .from(DbConstants.vwStockAdjustments)
          .select()
          .eq('adjustment_id', adjustmentId)
          .single()
          .withConverter(StockAdjustments.fromJson);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<void> adjustStock(Map<String, dynamic> adjustments) async {
    try {
      debugPrint(
        jsonEncode({
          'p_adjustment_json': adjustments,
          'p_business_id': ref.read(businessNotifierProvider)!.businessId,
          'p_org_id': ref.read(businessNotifierProvider)!.orgId,
        }),
      );

      await _supabaseClient.rpc<String>(
        RPCConstants.adjustStock,
        params: {
          'p_adjustment_json': adjustments,
          'p_business_id': ref.read(businessNotifierProvider)!.businessId,
          'p_org_id': ref.read(businessNotifierProvider)!.orgId,
        },
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
  Future<void> deleteStockAdjustment(String adjustmentId) async {
    try {
      await _supabaseClient.rpc<String>(
        RPCConstants.reverseStockAdjustment,
        params: {
          'p_original_adjustment_id': adjustmentId,
        },
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
  Future<num> getTotalStockValue() async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      final response = await _supabaseClient
          .from(DbConstants.vwItems)
          .select('stock_value.sum()')
          .eq('business_id', businessId)
          .single();
      return response['sum'] as num? ?? 0;
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }
}
