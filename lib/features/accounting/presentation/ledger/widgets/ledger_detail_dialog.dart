part of '../ledger_web.dart';

class LedgerDetailsDialog extends ConsumerStatefulWidget {
  const LedgerDetailsDialog({required this.transaction, super.key});
  final Party transaction;

  @override
  ConsumerState<LedgerDetailsDialog> createState() => _LedgerDetailsDialogState();
}

class _LedgerDetailsDialogState extends ConsumerState<LedgerDetailsDialog> {
  @override
  Widget build(BuildContext context) {
    final ledgerDetail = partyDetailsNotifierProvider(
      widget.transaction.type,
      widget.transaction.id,
    );
    final transDetails = ref.watch(ledgerDetail);
    final transDetailsNotifier = ref.watch(ledgerDetail.notifier);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.ledgerDetails,
              style: AppText.heading5.copyWith(color: AppColors.primaryColor),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 14),
                  if (widget.transaction.type == TransactionParty.customer) ...[
                    Row(
                      children: [
                        LedgerInfoCard(
                          color: AppColors.ledgerTotalSales,
                          title: context.l10n.totalSales,
                          subTitle: transDetails.partyDetails.total.toString(),
                          icon: Icons.add_business_sharp,
                        ),
                        LedgerInfoCard(
                          color: AppColors.ledgerReceiveAmount,
                          title: context.l10n.receivedAmount,
                          subTitle: transDetails.partyDetails.totalPaid.toString(),
                          icon: Icons.add_business_sharp,
                        ),
                        LedgerInfoCard(
                          color: AppColors.ledgerCustomerDue,
                          title: context.l10n.totalDue,
                          subTitle: transDetails.partyDetails.totalDue.toString(),
                          icon: Icons.add_business_sharp,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '${context.l10n.customerName}: ${transDetails.customer?.name ?? context.l10n.walkInCustomer}',
                      style: AppText.largeN.copyWith(color: AppColors.black),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${context.l10n.customerPhone}: ${transDetails.customer?.phone ?? ''}',
                      style: AppText.largeN.copyWith(color: AppColors.black),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        LedgerInfoCard(
                          color: AppColors.ledgerTotalSales,
                          title: context.l10n.totalPurchases,
                          subTitle: transDetails.partyDetails.total.toString(),
                          icon: Icons.add_business_sharp,
                        ),
                        LedgerInfoCard(
                          color: AppColors.ledgerReceiveAmount,
                          title: context.l10n.paidAmount,
                          subTitle: transDetails.partyDetails.totalPaid.toString(),
                          icon: Icons.add_business_sharp,
                        ),
                        LedgerInfoCard(
                          color: AppColors.ledgerCustomerDue,
                          title: context.l10n.totalDue,
                          subTitle: transDetails.partyDetails.totalDue.toString(),
                          icon: Icons.add_business_sharp,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '${context.l10n.supplierName}: ${transDetails.supplier?.name ?? ''}',
                      style: AppText.largeN.copyWith(color: AppColors.black),
                    ),
                    const SizedBox(height: 6),
                   
                    Text(
                      '${context.l10n.supplierPhone}: ${transDetails.supplier?.phone ?? ''}',
                      style: AppText.largeN.copyWith(color: AppColors.black),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * .4,
                    child: PlutoGrid(
                      mode: PlutoGridMode.readOnly,
                      columns: transDetailsNotifier.partyDetailsColumns,
                      // ignore: prefer_const_literals_to_create_immutables
                      rows: [],
                      onLoaded: (PlutoGridOnLoadedEvent event) {
                        transDetailsNotifier.setStateManager(
                          stateManager: event.stateManager,
                        );
                      },
                      configuration: AppStylesX.dataTableConfig,
                      noRowsWidget: const NoDataViewWidget(),
                    ),
                  ),
                  PaginationFooter(
                    onPageChanged: (value) {
                      if (widget.transaction.type == TransactionParty.customer) {
                        transDetailsNotifier.getSales(pageNumber: value);
                      } else {
                        transDetailsNotifier.getPurchases(pageNumber: value);
                      }
                    },
                    totalPages: (transDetails.count / transDetails.pageSize).ceil(),
                    currentPage: transDetails.pageNumber,
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
