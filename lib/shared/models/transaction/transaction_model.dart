// ignore_for_file: constant_identifier_names

import 'package:duxbe/shared/shared.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart';

@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    @JsonKey(name: 'transaction_id') required String transactionId,
    @JsonKey(name: 'reference_no') required String referenceNo,
    @JsonKey(name: 'transaction_type') required TransactionType transactionType,
    @JsonKey(name: 'transaction_date') required DateTime transactionDate,
    @JsonKey(name: 'status') required TransactionStatus status,
    @JsonKey(name: 'total_amount') required double totalAmount,
    @JsonKey(name: 'paid_amount') required double paidAmount,
    @JsonKey(name: 'due_amount') required double dueAmount,
    @JsonKey(name: 'business_id') required String businessId,
    @JsonKey(name: 'created_by') required String createdBy,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'metadata') required Map<String, dynamic>? metadata,
    @JsonKey(name: 'due_date') DateTime? dueDate,
    @JsonKey(name: 'notes') String? notes,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
}

@freezed
class TransactionEntry with _$TransactionEntry {
  const factory TransactionEntry({
    @JsonKey(name: 'entry') required Entry entry,
    @JsonKey(name: 'account') required Account account,
  }) = _TransactionEntry;

  factory TransactionEntry.fromJson(Map<String, dynamic> json) => _$TransactionEntryFromJson(json);
}

@freezed
class Entry with _$Entry {
  const factory Entry({
    @JsonKey(name: 'entry_id') required String entryId,
    @JsonKey(name: 'transaction_id') required String transactionId,
    @JsonKey(name: 'account_id') required String accountId,
    @JsonKey(name: 'entry_type') required EntryType entryType,
    @JsonKey(name: 'amount') required double amount,
    @JsonKey(name: 'description') required String description,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Entry;

  factory Entry.fromJson(Map<String, dynamic> json) => _$EntryFromJson(json);
}

@freezed
class Account with _$Account {
  const factory Account({
    @JsonKey(name: 'account_id') required String accountId,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'code') required String code,
    @JsonKey(name: 'description') required String description,
    @JsonKey(name: 'is_system') required bool isSystem,
    @JsonKey(name: 'business_id') required String businessId,
    @JsonKey(name: 'org_id') required String orgId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'balance') required double balance,
    @JsonKey(name: 'category_id') required String categoryId,
  }) = _Account;

  factory Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);
}

@freezed
class Payment with _$Payment {
  const factory Payment({
    @JsonKey(name: 'payment_id') required String paymentId,
    @JsonKey(name: 'transaction_id') required String transactionId,
    @JsonKey(name: 'payment_date') required DateTime paymentDate,
    @JsonKey(name: 'amount') required double amount,
    @JsonKey(name: 'payment_method') required PaymentMode paymentMethod,
    @JsonKey(name: 'reference_no') required String? referenceNo,
    @JsonKey(name: 'notes') required String? notes,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'created_by') required String createdBy,
    @JsonKey(name: 'metadata') required Map<String, dynamic>? metadata,
  }) = _Payment;

  factory Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);
}
