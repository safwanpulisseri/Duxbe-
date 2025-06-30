import 'package:freezed_annotation/freezed_annotation.dart';

part 'ledger_model.freezed.dart';
part 'ledger_model.g.dart';

// {
//   "total_sales": 1090,
//   "total_purchases": 2250,
//   "total_received_sales": 470,
//   "total_customer_dues": 340,
//   "total_supplier_dues": 0
// }

@freezed
class Ledger with _$Ledger {
  const factory Ledger({
    @Default(0) @JsonKey(name: 'total_sales') double totalSales,
    @Default(0) @JsonKey(name: 'total_received_sales') double totalReceivedSales,
    @Default(0) @JsonKey(name: 'total_purchases') double totalPurchases,
    @Default(0) @JsonKey(name: 'total_customer_dues') double totalCustomerDues,
    @Default(0) @JsonKey(name: 'total_supplier_dues') double totalSupplierDues,
  }) = _Ledger;

  factory Ledger.fromJson(Map<String, dynamic> json) => _$LedgerFromJson(json);
}

@freezed
class Party with _$Party {
  const factory Party({
    required String id,
    @JsonKey(name: 'business_id') required String businessId,
    required TransactionParty type,
    required double amount,
    String? name,
    @Default(0) @JsonKey(name: 'due_amount') double? dueAmount,
  }) = _Party;

  factory Party.fromJson(Map<String, dynamic> json) => _$PartyFromJson(json);
}

// {
//   "total": 1200,
//   "total_paid": 1300,
//   "total_due": -100
// }

@freezed
class PartyDetails with _$PartyDetails {
  const factory PartyDetails({
    @Default(0) @JsonKey(name: 'total') double total,
    @Default(0) @JsonKey(name: 'total_paid') double totalPaid,
    @Default(0) @JsonKey(name: 'total_due') double totalDue,
  }) = _PartyDetails;

  factory PartyDetails.fromJson(Map<String, dynamic> json) => _$PartyDetailsFromJson(json);
}

enum TransactionParty { customer, supplier, all }
