import 'package:duxbe/features/invoice/invoice.dart';
import 'package:flutter/material.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:intl/intl.dart';

class QuoteCard extends StatelessWidget {
  const QuoteCard({
    required this.customerName,
    required this.quoteCode,
    required this.createdAt,
    required this.quoteStatus,
    required this.grandTotal,
    // required this.quote,
    required this.onTap,
    required this.isSelected,
    required this.currency,
    super.key,
  });
  // final Quote quote;
  final String customerName;
  final String quoteCode;
  final DateTime createdAt;
  final String quoteStatus;
  final double grandTotal;
  final VoidCallback onTap;
  final bool isSelected;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lightPurple : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Name and details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customerName,
                    style: AppText.mediumN.copyWith(color: AppColors.black),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.circle,
                        size: 10,
                        color: AppColors.stormyBlue,
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          quoteCode,
                          style: AppText.mediumN.copyWith(
                            color: AppColors.greyText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      const Icon(
                        Icons.circle,
                        size: 10,
                        color: AppColors.black,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('dd/MM/yyyy').format(createdAt.toLocal()),
                        style: AppText.mediumN.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    switch (quoteStatus) {
                      'sent' => 'Sent',
                      'paid' => 'Paid',
                      'refund' => 'Refunded',
                      'partiallyRefund' => 'Partially Refund',
                      'completed' => 'Completed',
                      _ => 'Draft',
                    },
                    style: AppText.mediumN.copyWith(
                      fontSize: 15,
                      color: switch (quoteStatus) {
                        'sent' => AppColors.darkBlue,
                        'paid' => AppColors.green,
                        'refund' => AppColors.orange,
                        'partiallyRefund' => AppColors.orange,
                        'completed' => AppColors.green,
                        _ => AppColors.greyText,
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Right: Amount
            Text(
              '$currency ${grandTotal.toStringAsFixed(2)}',
              style: AppText.mediumB.copyWith(
                color: AppColors.black,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InvoiceCard extends StatelessWidget {
  const InvoiceCard({
    required this.customerName,
    required this.invoiceCode,
    required this.createdAt,
    required this.invoiceStatus,
    required this.grandTotal,
    // required this.invoice,
    required this.onTap,
    required this.isSelected,
    required this.currency,
    this.status = InvoiceFormStatus.draft,
    super.key,
  });
  // final invoice invoice;
  final String customerName;
  final String invoiceCode;
  final DateTime createdAt;
  final String invoiceStatus;
  final double grandTotal;
  final VoidCallback onTap;
  final bool isSelected;
  final String currency;
  final InvoiceFormStatus status;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lightPurple : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Name and details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customerName,
                    style: AppText.mediumN.copyWith(color: AppColors.black),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.circle,
                        size: 10,
                        color: AppColors.stormyBlue,
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          invoiceCode,
                          style: AppText.mediumN.copyWith(
                            color: AppColors.greyText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      const Icon(
                        Icons.circle,
                        size: 10,
                        color: AppColors.black,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('dd/MM/yyyy').format(createdAt.toLocal()),
                        style: AppText.mediumN.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    switch (invoiceStatus) {
                      'draft' => 'Draft',
                      'paid' => 'Paid',
                      'sent' => 'Sent',
                      'overdue' => 'Overdue',
                      _ => invoiceStatus,
                    },
                    style: AppText.mediumN.copyWith(
                      fontSize: 15,
                      color: switch (invoiceStatus) {
                        'sent' => AppColors.darkBlue,
                        'paid' => AppColors.green,
                        'overdue' => AppColors.orange,
                        _ => AppColors.greyText,
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Right: Amount
            Text(
              '$currency ${grandTotal.toStringAsFixed(2)}',
              style: AppText.mediumB.copyWith(
                color: AppColors.black,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
