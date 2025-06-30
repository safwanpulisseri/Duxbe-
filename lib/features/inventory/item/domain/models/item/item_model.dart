import 'dart:typed_data';

import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/features/purchase/domain/models/supplier/supplier_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'item_model.freezed.dart';
part 'item_model.g.dart';

enum ItemType { goods, services }

@freezed
class Item with _$Item {
  @JsonSerializable(explicitToJson: true)
  const factory Item({
    @JsonKey(name: 'item_type') required ItemType itemType,
    @JsonKey(name: 'item_code') required String itemCode,
    @JsonKey(name: 'sales_enabled') required bool salesEnabled,
    @JsonKey(name: 'purchase_enabled') required bool purchaseEnabled,
    @JsonKey(name: 'inventory_enabled') required bool inventoryEnabled,
    @JsonKey(name: 'is_returnable') required bool isReturnable,
    @JsonKey(name: 'is_tax_inclusive') required bool isTaxInclusive,
    @JsonKey(name: 'retail_price') required double retailPrice,
    @JsonKey(name: 'quantity') required double quantity,
    @JsonKey(name: 'sale_price') required double salePrice,
    @JsonKey(name: 'stock_value') required double stockValue,
    @JsonKey(name: 'opening_stock_value') required double openingStockValue,
    @JsonKey(name: 'stock_quantity') required double stockQuantity,
    @JsonKey(name: 'opening_stock_qty') required double openingStockQty,
    @JsonKey(name: 'branch_variant_id') required String branchVariantId,
    @JsonKey(name: 'stock_status') required String stockStatus,
    required String name,
    @Default(0) @JsonKey(name: 'purchase_price') double purchasePrice,
    @Default(0) @JsonKey(name: 'alert_quantity') double alertQuantity,
    @JsonKey(name: 'item_id', includeIfNull: false) String? itemId,
    @JsonKey(name: 'preferred_vendor_id') String? preferredVendorId,
    @JsonKey(name: 'item_category_id') String? itemCategoryId,
    @JsonKey(name: 'brand_id') String? brandId,
    @JsonKey(name: 'tax_id') String? taxId,
    @JsonKey(name: 'unit_id') String? unitId,
    @JsonKey(name: 'rich_text') String? richText,
    @JsonKey(name: 'business_id', includeIfNull: false) String? businessId,
    @JsonKey(name: 'org_id', includeIfNull: false) String? orgId,
    @Default([]) @JsonKey(name: 'serial_nos') List<String> serialNos,
    @Default([]) @JsonKey(name: 'images') List<ItemImage> images,
    @Default([]) @JsonKey(name: 'sub_services') List<SubService> subServices,
    @JsonKey(name: 'item_category') ItemCategory? itemCategory,
    @JsonKey(name: 'custom_fields', includeIfNull: false) Map<String, Field>? customFields,
    Brand? brand,
    Unit? unit,
    Tax? tax,
    @JsonKey(name: 'preferred_vendor', includeIfNull: false, includeToJson: false, includeFromJson: true)
    Supplier? preferredSupplier,
    @Default([])
    @JsonKey(
      name: 'selected_sub_services',
      includeIfNull: false,
      includeFromJson: true,
    )
    List<SubService> selectedSubServices,
  }) = _Item;

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
  factory Item.empty() => const Item(
        itemType: ItemType.goods,
        itemCode: '',
        salesEnabled: false,
        purchaseEnabled: false,
        inventoryEnabled: false,
        isReturnable: false,
        retailPrice: 0,
        quantity: 0,
        salePrice: 0,
        stockValue: 0,
        stockQuantity: 0,
        openingStockValue: 0,
        openingStockQty: 0,
        branchVariantId: '',
        name: '',
        preferredVendorId: '',
        itemCategoryId: '',
        brandId: '',
        taxId: '',
        unitId: '',
        richText: '',
        stockStatus: '',
        isTaxInclusive: false,
      );
}

@unfreezed
class ItemImage with _$ItemImage {
  @JsonSerializable(explicitToJson: true)
  factory ItemImage({
    @Default(false) @JsonKey(name: 'is_thumbnail') bool isThumbnail,
    String? url,
    @JsonKey(includeFromJson: false, includeToJson: false) Uint8List? bytes,
  }) = _ItemIImage;
  factory ItemImage.fromJson(Map<String, dynamic> json) => _$ItemImageFromJson(json);
}

@freezed
class SubService with _$SubService {
  @JsonSerializable(explicitToJson: true)
  const factory SubService({
    required String name,
    @JsonKey(name: 'additional_price') required double additionalPrice,
    @JsonKey(name: 'sub_service_id', includeIfNull: true) String? subServiceId,
    @Default(1) @JsonKey(name: 'quantity') double quantity,
    @JsonKey(name: 'service_id', includeIfNull: false) String? serviceId,
  }) = _SubService;
  factory SubService.fromJson(Map<String, dynamic> json) => _$SubServiceFromJson(json);
}

@freezed
class Field with _$Field {
  @JsonSerializable(explicitToJson: true)
  const factory Field({
    required String type,
    required bool required,
    String? value,
  }) = _Field;

  factory Field.fromJson(Map<String, dynamic> json) => _$FieldFromJson(json);
}
