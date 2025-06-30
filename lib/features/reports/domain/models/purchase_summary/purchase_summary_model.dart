import 'package:freezed_annotation/freezed_annotation.dart';

part 'purchase_summary_model.freezed.dart';
part 'purchase_summary_model.g.dart';

@freezed
class PurchaseSummary with _$PurchaseSummary {
  const factory PurchaseSummary({
    @JsonKey(name: 'total_purchase_amount') @Default(0) double totalPurchaseAmount,
    @JsonKey(name: 'total_due') @Default(0) double totalDue,
    @JsonKey(name: 'total_paid') @Default(0) double totalPaid,
    @JsonKey(name: 'total_purchase_count') @Default(0) int totalPurchaseCount,
  }) = _PurchaseSummary;

  factory PurchaseSummary.fromJson(Map<String, dynamic> json) => _$PurchaseSummaryFromJson(json);
}
