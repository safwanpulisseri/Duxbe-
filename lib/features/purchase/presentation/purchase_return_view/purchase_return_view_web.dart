import 'package:duxbe/features/purchase/purchase.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';

class PurchaseReturnViewScreenWeb extends ConsumerStatefulWidget {
  const PurchaseReturnViewScreenWeb({required this.purchaseReturn, super.key});
  final PurchaseReturn purchaseReturn;

  @override
  ConsumerState<PurchaseReturnViewScreenWeb> createState() => _PurchaseReturnViewScreenWebState();
}

class _PurchaseReturnViewScreenWebState extends ConsumerState<PurchaseReturnViewScreenWeb> {
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
                title: 'RETURN ID: ${widget.purchaseReturn.returnInvoice}',
                trailingWidget: CustomOutlinedIconButton(
                  label: context.l10n.print,
                  icon: Assets.icons.print.svg(),
                  onPressed: () {
                    // PdfService.printPurchaseReturnInvoice(widget.purchaseReturn);
                  },
                  borderColor: tableBorder,
                  backgroundColor: AppColors.white,
                  textColor: AppColors.black,
                ),
                children: [
                  Row(
                    children: [
                      StatusContainer(
                        label: 'Returned on: ',
                        value: widget.purchaseReturn.returnDate.toLocal().toFullFormat,
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
                            widget.purchaseReturn.supplier.name,
                          ),
                          _buildRow(
                            context.l10n.phoneNumber,
                            widget.purchaseReturn.supplier.phone,
                          ),
                          _buildRow(
                            context.l10n.email,
                            widget.purchaseReturn.supplier.email ?? '',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Spacer(flex: 2),
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
                      '${context.l10n.itemReturned} (${widget.purchaseReturn.returnItems.length})',
                      style: AppText.largeSB.copyWith(color: AppColors.black),
                    ),
                  ),
                  const Divider(
                    color: tableBorder,
                    thickness: 2,
                    height: 0,
                  ),
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
                      ...widget.purchaseReturn.returnItems.map(
                        (e) => TableRow(
                          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: tableBorder, width: 2))),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                '${widget.purchaseReturn.returnItems.indexOf(e) + 1}',
                                style: const TextStyle(color: AppColors.stormyBlue),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                e.itemName,
                                style: const TextStyle(color: AppColors.stormyBlue),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                e.returnUnitPrice.toString(),
                                style: const TextStyle(color: AppColors.stormyBlue),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                e.returnQuantity.toString(),
                                style: const TextStyle(color: AppColors.stormyBlue),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                e.returnTotalPrice.toString(),
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
                      '${context.l10n.total}      ${widget.purchaseReturn.returnAmount}',
                      style: AppText.largeSB.copyWith(color: AppColors.black),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
