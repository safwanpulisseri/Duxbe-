import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_transaction_model.freezed.dart';
part 'daily_transaction_model.g.dart';

@freezed
class DailyTransaction with _$DailyTransaction {
  const factory DailyTransaction({
    @JsonKey(name: 'date') required DateTime date,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'type') required String type,
    @JsonKey(name: 'transaction_total') required double transactionTotal,
    @JsonKey(name: 'transaction_category') required String transactionCategory,
    @JsonKey(name: 'balance') required double balance,
    @JsonKey(name: 'business_id') required String businessId,
    @JsonKey(name: 'payment_method') String? paymentMethod,
    @JsonKey(name: 'payment_id') String? paymentId,
    @JsonKey(name: 'transaction_id') String? transactionId,
    @JsonKey(name: 'reference_no') String? referenceNo,
    @JsonKey(name: 'payment_in') double? paymentIn,
    @JsonKey(name: 'payment_out') double? paymentOut,
  }) = _DailyTransaction;

  factory DailyTransaction.fromJson(Map<String, dynamic> json) => _$DailyTransactionFromJson(json);
}
