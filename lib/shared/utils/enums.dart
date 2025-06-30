// ignore_for_file: constant_identifier_names

enum PaymentMode { cash, card, bank }

enum TransactionType {
  SALE,
  PURCHASE,
  SALE_RETURN,
  PURCHASE_RETURN,
  INCOME,
  EXPENSE,
  PAYMENT_RECEIVED,
  PAYMENT_MADE,
  ASSET_PURCHASE,
  ASSET_SALE,
  ADJUSTMENT
}

enum TransactionStatus { PENDING, PARTIALLY_PAID, PAID, VOID, CANCELLED }

enum EntryType { DEBIT, CREDIT }
