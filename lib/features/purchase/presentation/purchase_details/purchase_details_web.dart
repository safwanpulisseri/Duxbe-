import 'package:collection/collection.dart';
import 'package:duxbe/features/purchase/presentation/supplier_list/supplier_settlement.dart';
import 'package:duxbe/features/purchase/purchase.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';

class PurchaseDetailsScreenWeb extends ConsumerStatefulWidget {
  const PurchaseDetailsScreenWeb({required this.purchase, super.key});
  final PurchaseView purchase;

  @override
  ConsumerState<PurchaseDetailsScreenWeb> createState() => _PurchaseDetailsScreenWebState();
}

class _PurchaseDetailsScreenWebState extends ConsumerState<PurchaseDetailsScreenWeb> {
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
                title: 'PURCHASE ID: ${widget.purchase.invoiceNo}',
                trailingWidget: Row(
                  children: [
                    if (widget.purchase.attachmentURL != null)
                      CustomOutlinedIconButton(
                        label: 'Attachment',
                        icon: const Icon(CupertinoIcons.paperclip, size: 20),
                        onPressed: () {
                          final fileName = widget.purchase.attachmentURL!.split('/').last;
                          FileDownloader.downloadFile(
                            url: widget.purchase.attachmentURL!,
                            filename: fileName,
                            onError: print,
                            onProgress: print,
                          );
                        },
                        borderColor: tableBorder,
                        backgroundColor: AppColors.white,
                        textColor: AppColors.black,
                      ),
                    const SizedBox(width: 10),
                    CustomOutlinedIconButton(
                      label: context.l10n.print,
                      icon: Assets.icons.print.svg(),
                      onPressed: () {
                        PdfService.printPurchaseInvoice(widget.purchase);
                      },
                      borderColor: tableBorder,
                      backgroundColor: AppColors.white,
                      textColor: AppColors.black,
                    ),
                    const SizedBox(width: 10),
                    CustomOutlinedIconButton(
                      label: context.l10n.purchaseReturn,
                      icon: Assets.icons.saleReturn.svg(),
                      onPressed: () {
                        context.pushNamed(
                          AppRouter.createPurchaseReturn,
                          queryParameters: {'id': widget.purchase.purchaseId},
                        );
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
                    label: widget.purchase.transaction.status.name.displayCase,
                    labelColor: switch (widget.purchase.transaction.status) {
                      TransactionStatus.CANCELLED => AppColors.red,
                      TransactionStatus.PENDING => AppColors.orange,
                      TransactionStatus.PAID => AppColors.green,
                      TransactionStatus.PARTIALLY_PAID => AppColors.warning,
                      TransactionStatus.VOID => AppColors.grey,
                    },
                    backgroundColor: switch (widget.purchase.transaction.status) {
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
                        value: widget.purchase.purchaseDate.toLocal().toFullFormat,
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
                        value: widget.purchase.updatedAt.toLocal().toFullFormat,
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
                        title: context.l10n.supplier,
                        children: [
                          _buildRow(
                            context.l10n.name,
                            widget.purchase.supplier.name,
                          ),
                          _buildRow(
                            context.l10n.phoneNumber,
                            widget.purchase.supplier.phone,
                          ),
                          _buildRow(
                            context.l10n.email,
                            widget.purchase.supplier.email ?? '',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: tableDecoration,
                      child: _buildSection(
                        title: context.l10n.salespersonDetails,
                        children: [
                          _buildRow(
                            context.l10n.name,
                            widget.purchase.employee.name,
                          ),
                          _buildRow(
                            context.l10n.phoneNumber,
                            widget.purchase.employee.phone ?? '',
                          ),
                          _buildRow(
                            context.l10n.email,
                            widget.purchase.employee.email,
                          ),
                          _buildRow(
                            context.l10n.staffId,
                            widget.purchase.employee.code ?? '',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: tableDecoration,
                      child: _buildSection(
                        title: context.l10n.paymentDetails,
                        children: [
                          _buildRow(context.l10n.totalAmount, widget.purchase.totalAmount.toString()),
                          _buildRow(context.l10n.dueAmount, widget.purchase.dueAmount.toString()),
                          _buildRow(
                            context.l10n.paymentMode,
                            widget.purchase.payments
                                .map(
                                  (e) => e.paymentMethod.name.displayCase,
                                )
                                .toSet()
                                .join(', '),
                          ),
                          if (widget.purchase.dueAmount > 0) ...[
                            const SizedBox(height: 8),
                            CustomOutlinedIconButton(
                              label: context.l10n.settle,
                              icon: Assets.icons.updatePayment
                                  .svg(colorFilter: const ColorFilter.mode(AppColors.blue, BlendMode.srcIn)),
                              onPressed: () {
                                showDialog<void>(
                                  context: AppRouter.rootContext,
                                  builder: (context) {
                                    return SupplierSettlementDialog(
                                      supplierId: widget.purchase.supplierId,
                                      invoice: widget.purchase,
                                    );
                                  },
                                ).then((value) {
                                  ref
                                    ..invalidate(purchaseAuditsProvider(widget.purchase.purchaseId))
                                    ..invalidate(purchaseProvider(widget.purchase.purchaseId));
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
                      '${context.l10n.itemsOrdered} (${widget.purchase.purchaseItems.length})',
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
                          context.l10n.slNo,
                          context.l10n.image,
                          context.l10n.name,
                          context.l10n.price,
                          context.l10n.qty,
                          context.l10n.amount,
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
                      ...widget.purchase.purchaseItems.map(
                        (e) => TableRow(
                          decoration:
                              const BoxDecoration(border: Border(bottom: BorderSide(color: tableBorder, width: 2))),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                '${widget.purchase.purchaseItems.indexOf(e) + 1}',
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
                              child: Text(
                                e.item.name,
                                style: const TextStyle(color: AppColors.stormyBlue),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                e.unitPrice.toString(),
                                style: const TextStyle(color: AppColors.stormyBlue),
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
                                e.totalPrice.toString(),
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
                      '${context.l10n.subTotal}      ${widget.purchase.subTotal}',
                      style: AppText.largeSB.copyWith(color: AppColors.black),
                      textAlign: TextAlign.end,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      '${context.l10n.discount}      ${widget.purchase.discountAmount}',
                      style: AppText.mediumSB.copyWith(color: AppColors.stormyBlue),
                      textAlign: TextAlign.end,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      '${context.l10n.taxAmount}      ${widget.purchase.taxAmount}',
                      style: AppText.mediumSB.copyWith(color: AppColors.stormyBlue),
                      textAlign: TextAlign.end,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      '${context.l10n.shipping}      ${widget.purchase.shippingCharge}',
                      style: AppText.mediumSB.copyWith(color: AppColors.stormyBlue),
                      textAlign: TextAlign.end,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      '${context.l10n.total}      ${widget.purchase.totalAmount}',
                      style: AppText.largeSB.copyWith(color: AppColors.black),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ref.watch(purchaseAuditsProvider(widget.purchase.purchaseId)).when(
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
                                  '${ widget.purchase.employee!.name} - ${e.changeDetails ?? '-'} On ${e.actionTimestamp.toLocal().toTime12WithDayWithMonthFormat}',
                                ),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                  error: (error, stackTrace) => Text(error.toString()),
                  loading: () => const Text('Loading...'),
                ),
          ],
        ),
      ),
    );
  }
}

class StatusContainer extends StatelessWidget {
  const StatusContainer({
    required this.label,
    super.key,
    this.value,
    this.backgroundColor,
    this.labelColor,
    this.valueColor,
    this.padding,
    this.borderRadius,
    this.valueTextStyle,
    this.labelTextStyle,
  });

  final String label;
  final String? value;
  final Color? backgroundColor;
  final Color? labelColor;
  final Color? valueColor;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final TextStyle? valueTextStyle;
  final TextStyle? labelTextStyle;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? 7),
        color: backgroundColor ?? const Color.fromARGB(255, 44, 197, 111).withOpacity(0.12),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: label,
              style: labelTextStyle ??
                  AppText.largeSB.copyWith(
                    color: labelColor ?? AppColors.greyText,
                  ),
            ),
            if (value != null)
              TextSpan(
                text: value,
                style: valueTextStyle ??
                    AppText.largeSB.copyWith(
                      color: valueColor ?? AppColors.green,
                    ),
              ),
          ],
        ),
      ),
    );
  }
}
