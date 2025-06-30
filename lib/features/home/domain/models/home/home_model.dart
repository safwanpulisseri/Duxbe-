import 'package:duxbe/shared/shared.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_model.freezed.dart';
part 'home_model.g.dart';

@freezed
class HomeModel with _$HomeModel {
  const factory HomeModel({
    @JsonKey(name: 'daily_sales') @Default(0) double dailySales,
    @JsonKey(name: 'total_incomes_current_fiscal_year') @Default(0) double totalIncomesCurrentFiscalYear,
    @JsonKey(name: 'total_expenses_current_fiscal_year') @Default(0) double totalExpensesCurrentFiscalYear,
    @JsonKey(name: 'new_customers_past_30_days') @Default(0) int newCustomersPast30Days,
    @JsonKey(name: 'top_selling_items') @Default([]) List<TopSellingItem> topSellingItems,
    @JsonKey(name: 'low_stock_items') @Default([]) List<LowStockItem> lowStockItems,
    @JsonKey(name: 'item_category_statistics') @Default([]) List<CategoryStat> itemCategoryStatistics,
  }) = _HomeModel;

  factory HomeModel.fromJson(Map<String, dynamic> json) => _$HomeModelFromJson(json);
  factory HomeModel.empty() => const HomeModel();
}

@freezed
class TopSellingItem with _$TopSellingItem {
  const factory TopSellingItem({
    @Default('') String name,
    @JsonKey(name: 'sold_count') @Default(0) int soldCount,
  }) = _TopSellingItem;

  factory TopSellingItem.fromJson(Map<String, dynamic> json) => _$TopSellingItemFromJson(json);
}

@freezed
class LowStockItem with _$LowStockItem {
  const factory LowStockItem({
    @Default('') String name,
    @JsonKey(name: 'stock_left') @Default(0) int stockLeft,
  }) = _LowStockItem;

  factory LowStockItem.fromJson(Map<String, dynamic> json) => _$LowStockItemFromJson(json);
}

@freezed
class CategoryStat with _$CategoryStat {
  const factory CategoryStat({
    @JsonKey(name: 'icon_info') required IconInfo? iconInfo,
    @JsonKey(name: 'category_name') required String categoryName,
    @JsonKey(name: 'percentage') required double percentage,
  }) = _CategoryStat;

  factory CategoryStat.fromJson(Map<String, dynamic> json) => _$CategoryStatFromJson(json);
}
