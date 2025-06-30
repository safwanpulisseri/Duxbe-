import 'package:duxbe/features/invoice/invoice.dart';
import 'package:flutter/material.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:intl/intl.dart';

class CreditNoteCard extends StatelessWidget {
  const CreditNoteCard({
    required this.customerName,
    required this.creditCode,
    required this.createdAt,
    required this.creditStatus,
    required this.grandTotal,
    // required this.credit,
    required this.onTap,
    required this.isSelected,
    required this.currency,
    super.key,
  });
  // final credit credit;
  final String customerName;
  final String creditCode;
  final DateTime createdAt;
  final CreditNoteFormStatus creditStatus;
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
                          creditCode,
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
                    creditStatus.name,
                    style: AppText.mediumN.copyWith(
                      fontSize: 15,
                      color: switch (creditStatus.name) {
                        'open' => AppColors.green,
                        _ => AppColors.orange,
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
