import 'package:freezed_annotation/freezed_annotation.dart';

part 'sales_summary_model.freezed.dart';
part 'sales_summary_model.g.dart';

@freezed
class SalesSummary with _$SalesSummary {
  const factory SalesSummary({
    @JsonKey(name: 'total_sales_amount') @Default(0) double totalSalesAmount,
    @JsonKey(name: 'total_due') @Default(0) double totalDue,
    @JsonKey(name: 'total_paid') @Default(0) double totalPaid,
    @JsonKey(name: 'total_sales_count') @Default(0) int totalSalesCount,
  }) = _SalesSummary;

  factory SalesSummary.fromJson(Map<String, dynamic> json) =>
      _$SalesSummaryFromJson(json);
}

@freezed
class DailyTransactionSummary with _$DailyTransactionSummary {
  const factory DailyTransactionSummary({
    @JsonKey(name: 'total_transactions') @Default(0) int totalTransactions,
    @JsonKey(name: 'total_payments_in') @Default(0) double totalPaymentsIn,
    @JsonKey(name: 'total_payments_out') @Default(0) double totalPaymentsOut,
    @JsonKey(name: 'net_balance_change') @Default(0) double netBalanceChange,
  }) = _DailyTransactionSummary;

  factory DailyTransactionSummary.fromJson(Map<String, dynamic> json) =>
      _$DailyTransactionSummaryFromJson(json);
}
@freezed
class EmployeeSalesSummary with _$EmployeeSalesSummary {
  const factory EmployeeSalesSummary({
    @JsonKey(name: 'total_employees') @Default(0) int totalEmployees,
    @JsonKey(name: 'total_items_sold') @Default(0) int totalItemsSold,
    @JsonKey(name: 'total_revenue_generated') @Default(0) double totalRevenueGenerated,
  }) = _EmployeeSalesSummary;

  factory EmployeeSalesSummary.fromJson(Map<String, dynamic> json) => _$EmployeeSalesSummaryFromJson(json);
}
