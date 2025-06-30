import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense_model.freezed.dart';
part 'expense_model.g.dart';

@freezed
class Expense with _$Expense {
  const factory Expense({
    required DateTime date,
    @JsonKey(name: 'payment_type') required PaymentMode paymentType,
    @JsonKey(name: 'expense_for') required String expenseFor,
    required double amount,
    @JsonKey(name: 'expense_id', includeIfNull: false) String? expenseId,
    @JsonKey(includeToJson: false) TransactionCategory? category,
    @JsonKey(name: 'expense_category_id') String? expenseCategoryId,
    String? note,
    @JsonKey(name: 'reference_number') String? referenceNumber,
    @JsonKey(name: 'business_id', includeIfNull: false) String? businessId,
    @JsonKey(name: 'transaction_id', includeIfNull: false) String? transactionId,
  }) = _Expense;

  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);
}
