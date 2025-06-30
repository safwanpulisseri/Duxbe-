import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/purchase/purchase.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';

class PurchaseDetailsScreenMobile extends ConsumerStatefulWidget {
  const PurchaseDetailsScreenMobile({required this.purchase, super.key});
  final PurchaseView purchase;

  @override
  ConsumerState<PurchaseDetailsScreenMobile> createState() => _PurchaseDetailsScreenMobileState();
}

class _PurchaseDetailsScreenMobileState extends ConsumerState<PurchaseDetailsScreenMobile> {
  @override
  Widget build(BuildContext context) {
    final currency = context.read(currencyProvider);
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(context.l10n.purchaseDetails),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.greyBorder),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      Text('$currency${widget.purchase.totalAmount}', style: AppText.b32),
                      const SizedBox(height: 6),
                      Text(widget.purchase.invoiceNo, style: AppText.xLargeSB.copyWith(color: AppColors.blue)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: widget.purchase.dueAmount > 0
                              ? AppColors.red.withOpacity(0.1)
                              : AppColors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.purchase.dueAmount > 0 ? context.l10n.due : context.l10n.paid,
                          style: AppText.mediumN
                              .copyWith(color: widget.purchase.dueAmount > 0 ? AppColors.red : AppColors.green),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppColors.lightPurple),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      Text(widget.purchase.supplier.name, style: AppText.xLargeB.copyWith(color: AppColors.title)),
                      if (widget.purchase.supplier.phone.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          widget.purchase.supplier.phone,
                          style: AppText.mediumN.copyWith(color: AppColors.greyish2),
                        ),
                      ],
                    ],
                  ),
                ),
                const Divider(color: AppColors.lightPurple),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Text(
                    widget.purchase.purchaseDate.toLocal().toTime12WithDayWithMonthFormat,
                    style: AppText.smallN.copyWith(color: AppColors.stormyBlue),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.greyBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.salePersonDetails, style: AppText.smallM.copyWith(color: AppColors.stormyBlue)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // CircleAvatar
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.lightPurple,
                          backgroundImage: widget.purchase.employee.image != null
                              ? NetworkImage(widget.purchase.employee.image!)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.purchase.employee.name,
                              style: AppText.xLargeSB.copyWith(color: AppColors.primaryColor),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.purchase.employee.email,
                              style: AppText.smallN.copyWith(color: AppColors.stormyBlue),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xffF1F3FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.l10n.paymentDetails, style: AppText.largeSB.copyWith(color: AppColors.primaryColor)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${context.l10n.totalAmount}:',
                              style: AppText.mediumN.copyWith(color: AppColors.primaryColor),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '$currency${widget.purchase.totalAmount}',
                              style: AppText.mediumEB.copyWith(color: AppColors.primaryColor),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${context.l10n.paymentStatus}:',
                              style: AppText.mediumN.copyWith(color: AppColors.primaryColor),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.purchase.dueAmount > 0 ? context.l10n.due : context.l10n.paid,
                              style: AppText.mediumN
                                  .copyWith(color: widget.purchase.dueAmount > 0 ? AppColors.red : AppColors.green),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${context.l10n.dueAmount}:',
                              style: AppText.mediumN.copyWith(color: AppColors.primaryColor),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '$currency${widget.purchase.dueAmount}',
                              style: AppText.mediumN.copyWith(color: AppColors.primaryColor),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${context.l10n.paymentMethod}:',
                              style: AppText.mediumN.copyWith(color: AppColors.primaryColor),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.purchase.payments.map((e) => e.paymentMethod.name.displayCase).toSet().join(', '),
                              style: AppText.mediumN.copyWith(color: AppColors.primaryColor),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(context.l10n.paymentLastUpdated, style: AppText.smallM.copyWith(color: AppColors.stormyBlue)),
                const SizedBox(height: 8),
                Text(
                  widget.purchase.updatedAt.toLocal().toTime12WithDayWithMonthFormat,
                  style: AppText.smallN.copyWith(color: AppColors.primaryColor),
                ),
                const SizedBox(height: 12),
                Text(context.l10n.purchaseInvoiceNumber, style: AppText.smallM.copyWith(color: AppColors.stormyBlue)),
                const SizedBox(height: 8),
                Text(
                  widget.purchase.purchaseInvoice,
                  style: AppText.smallN.copyWith(color: AppColors.primaryColor),
                ),
                if (widget.purchase.dueAmount > 0) ...[
                  const SizedBox(height: 12),
                  AppButton(
                    color: AppColors.green,
                    label: Text(context.l10n.updatePayment, style: AppText.mediumSB),
                    onPress: () {},
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.greyBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(context.l10n.namePrice, style: AppText.smallSB.copyWith(color: AppColors.grey)),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 40,
                      child: Text(context.l10n.qty, style: AppText.smallSB.copyWith(color: AppColors.grey)),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 80,
                      child: Text(
                        context.l10n.amount,
                        style: AppText.smallSB.copyWith(color: AppColors.grey),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                const Divider(color: AppColors.lightPurple),
                for (final item in widget.purchase.purchaseItems)
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.item.name, style: AppText.smallSB.copyWith(color: AppColors.black)),
                            Text(
                              currency + item.unitPrice.toString(),
                              style: AppText.smallSB.copyWith(color: AppColors.black.withOpacity(0.5)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 40,
                        child: Text(item.quantity.toString(), style: AppText.smallSB.copyWith(color: AppColors.black)),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 80,
                        child: Text(
                          currency + item.totalPrice.toString(),
                          style: AppText.smallSB.copyWith(color: AppColors.black),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.greyBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(context.l10n.subTotal, style: AppText.mediumM.copyWith(color: AppColors.title)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$currency${widget.purchase.subTotal}',
                        style: AppText.mediumN.copyWith(color: AppColors.primaryColor),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(context.l10n.discount, style: AppText.mediumM.copyWith(color: AppColors.title)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$currency${widget.purchase.discountAmount}',
                        style: AppText.mediumN.copyWith(color: AppColors.primaryColor),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(context.l10n.taxAmount, style: AppText.mediumM.copyWith(color: AppColors.title)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$currency${widget.purchase.taxAmount}',
                        style: AppText.mediumN.copyWith(color: AppColors.primaryColor),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(context.l10n.shipping, style: AppText.mediumM.copyWith(color: AppColors.title)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$currency${widget.purchase.shippingCharge}',
                        style: AppText.mediumN.copyWith(color: AppColors.primaryColor),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.greyBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(context.l10n.total, style: AppText.mediumM.copyWith(color: AppColors.title)),
                Text(
                  '$currency${widget.purchase.totalAmount}',
                  style: AppText.mediumB.copyWith(color: AppColors.primaryColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (widget.purchase.attachmentURL != null || true) ...[
            InkWell(
              borderRadius: BorderRadius.circular(8).resolve(TextDirection.ltr),
              splashColor: Colors.transparent,
              onTap: () {
                FileDownloader.downloadFile(
                  url: widget.purchase.attachmentURL!,
                  filename: widget.purchase.attachmentURL?.split('/').lastOrNull ?? 'Attachment',
                );
              },
              child: Ink(
                decoration: BoxDecoration(
                  color: const Color(0xffEFF7FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.greyBorder),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.purchase.attachmentURL?.split('/').lastOrNull ?? context.l10n.attachment,
                        style: AppText.mediumM.copyWith(color: AppColors.darkBlue),
                      ),
                      Text(context.l10n.download, style: AppText.mediumB.copyWith(color: AppColors.darkBlue)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          ref.watch(purchaseAuditsProvider(widget.purchase.purchaseId)).when(
                data: (data) => data.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.l10n.auditHistory, style: AppText.smallM.copyWith(color: AppColors.stormyBlue)),
                          ...data.map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                '${ widget.purchase.employee!.name} - ${e.changeDetails ?? '-'} On ${e.actionTimestamp.toLocal().toTime12WithDayWithMonthFormat}',
                                style: AppText.xSmallN.copyWith(color: AppColors.stormyBlue),
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
                error: (error, stackTrace) => Text(error.toString()),
                loading: () =>  Text(context.l10n.loading),
              ),
          const SizedBox(height: 12),
          AppButton(
            style: ButtonStyles.cancel,
            label: Text(context.l10n.printInvoice, style: AppText.mediumSB.copyWith(color: AppColors.primaryColor)),
            onPress: () {
              PdfService.printPurchaseInvoice(widget.purchase);
            },
          ),
        ],
      ),
    );
  }
}
