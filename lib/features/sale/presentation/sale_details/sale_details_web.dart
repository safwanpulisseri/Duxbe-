import 'package:collection/collection.dart';
import 'package:duxbe/features/sale/presentation/customer_list/customer_settlement.dart';
import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';

class SaleDetailsScreenWeb extends ConsumerStatefulWidget {
  const SaleDetailsScreenWeb({required this.sale, super.key});
  final SaleView sale;

  @override
  ConsumerState<SaleDetailsScreenWeb> createState() => _SaleDetailsScreenWebState();
}

class _SaleDetailsScreenWebState extends ConsumerState<SaleDetailsScreenWeb> {
  static const Color tableBorder = Color(0xFFE2E3E7);

  Widget _buildSection({
    required String title,
    required List<Widget> children,
    Widget? trailingWidget,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppText.heading4.copyWith(color: AppColors.primaryColor),
            ),
            if (trailingWidget != null) trailingWidget,
          ],
        ),
        const SizedBox(height: 10),
        ...children,
      ],
    );
  }

  final tableDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: tableBorder, width: 2),
  );

  Widget _buildRow(String key, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              key,
              style: AppText.xLargeM.copyWith(color: AppColors.greyText),
            ),
          ),
          const Text(':  '),
          Expanded(
            child: Text(
              value,
              style: AppText.xLargeSB.copyWith(
                color: valueColor ?? AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppStyles.boxDecoration,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: tableDecoration,
              child: _buildSection(
                title: 'SALE ID: ${widget.sale.saleInvoice}',
                trailingWidget: Row(
                  children: [
                    CustomOutlinedIconButton(
                      label: context.l10n.print,
                      icon: Assets.icons.print.svg(),
                      onPressed: () {
                        PdfService.printSaleInvoice(widget.sale);
                      },
                      borderColor: tableBorder,
                      backgroundColor: AppColors.white,
                      textColor: AppColors.black,
                    ),
                    const SizedBox(width: 10),
                    CustomOutlinedIconButton(
                      label: context.l10n.saleReturn,
                      icon: Assets.icons.saleReturn.svg(),
                      onPressed: () {
                        context.pushNamed(AppRouter.createSaleReturn, queryParameters: {'id': widget.sale.saleId});
                      },
                      borderColor: const Color(0xFFDE3BE2),
                      backgroundColor: const Color(0xFFFFEEFC),
                      textColor: const Color(0xFFDE3BE2),
                    ),
                  ],
                ),
                children: [
                  StatusContainer(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
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
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      StatusContainer(
                        label: 'Placed  on: ',
                        value: widget.sale.saleDate.toLocal().toFullFormat,
                        valueColor: const Color(0xFFF5F6F8),
                        backgroundColor: const Color(0xFFF5F6F8),
                        labelTextStyle: AppText.largeSB.copyWith(
                          color: AppColors.greyText,
                        ),
                        valueTextStyle: AppText.largeSB.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(width: 10),
                      StatusContainer(
                        label: 'Updated  on: ',
                        value: widget.sale.updatedAt.toLocal().toFullFormat,
                        valueColor: const Color(0xFFF5F6F8),
                        backgroundColor: const Color(0xFFF5F6F8),
                        labelTextStyle: AppText.largeSB.copyWith(
                          color: AppColors.greyText,
                        ),
                        valueTextStyle: AppText.largeSB.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: tableDecoration,
                      child: _buildSection(
                        title: context.l10n.customerDetails,
                        children: [
                          _buildRow(
                            context.l10n.name,
                            widget.sale.customer?.name ?? AppRouter.l10n.walkInCustomer,
                          ),
                          _buildRow(
                            context.l10n.phoneNumber,
                            widget.sale.customer?.phone ?? '',
                          ),
                          _buildRow(
                            context.l10n.email,
                            widget.sale.customer?.email ?? '',
                          ),
                          if (widget.sale.billingAddress != null)
                            _buildRow('Billing Address', widget.sale.billingAddress?.formattedAddress ?? 'N/A'),
                          if (widget.sale.shippingAddress != null)
                            _buildRow('Shipping Address', widget.sale.shippingAddress?.formattedAddress ?? 'N/A'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (widget.sale.employee != null) ...[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: tableDecoration,
                        child: _buildSection(
                          title: context.l10n.salespersonDetails,
                          children: [
                            _buildRow(
                              context.l10n.name,
                              widget.sale.employee!.name,
                            ),
                            _buildRow(
                              context.l10n.phoneNumber,
                              widget.sale.employee!.phone ?? '',
                            ),
                            _buildRow(
                              context.l10n.email,
                              widget.sale.employee!.email,
                            ),
                            _buildRow(
                              context.l10n.staffId,
                              widget.sale.employee!.code ?? '',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: tableDecoration,
                      child: _buildSection(
                        title: context.l10n.paymentDetails,
                        children: [
                          _buildRow(context.l10n.totalAmount, widget.sale.totalAmount.toString()),
                          _buildRow(context.l10n.dueAmount, widget.sale.dueAmount.toString()),
                          _buildRow(
                            context.l10n.paymentMode,
                            widget.sale.payments
                                .map(
                                  (e) => e.paymentMethod.name.displayCase,
                                )
                                .toSet()
                                .join(', '),
                          ),
                          if (widget.sale.customer != null && widget.sale.dueAmount > 0) ...[
                            const SizedBox(height: 8),
                            CustomOutlinedIconButton(
                              label: context.l10n.settle,
                              icon: Assets.icons.updatePayment
                                  .svg(colorFilter: const ColorFilter.mode(AppColors.blue, BlendMode.srcIn)),
                              onPressed: () {
                                showDialog<void>(
                                  context: AppRouter.rootContext,
                                  builder: (context) {
                                    return CustomerSettlementDialog(
                                      customerId: widget.sale.customer!.customerId!,
                                      invoice: widget.sale,
                                    );
                                  },
                                ).then((value) {
                                  ref
                                    ..invalidate(saleAuditsProvider(widget.sale.saleId))
                                    ..invalidate(saleProvider(widget.sale.saleId));
                                  ref.read(orderListNotifierProvider.notifier).setFilter(pageNumber: 1);
                                  ref.read(saleListNotifierProvider.notifier).setFilter(pageNumber: 1);
                                });
                              },
                              borderColor: AppColors.blue,
                              backgroundColor: AppColors.blue.withOpacity(.2),
                              textColor: AppColors.blue,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: tableDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      '${context.l10n.itemsOrdered} (${widget.sale.saleItems.length})',
                      style: AppText.largeSB.copyWith(color: AppColors.black),
                    ),
                  ),
                  const Divider(
                    color: tableBorder,
                    thickness: 2,
                    height: 0,
                  ),
                  // Table with headers , SL No, Name, Price, Qty, Amount
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(.5),
                      1: FlexColumnWidth(),
                      2: FlexColumnWidth(3),
                      3: FlexColumnWidth(),
                      4: FlexColumnWidth(),
                      5: FlexColumnWidth(),
                    },
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(color: AppColors.offWhite),
                        children: [
                          AppRouter.l10n.slNo,
                          AppRouter.l10n.image,
                          AppRouter.l10n.name,
                          AppRouter.l10n.price,
                          AppRouter.l10n.quantity,
                          AppRouter.l10n.amount,
                        ]
                            .map(
                              (header) => Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  header,
                                  style: AppText.mediumSB,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      ...widget.sale.saleItems.map(
                        (e) => TableRow(
                          decoration:
                              const BoxDecoration(border: Border(bottom: BorderSide(color: tableBorder, width: 2))),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                '${widget.sale.saleItems.indexOf(e) + 1}',
                                style: const TextStyle(color: AppColors.stormyBlue),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: e.item.images.isNotEmpty
                                  ? Align(
                                      alignment: Alignment.centerLeft,
                                      child: Image.network(
                                        e.item.images.firstWhereOrNull((e) => e.isThumbnail)?.url ??
                                            e.item.images.firstOrNull?.url ??
                                            '',
                                        height: 50,
                                        width: 50,
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.item.name,
                                    style: const TextStyle(color: AppColors.stormyBlue),
                                  ),
                                  ...e.subServices.map(
                                    (service) => Padding(
                                      padding: const EdgeInsets.only(left: 8, top: 4),
                                      child: Text(
                                        '\u2022 ${service.name}',
                                        style: const TextStyle(color: AppColors.stormyBlue),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.unitPrice.toString(),
                                    style: const TextStyle(color: AppColors.stormyBlue),
                                  ),
                                  ...e.subServices.map(
                                    (service) => Padding(
                                      padding: const EdgeInsets.only(left: 8, top: 4),
                                      child: Text(
                                        '\u2022 ${service.additionalPrice}',
                                        style: const TextStyle(color: AppColors.stormyBlue),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                e.quantity.toString(),
                                style: const TextStyle(color: AppColors.stormyBlue),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                (e.totalPrice + e.subServices.map((e) => e.totalAdditionalPrice).sum).toString(),
                                style: const TextStyle(color: AppColors.stormyBlue),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      '${context.l10n.subTotal}      ${widget.sale.subTotal}',
                      style: AppText.largeSB.copyWith(color: AppColors.black),
                      textAlign: TextAlign.end,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      '${context.l10n.discount}      ${widget.sale.discountAmount}',
                      style: AppText.mediumSB.copyWith(color: AppColors.stormyBlue),
                      textAlign: TextAlign.end,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      '${context.l10n.taxAmount}      ${widget.sale.taxAmount}',
                      style: AppText.mediumSB.copyWith(color: AppColors.stormyBlue),
                      textAlign: TextAlign.end,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      '${context.l10n.shipping}      ${widget.sale.shippingCharge}',
                      style: AppText.mediumSB.copyWith(color: AppColors.stormyBlue),
                      textAlign: TextAlign.end,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      '${context.l10n.total}      ${widget.sale.totalAmount}',
                      style: AppText.largeSB.copyWith(color: AppColors.black),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ref.watch(saleAuditsProvider(widget.sale.saleId)).when(
                  data: (data) => data.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${context.l10n.auditHistory} (${data.length})',
                              style: AppText.largeSB.copyWith(color: AppColors.stormyBlue),
                            ),
                            ...data.map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  '${ widget.sale.employee!.name} - ${e.changeDetails ?? '-'} On ${e.actionTimestamp.toLocal().toTime12WithDayWithMonthFormat}',
                                ),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                  error: (error, stackTrace) => Text(error.toString()),
                  loading: () => Text(context.l10n.loading),
                ),
          ],
        ),
      ),
    );
  }
}
