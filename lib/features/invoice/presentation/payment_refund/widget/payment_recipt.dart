import 'package:duxbe/features/invoice/invoice.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';

class PaymentRecipt extends ConsumerStatefulWidget {
  const PaymentRecipt({required this.paymentReceived, super.key});
  final PaymentReceived paymentReceived;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _State();
}

class _State extends ConsumerState<PaymentRecipt> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.paymentReceived.business?.name ?? '',
                      style: AppText.heading4.copyWith(color: AppColors.primaryColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.paymentReceived.business?.legalBusinessName ?? '',
                      style: AppText.mediumB.copyWith(fontSize: 15, color: AppColors.black),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.paymentReceived.business?.contactAddress ?? '',
                      style: AppText.smallN.copyWith(color: AppColors.stormyBlue),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.paymentReceived.business?.gstIn ?? '',
                      style: AppText.smallB.copyWith(
                        color: AppColors.stormyBlue,
                      ),
                    ),
                    Text(
                      '${widget.paymentReceived.business?.contactPhone}  |  ${widget.paymentReceived.business?.contactEmail}',
                      style: AppText.smallN.copyWith(color: AppColors.stormyBlue),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.paymentReceived.paymentCode ?? '',
                  style: AppText.mediumSB.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            context.l10n.paymentReceipt.toUpperCase(),
            style: AppText.xLargeSB.copyWith(color: AppColors.primaryColor),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.amountReceived,
                        style: AppText.xLargeSB.copyWith(color: AppColors.stormyBlue),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.paymentReceived.business?.currency?.code ?? ''} ${widget.paymentReceived.amountReceived?.toStringAsFixed(2) ?? ''}',
                        style: AppText.heading2,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AmountToWordsConverter.convertToWordsOnly(widget.paymentReceived.amountReceived ?? 0),
                        style: AppText.mediumSB,
                      ),
                      const SizedBox(height: 30),
                      _dataRow(
                        label: context.l10n.receivedFrom,
                        value: widget.paymentReceived.customer?.name ?? '',
                      ),
                      const SizedBox(height: 16),
                      _dataRow(
                        label: context.l10n.paymentDate,
                        value: widget.paymentReceived.paymentDate?.toLocal().toString() ?? '',
                      ),
                      const SizedBox(height: 16),
                      _dataRow(
                        label: context.l10n.referenceNumber,
                        value: widget.paymentReceived.paymentCode ?? '',
                      ),
                      const SizedBox(height: 16),
                      _dataRow(
                        label: context.l10n.paymentMode,
                        value: widget.paymentReceived.paymentMode?.name ?? '',
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dataRow({required String label, required String value}) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppText.smallN,
          ),
        ),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Text(
                value,
                style: AppText.smallB,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
