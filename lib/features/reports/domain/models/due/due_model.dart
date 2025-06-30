import 'package:duxbe/shared/shared.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'due_model.freezed.dart';
part 'due_model.g.dart';

@freezed
class Due with _$Due {
  const factory Due({
    @JsonKey(name: 'date') required DateTime date,
    @JsonKey(name: 'total_amount') required double totalAmount,
    @JsonKey(name: 'due_amount') required double dueAmount,
    @JsonKey(name: 'transaction_id') required String transactionId,
    @JsonKey(name: 'transaction_type') required String transactionType,
    @JsonKey(name: 'business_id') required String businessId,
    @JsonKey(name: 'invoice_no') required String invoiceNo,
    @JsonKey(name: 'payments') @Default([]) List<Payment> payments,
    @JsonKey(name: 'party_name') String? partyName,
  }) = _Due;

  factory Due.fromJson(Map<String, dynamic> json) => _$DueFromJson(json);
}

@freezed
class TotalDuesSummary with _$TotalDuesSummary {
  const factory TotalDuesSummary({
    @JsonKey(name: 'start_date') required String startDate,
    @JsonKey(name: 'end_date') required String endDate,
    @JsonKey(name: 'total_sales_due') @Default(0) double totalSalesDue,
    @JsonKey(name: 'sales_due_count') @Default(0) int salesDueCount,
    @JsonKey(name: 'total_purchase_due') @Default(0) double totalPurchaseDue,
    @JsonKey(name: 'purchase_due_count') @Default(0) int purchaseDueCount,
    @JsonKey(name: 'total_combined_due') @Default(0) double totalCombinedDue,
    @JsonKey(name: 'total_due_transactions') @Default(0) int totalDueTransactions,
  }) = _TotalDuesSummary;

  factory TotalDuesSummary.fromJson(Map<String, dynamic> json) => _$TotalDuesSummaryFromJson(json);
}
