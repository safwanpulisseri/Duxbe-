import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/sale/presentation/customer_list/customer_settlement.dart';
import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';

class SaleDetailsScreenMobile extends ConsumerStatefulWidget {
  const SaleDetailsScreenMobile({required this.sale, super.key});
  final SaleView sale;

  @override
  ConsumerState<SaleDetailsScreenMobile> createState() => _SaleDetailsScreenMobileState();
}

class _SaleDetailsScreenMobileState extends ConsumerState<SaleDetailsScreenMobile> {
  @override
  Widget build(BuildContext context) {
    final currency = context.read(currencyProvider);
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(context.l10n.saleDetails),
      ),
      body: SafeArea(
        child: ListView(
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
                        Text('$currency${widget.sale.totalAmount}', style: AppText.b32),
                        const SizedBox(height: 6),
                        Text(widget.sale.saleInvoice, style: AppText.xLargeSB.copyWith(color: AppColors.blue)),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 8,
                          children: [
                            StatusContainer(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              label: widget.sale.transaction.status.name.displayCase,
                              labelColor: switch (widget.sale.transaction.status) {
                                TransactionStatus.CANCELLED => AppColors.red,
                                TransactionStatus.PENDING => AppColors.orange,
                                TransactionStatus.PAID => AppColors.green,
                                TransactionStatus.PARTIALLY_PAID => AppColors.warning,
                                TransactionStatus.VOID => AppColors.grey,
                              },
                              backgroundColor: switch (widget.sale.transaction.status) {
                                TransactionStatus.CANCELLED => AppColors.red.withOpacity(0.12),
                                TransactionStatus.PENDING => AppColors.orange.withOpacity(0.12),
                                TransactionStatus.PAID => AppColors.green.withOpacity(0.12),
                                TransactionStatus.PARTIALLY_PAID => AppColors.warning.withOpacity(0.12),
                                TransactionStatus.VOID => AppColors.grey.withOpacity(0.12),
                              },
                            ),
                            StatusContainer(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              label: widget.sale.status!.name,
                              labelColor: switch (widget.sale.status!.name) {
                                'Booked' => AppColors.blue,
                                'In Process' => AppColors.orange,
                                'Cancelled' => AppColors.grey,
                                'Completed' => AppColors.green,
                                _ => AppColors.grey,
                              },
                              backgroundColor: switch (widget.sale.status!.name) {
                                'Booked' => AppColors.blue.withOpacity(0.12),
                                'In Process' => AppColors.orange.withOpacity(0.12),
                                'Cancelled' => AppColors.grey.withOpacity(0.12),
                                'Completed' => AppColors.green.withOpacity(0.12),
                                _ => AppColors.grey.withOpacity(0.12),
                              },
                            ),
                            StatusContainer(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              label: widget.sale.orderSource ?? 'Duxbe',
                              labelColor: AppColors.brandViolet,
                              backgroundColor: AppColors.lightPurple,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: AppColors.lightPurple),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        Text(
                          widget.sale.customer?.name ?? context.l10n.walkInCustomer,
                          style: AppText.xLargeB.copyWith(color: AppColors.title),
                        ),
                        if (widget.sale.customer?.phone != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            widget.sale.customer!.phone!,
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
                      widget.sale.saleDate.toLocal().toTime12WithDayWithMonthFormat,
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
                  if (widget.sale.employee != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.salePersonDetails,
                          style: AppText.smallM.copyWith(color: AppColors.stormyBlue),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // CircleAvatar
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: AppColors.lightPurple,
                              backgroundImage: widget.sale.employee?.image != null
                                  ? NetworkImage(widget.sale.employee!.image!)
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.sale.employee!.name,
                                  style: AppText.xLargeSB.copyWith(color: AppColors.primaryColor),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  widget.sale.employee!.email,
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
                        Text(
                          context.l10n.paymentDetails,
                          style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
                        ),
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
                                '$currency${widget.sale.totalAmount}',
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
                                widget.sale.dueAmount > 0 ? context.l10n.due : context.l10n.paid,
                                style: AppText.mediumN
                                    .copyWith(color: widget.sale.dueAmount > 0 ? AppColors.red : AppColors.green),
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
                                '$currency${widget.sale.dueAmount}',
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
                                widget.sale.payments.map((e) => e.paymentMethod.name.displayCase).toSet().join(', '),
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
                    widget.sale.updatedAt.toLocal().toTime12WithDayWithMonthFormat,
                    style: AppText.smallN.copyWith(color: AppColors.primaryColor),
                  ),
                  if (widget.sale.dueAmount > 0) ...[
                    const SizedBox(height: 12),
                    AppButton(
                      color: AppColors.green,
                      label: Text(context.l10n.updatePayment, style: AppText.mediumSB),
                      onPress: () {
                        showDialog<void>(
                          context: AppRouter.rootContext,
                          builder: (context) {
                            return CustomerSettlementDialog(
                              customerId: widget.sale.customer!.customerId!,
                              invoice: widget.sale,
                            );
                          },
                        );
                      },
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
                  for (final item in widget.sale.saleItems)
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
                          child: Text(
                            item.quantity.toString(),
                            style: AppText.smallSB.copyWith(color: AppColors.black),
                          ),
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
                          '$currency${widget.sale.subTotal}',
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
                          '$currency${widget.sale.discountAmount}',
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
                          '$currency${widget.sale.taxAmount}',
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
                          '$currency${widget.sale.shippingCharge}',
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
                    '$currency${widget.sale.totalAmount}',
                    style: AppText.mediumB.copyWith(color: AppColors.primaryColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ref.watch(saleAuditsProvider(widget.sale.saleId)).when(
                  data: (data) => data.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.auditHistory,
                              style: AppText.smallM.copyWith(color: AppColors.stormyBlue),
                            ),
                            ...data.map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  '${ widget.sale.employee!.name} - ${e.changeDetails ?? '-'} On ${e.actionTimestamp.toLocal().toTime12WithDayWithMonthFormat}',
                                  style: AppText.xSmallN.copyWith(color: AppColors.stormyBlue),
                                ),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                  error: (error, stackTrace) => Text(error.toString()),
                  loading: () => Text(context.l10n.loading),
                ),
            const SizedBox(height: 12),
            AppButton(
              style: ButtonStyles.cancel,
              label: Text(context.l10n.printInvoice, style: AppText.mediumSB.copyWith(color: AppColors.primaryColor)),
              onPress: () {
                PdfService.printSaleInvoice(widget.sale);
              },
            ),
          ],
        ),
      ),
    );
  }
}
