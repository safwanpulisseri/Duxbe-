import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'income_model.freezed.dart';
part 'income_model.g.dart';

@freezed
class Income with _$Income {
  const factory Income({
    required DateTime date,
    @JsonKey(name: 'payment_type') required PaymentMode paymentType,
    @JsonKey(name: 'income_for') required String incomeFor,
    required double amount,
    @JsonKey(name: 'income_id', includeIfNull: false) String? incomeId,
    @JsonKey(includeToJson: false) TransactionCategory? category,
    @JsonKey(name: 'income_category_id') String? incomeCategoryId,
    String? note,
    @JsonKey(name: 'reference_number') String? referenceNumber,
    @JsonKey(name: 'business_id', includeIfNull: false) String? businessId,
    @JsonKey(name: 'transaction_id', includeIfNull: false) String? transactionId,
  }) = _Income;

  factory Income.fromJson(Map<String, dynamic> json) => _$IncomeFromJson(json);
}
