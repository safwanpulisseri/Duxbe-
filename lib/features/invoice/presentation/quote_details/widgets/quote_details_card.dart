import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/invoice/invoice.dart';
import 'package:duxbe/features/invoice/presentation/widgets/invoice_details_card.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';

class QuoteDetailsCard extends ConsumerStatefulWidget {
  const QuoteDetailsCard({
    required this.type,
    required this.invoiceNumber,
    required this.quoteDate,
    required this.expiryDate,
    required this.customerName,
    required this.customerAddress,
    required this.items,
    required this.subtotal,
    required this.cgst,
    required this.sgst,
    required this.total,
    required this.totalInWords,
    required this.note,
    required this.termsAndConditions,
    required this.currencyCode,
    super.key,
    this.referenceInvoiceNumber,
    this.businessName,
    this.businessAddress,
    this.businessGSTIN,
    this.businessPhone,
    this.businessEmail,
    this.status = QuoteFormStatus.draft,
  });
  final InvoiceType type;
  final String invoiceNumber;
  final String quoteDate;
  final String expiryDate;
  final String? referenceInvoiceNumber;
  final String customerName;
  final String customerAddress;
  final List<InvoiceItem> items;
  final double subtotal;
  final QuoteFormStatus status;
  final double cgst;
  final double sgst;
  final double total;
  final String totalInWords;
  final String note;
  final String currencyCode;
  final String termsAndConditions;
  final String? businessName;
  final String? businessAddress;
  final String? businessGSTIN;
  final String? businessPhone;
  final String? businessEmail;

  @override
  ConsumerState<QuoteDetailsCard> createState() => _QuoteDetailsCardState();
}

