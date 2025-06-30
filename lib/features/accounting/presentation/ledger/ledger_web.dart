import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

part 'widgets/ledger_detail_dialog.dart';

class LedgerScreenWeb extends ConsumerStatefulWidget {
  const LedgerScreenWeb({super.key});

  @override
  ConsumerState<LedgerScreenWeb> createState() => _LedgerScreenWebState();
}

class _LedgerScreenWebState extends ConsumerState<LedgerScreenWeb> {
  final debouncer = Debouncer(milliseconds: 500);
  @override
  Widget build(BuildContext context) {
    final ledgerState = ref.watch(ledgerNotifierProvider);
    final ledgerNotifier = ref.watch(ledgerNotifierProvider.notifier);

    return ColoredBox(
      color: AppColors.scaffoldBgColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: AppStyles.boxDecoration,
            padding: const EdgeInsets.all(18),
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LedgerInfoCard(
                  color: AppColors.ledgerTotalSales,
                  title: context.l10n.totalSales,
                  subTitle: ledgerState.ledger.totalSales.toString(),
                  icon: Icons.add_business_sharp,
                ),
                VerticalDivider(color: AppColors.outlineGrey.withOpacity(.3)),
                LedgerInfoCard(
                  color: AppColors.ledgerTotalPurchases,
                  title: context.l10n.totalPurchase,
                  subTitle: ledgerState.ledger.totalPurchases.toString(),
                  icon: Icons.add_business_sharp,
                ),
                VerticalDivider(color: AppColors.outlineGrey.withOpacity(.3)),
                LedgerInfoCard(
                  color: AppColors.ledgerReceiveAmount,
                  title: context.l10n.receivedAmount,
                  subTitle: ledgerState.ledger.totalReceivedSales.toString(),
                  icon: Icons.add_business_sharp,
                ),
                VerticalDivider(color: AppColors.outlineGrey.withOpacity(.3)),
                LedgerInfoCard(
                  color: AppColors.ledgerCustomerDue,
                  title: context.l10n.customerDue,
                  subTitle: ledgerState.ledger.totalCustomerDues.toString(),
                  icon: Icons.add_business_sharp,
                ),
                VerticalDivider(color: AppColors.outlineGrey.withOpacity(.3)),
                LedgerInfoCard(
                  color: AppColors.ledgerSupplierDue,
                  title: context.l10n.supplierDue,
                  subTitle: ledgerState.ledger.totalSupplierDues.toString(),
                  icon: Icons.add_business_sharp,
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 24),
            child: Row(
              children: [
                Expanded(
                  child: AppTextForm<String>(
                    name: 'ledger_search',
                    hintText: context.l10n.search,
                    onChanged: (val) {
                      debouncer.run(() {
                        ledgerNotifier.getParties(query: val);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: 200,
                  child: AppDropDownForm(
                    name: 'isDue',
                    initialValue: TransactionParty.all,
                    label: null,
                    items: [
                      DropDownItems(
                        value: TransactionParty.all,
                        child: Text(context.l10n.all),
                      ),
                      DropDownItems(
                        value: TransactionParty.customer,
                        child: Text(context.l10n.customer),
                      ),
                      DropDownItems(
                        value: TransactionParty.supplier,
                        child: Text(AppRouter.l10n.supplier),
                      ),
                    ],
                    onChanged: (val) {
                      debouncer.run(() {
                        ledgerNotifier.getParties(party: val);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PlutoGrid(
              mode: PlutoGridMode.readOnly,
              columns: ledgerNotifier.ledgerColumns,
              // ignore: prefer_const_literals_to_create_immutables
              rows: [],
              onLoaded: (PlutoGridOnLoadedEvent event) {
                ledgerNotifier.setStateManager(
                  stateManager: event.stateManager,
                );
              },
              configuration: AppStylesX.dataTableConfig,
              noRowsWidget: const NoDataViewWidget(),
            ),
          ),
          PaginationFooter(
            onPageChanged: (value) {
              ledgerNotifier.getParties(pageNumber: value);
            },
            totalPages: (ledgerState.count / ledgerState.pageSize).ceil(),
            currentPage: ledgerState.pageNumber,
          ),
        ],
      ),
    );
  }
}

class LedgerInfoCard extends StatelessWidget {
  const LedgerInfoCard({
    required this.color,
    required this.title,
    required this.subTitle,
    required this.icon,
    super.key,
  });
  final Color color;
  final String title;
  final String subTitle;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: color.withOpacity(.15),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppText.largeN),
              const SizedBox(height: 8),
              Text(subTitle, style: AppText.xLargeSB),
            ],
          ),
        ],
      ),
    );
  }
}
