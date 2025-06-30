import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';

class ProfitAndLossScreenMobile extends ConsumerStatefulWidget {
  const ProfitAndLossScreenMobile({super.key});

  @override
  ConsumerState<ProfitAndLossScreenMobile> createState() => _ProfitAndLossScreenMobileState();
}

class _ProfitAndLossScreenMobileState extends ConsumerState<ProfitAndLossScreenMobile> {
  final DateTime today = DateTime.now();
  final DateTime tomorrow = DateTime.now().add(const Duration(days: 1));

  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    final fiscalYear = ref.watch(currentFiscalPeriodProvider).valueOrNull;

    final start = startDate ?? fiscalYear?.$1 ?? today;
    final end = endDate ?? fiscalYear?.$2 ?? tomorrow;
    // Use watch here so it rebuilds when dates change
    final profiAndLossProvider = ref.watch(
      profitAndLossProvider(
        start,
        end,
      ),
    );
    final currency = ref.watch(currencyProvider);
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(context.l10n.profitAndLoss),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await showModalBottomSheet<(DateTime, DateTime)?>(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => DateRangeBottomSheet(
                  initialStartDate: start,
                  initialEndDate: end,
                ),
              );

              if (result != null) {
                setState(() {
                  startDate = result.$1;
                  endDate = result.$2;
                });
              }
            },
            icon: const Icon(Icons.edit_calendar_outlined, color: AppColors.darkBlue),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            color: AppColors.lightPurple,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${start.toDateOnlyWithYear}${context.l10n.dateRangeToSeparator}${end.toDateOnlyWithYear}',
                  style: AppText.smallSB.copyWith(color: AppColors.black),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          profiAndLossProvider.when(
            data: (data) => Expanded(
              child: SingleChildScrollView(
                child: Container(
                  decoration: AppStyles.boxDecoration,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              context.l10n.profitAndLoss,
                              style: AppText.largeSB.copyWith(color: AppColors.darkBlue),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '(${context.l10n.from} ${start.toDateOnlyWithYear} ${context.l10n.to} ${end.toDateOnlyWithYear})',
                              style: AppText.smallN.copyWith(color: AppColors.darkBlue),
                            ),
                            const SizedBox(height: 20),

                            // Detailed Revenue Section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(context.l10n.revenueProducts, style: AppText.mediumN.copyWith(color: AppColors.black)),
                                Text(
                                  '$currency ${data.revenueProducts.toStringAsFixed(2)}',
                                  style: AppText.mediumN.copyWith(color: AppColors.black),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(context.l10n.revenueServices, style: AppText.mediumN.copyWith(color: AppColors.black)),
                                Text(
                                  '$currency ${data.revenueServices.toStringAsFixed(2)}',
                                  style: AppText.mediumN.copyWith(color: AppColors.black),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(context.l10n.revenueShipping, style: AppText.mediumN.copyWith(color: AppColors.black)),
                                Text(
                                  '$currency ${data.revenueShipping.toStringAsFixed(2)}',
                                  style: AppText.mediumN.copyWith(color: AppColors.black),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(context.l10n.discountsOnSales, style: AppText.mediumN.copyWith(color: AppColors.black)),
                                Text(
                                  '$currency ${data.salesDiscountsTotal.toStringAsFixed(2)}',
                                  style: AppText.mediumN.copyWith(color: AppColors.black),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const DottedLine(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  context.l10n.totalSalesRevenue,
                                  style: AppText.mediumN.copyWith(color: AppColors.black, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '$currency ${data.netSalesRevenue.toStringAsFixed(2)}',
                                  style: AppText.n20.copyWith(color: AppColors.black, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Detailed COGS Section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(context.l10n.cogsProducts, style: AppText.mediumN.copyWith(color: AppColors.black)),
                                Text(
                                  '$currency ${data.cogsProductsTotal.toStringAsFixed(2)}',
                                  style: AppText.mediumN.copyWith(color: AppColors.black),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(context.l10n.freightIn, style: AppText.mediumN.copyWith(color: AppColors.black)),
                                Text(
                                  '$currency ${data.freightInTotal.toStringAsFixed(2)}',
                                  style: AppText.mediumN.copyWith(color: AppColors.black),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  context.l10n.discountsOnPurchases,
                                  style: AppText.mediumN.copyWith(color: AppColors.black),
                                ),
                                Text(
                                  '$currency ${data.purchaseDiscountsTotal.toStringAsFixed(2)}',
                                  style: AppText.mediumN.copyWith(color: AppColors.black),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const DottedLine(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  context.l10n.totalPurchases,
                                  style: AppText.mediumN.copyWith(color: AppColors.black, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '$currency ${data.netCogs.toStringAsFixed(2)}',
                                  style: AppText.n20.copyWith(color: AppColors.black, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        color: AppColors.lightPurple,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(context.l10n.grossProfit, style: AppText.largeSB.copyWith(color: AppColors.black)),
                            Text(
                              '$currency ${data.grossProfit}',
                              style: AppText.largeSB.copyWith(color: AppColors.black),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Detailed Other Income Section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(context.l10n.incomeGeneral, style: AppText.mediumN.copyWith(color: AppColors.black)),
                                Text(
                                  '$currency ${data.incomeGeneral.toStringAsFixed(2)}',
                                  style: AppText.mediumN.copyWith(color: AppColors.black),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(context.l10n.incomeStockOverage, style: AppText.mediumN.copyWith(color: AppColors.black)),
                                Text(
                                  '$currency ${data.incomeStockOverage.toStringAsFixed(2)}',
                                  style: AppText.mediumN.copyWith(color: AppColors.black),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const DottedLine(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  context.l10n.totalIncomeOther,
                                  style: AppText.mediumN.copyWith(color: AppColors.black, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '$currency ${data.totalOtherIncome.toStringAsFixed(2)}',
                                  style: AppText.n20.copyWith(color: AppColors.black, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Total Expenses (remains as is)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  context.l10n.totalExpenses,
                                  style: AppText.mediumN.copyWith(color: AppColors.black),
                                ),
                                Text(
                                  '$currency ${data.totalOperatingExpenses.toStringAsFixed(2)}',
                                  style: AppText.n20.copyWith(color: AppColors.black),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        color: AppColors.lightPurple,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(context.l10n.netProfitLoss, style: AppText.largeSB.copyWith(color: AppColors.black)),
                            Text(
                              '$currency ${data.netIncomeLoss}',
                              style: AppText.largeSB.copyWith(color: AppColors.black),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            loading: () => const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stackTrace) => Expanded(
              child: Center(
                child: Text('${context.l10n.errorPrefix}$error'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