class _QuoteDetailsCardState extends ConsumerState<QuoteDetailsCard> {
  @override
  Widget build(BuildContext context) {
    final business = ref.read(businessNotifierProvider);
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(business!),
          const SizedBox(height: 24),
          _buildDateSection(),
          const SizedBox(height: 24),
          _buildCustomerAndItemsSection(),
          const SizedBox(height: 18),
          _buildNoteAndTerms(),
        ],
      ),
    );
  }

  Widget _buildHeader(Business business) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                business.name,
                style: AppText.heading4.copyWith(color: AppColors.primaryColor),
              ),
              const SizedBox(height: 4),
              Text(
                business.legalBusinessName ?? '',
                style: AppText.mediumB.copyWith(fontSize: 15, color: AppColors.black),
              ),
              const SizedBox(height: 2),
              Text(
                business.contactAddress ?? '',
                style: AppText.smallN.copyWith(color: AppColors.stormyBlue),
              ),
              const SizedBox(height: 2),
              Text(
               '${business.state ?? ''}, ${business.country ?? ''}',
                style: AppText.smallN.copyWith(color: AppColors.stormyBlue),
              ),
              const SizedBox(height: 2),
              Text(
                business.gstIn ?? '',
                style: AppText.smallB.copyWith(color: AppColors.stormyBlue),
              ),
              Text(
                '${business.contactPhone ?? ''}  |  ${business.contactEmail ?? ''}',
                style: AppText.smallN.copyWith(color: AppColors.stormyBlue),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 220,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.invoiceNumber,
                  style: AppText.mediumSB.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.black,
                  ),
                ),
              ),
              if (widget.type != InvoiceType.quote) ...[
                const SizedBox(height: 32),
                Text(
                  context.l10n.total,
                  style: AppText.smallM.copyWith(color: AppColors.stormyBlue),
                ),
                Text(
                  '${widget.currencyCode} ${widget.total.toStringAsFixed(2)}',
                  style: AppText.heading5.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.type == InvoiceType.credit ? 'Credit Date' : 'Quote Date',
                  style: AppText.smallN.copyWith(color: AppColors.stormyBlue),
                ),
                const SizedBox(height: 4),
                Text(widget.quoteDate, style: AppText.mediumSB),
              ],
            ),
          ),
          if (widget.type == InvoiceType.credit) ...[
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invoice Number',
                    style: AppText.smallN.copyWith(color: AppColors.stormyBlue),
                  ),
                  const SizedBox(height: 4),
                  Text(widget.referenceInvoiceNumber ?? '', style: AppText.mediumSB),
                ],
              ),
            ),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expiry Date',
                  style: AppText.smallN.copyWith(color: AppColors.stormyBlue),
                ),
                const SizedBox(height: 4),
                Text(widget.expiryDate, style: AppText.mediumSB),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerAndItemsSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bill To',
            style: AppText.smallM.copyWith(color: AppColors.stormyBlue),
          ),
          const SizedBox(height: 4),
          Text(widget.customerName, style: AppText.mediumSB),
          Text(
            widget.customerAddress,
            style: AppText.smallN,
          ),
          const SizedBox(height: 18),
          _buildItemsTable(),
          const SizedBox(height: 18),
          const Divider(
            color: Color(0xFFE0E0E0),
            height: 1,
          ),
          const SizedBox(height: 18),
          _buildTotalsSection(),
        ],
      ),
    );
  }

  Widget _buildItemsTable() {
    return Table(
      columnWidths: const <int, TableColumnWidth>{
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
        2: IntrinsicColumnWidth(),
        3: IntrinsicColumnWidth(),
        4: IntrinsicColumnWidth(),
        5: IntrinsicColumnWidth(),
      },
      border: const TableBorder(
        horizontalInside: BorderSide(color: Color(0xFFF5F5F5)),
      ),
      children: [
        TableRow(
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F5),
          ),
          children: [
            tableHeader('Sl. no.'),
            tableHeader(context.l10n.itemName),
            tableHeader(context.l10n.quantity),
            tableHeader(context.l10n.rate),
            tableHeader(context.l10n.tax),
            tableHeader(context.l10n.amount),
          ],
        ),
        ...widget.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return TableRow(
            children: [
              tableCell('${index + 1}', null),
              tableCell(item.description, item.subDescription),
              tableCell(item.quantity.toString(), null),
              tableCell(item.rate.toString(), null),
              tableCell(item.tax.toString(), null),
              tableCell(item.amount.toString(), null),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildTotalsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            rowTotal(
              context.l10n.subTotal,
              '${widget.currencyCode} ${widget.subtotal.toStringAsFixed(2)}',
              isvalueBold: true,
            ),
            rowTotal(
              'CGST9 (9%)',
              '${widget.currencyCode} ${widget.cgst.toStringAsFixed(2)}',
              isvalueBold: true,
            ),
            rowTotal(
              'SGST9 (9%)',
              '${widget.currencyCode} ${widget.sgst.toStringAsFixed(2)}',
              isvalueBold: true,
            ),
            const SizedBox(height: 8),
            rowTotal(
              context.l10n.total,
              '${widget.currencyCode} ${widget.total.toStringAsFixed(2)}',
              isvalueBold: true,
              isLabelBold: true,
            ),
            const SizedBox(height: 8),
            if (widget.type == InvoiceType.credit)
              rowTotal(
                'Credits Remaining',
                '${widget.currencyCode} ${widget.total.toStringAsFixed(2)}',
                isvalueBold: true,
                isLabelBold: true,
              ),
            const SizedBox(height: 4),
            Text(
              widget.totalInWords,
              style: AppText.smallN.copyWith(color: AppColors.stormyBlue),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoteAndTerms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.note,
          style: AppText.smallN.copyWith(color: AppColors.stormyBlue),
        ),
        const SizedBox(height: 2),
        Text(
          widget.note,
          style: AppText.smallM,
        ),
        const SizedBox(height: 18),
        Text(
          context.l10n.termsAndConditions,
          style: AppText.smallN.copyWith(color: AppColors.stormyBlue),
        ),
        const SizedBox(height: 2),
        Text(
          widget.termsAndConditions,
          style: AppText.smallM,
        ),
      ],
    );
  }

  Widget tableHeader(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Text(
          text,
          style: AppText.xSmallM.copyWith(color: AppColors.stormyBlue),
        ),
      );

  Widget tableCell(String text, String? subText) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: AppText.smallM),
            if (subText != null)
              Text(
                subText,
                style: AppText.smallN.copyWith(color: AppColors.stormyBlue),
              ),
          ],
        ),
      );

  Widget rowTotal(
    String label,
    String value, {
    bool isvalueBold = false,
    bool isLabelBold = false,
  }) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isLabelBold ? AppText.smallB : AppText.smallN,
          ),
          const SizedBox(width: 16),
          Text(value, style: isvalueBold ? AppText.smallB : AppText.smallN),
        ],
      );
}
