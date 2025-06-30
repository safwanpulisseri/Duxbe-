import 'package:freezed_annotation/freezed_annotation.dart';

part 'profit_and_loss_model.freezed.dart';
part 'profit_and_loss_model.g.dart';

@freezed
class ProfitAndLoss with _$ProfitAndLoss {
  const factory ProfitAndLoss({
    @Default('') @JsonKey(name: 'period_start_date') String periodStartDate,
    @Default('') @JsonKey(name: 'period_end_date') String periodEndDate,
    @Default(0) @JsonKey(name: 'revenue_products') double revenueProducts,
    @Default(0) @JsonKey(name: 'revenue_services') double revenueServices,
    @Default(0) @JsonKey(name: 'revenue_shipping') double revenueShipping,
    @Default(0) @JsonKey(name: 'sales_discounts_total') double salesDiscountsTotal,
    @Default(0) @JsonKey(name: 'net_sales_revenue') double netSalesRevenue,
    @Default(0) @JsonKey(name: 'cogs_products_total') double cogsProductsTotal,
    @Default(0) @JsonKey(name: 'freight_in_total') double freightInTotal,
    @Default(0) @JsonKey(name: 'purchase_discounts_total') double purchaseDiscountsTotal,
    @Default(0) @JsonKey(name: 'net_cogs') double netCogs,
    @Default(0) @JsonKey(name: 'gross_profit') double grossProfit,
    @Default(0) @JsonKey(name: 'income_general') double incomeGeneral,
    @Default(0) @JsonKey(name: 'income_stock_overage') double incomeStockOverage,
    @Default(0) @JsonKey(name: 'total_other_income') double totalOtherIncome,
    @Default(0) @JsonKey(name: 'total_operating_expenses') double totalOperatingExpenses,
    @Default(0) @JsonKey(name: 'net_income_loss') double netIncomeLoss,
  }) = _ProfitAndLoss;

  factory ProfitAndLoss.fromJson(Map<String, dynamic> json) => _$ProfitAndLossFromJson(json);
}
