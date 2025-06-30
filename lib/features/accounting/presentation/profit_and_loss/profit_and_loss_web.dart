import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';

class ProfitAndLossScreenWeb extends ConsumerStatefulWidget {
  const ProfitAndLossScreenWeb({super.key});

  @override
  ConsumerState<ProfitAndLossScreenWeb> createState() => _ProfitAndLossScreenWebState();
}

class _ProfitAndLossScreenWebState extends ConsumerState<ProfitAndLossScreenWeb> {
  final _formKey = GlobalKey<FormBuilderState>();
  final DateTime today = DateTime.now();
  final DateTime tomorrow = DateTime.now().add(const Duration(days: 1));

  @override
  Widget build(BuildContext context) {
    final fiscalYear = ref.watch(currentFiscalPeriodProvider).valueOrNull;
    final startDate = _formKey.currentState?.fields['date_range']?.value?.$1 as DateTime? ?? today;
    final endDate = _formKey.currentState?.fields['date_range']?.value?.$2 as DateTime? ?? tomorrow;
    final profiAndLossProvider = profitAndLossProvider(
      startDate,
      endDate,
    );
    final currency = ref.watch(currencyProvider);
    final initialEndDate = DateTime.now();
    final initialStartDate = initialEndDate.subtract(const Duration(days: 30));
    return FormBuilder(
      key: _formKey,
      initialValue: {
        'time_period': 30,
        'date_range': (initialStartDate, initialEndDate),
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: AppStyles.boxDecoration,
            padding: const EdgeInsets.all(18),
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 240,
                  child: AppDropDownForm(
                    onChanged: (p0) {
                      if (p0 == null) return;
                      // Get the form field for date range
                      final dateRangeField = _formKey.currentState?.fields['date_range'];
                      if (dateRangeField != null) {
                        // Calculate new date range based on selected period
                        final days = p0;
                        final endDate = DateTime.now();
                        final startDate = endDate.subtract(Duration(days: days));

                        // Update the date range field with new values
                        dateRangeField.didChange((startDate, endDate));
                      }
                      ref.invalidate(profiAndLossProvider);
                    },
                    name: 'time_period',
                    label: context.l10n.chooseTimePeriod,
                    items: [
                      DropDownItems(
                        value: 30,
                        child: Text(context.l10n.lastMonth),
                      ),
                      DropDownItems(
                        value: 90,
                        child: Text(context.l10n.last3Months),
                      ),
                      DropDownItems(
                        value: 180,
                        child: Text(context.l10n.last6Months),
                      ),
                      DropDownItems(
                        value: 365,
                        child: Text(context.l10n.lastYear),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: IntrinsicHeight(
                    child: Align(
                      alignment: const Alignment(0, 0.3),
                      child: Text(context.l10n.or),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.selectDateRange),
                    const SizedBox(height: 12),
                    FormBuilderField<(DateTime, DateTime)>(
                      builder: (field) {
                        return IntrinsicWidth(
                          child: InkWell(
                            onTap: () async {
                              final start = await showDatePicker(
                                context: context,
                                initialDate: field.value?.$1 ?? fiscalYear?.$1,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2040),
                              );
                              if (start == null) return;
                              if (!context.mounted) return;

                              // Then pick closing time
                              final end = await showDatePicker(
                                context: context,
                                initialDate: field.value?.$2 ?? fiscalYear?.$2,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2040),
                              );
                              if (end != null) {
                                // Validate that end time is after start time
                                // by converting both times to minutes since midnight

                                if (start.isAfter(end)) {
                                  // Show error if start time is after or equal to end time
                                  Alert.showSnackBar(
                                    context.l10n.startDateMustBeBeforeEndDate,
                                    type: SnackBarType.error,
                                  );
                                  return;
                                }

                                // Update form fields with the selected times
                                field.didChange((start, end));
                                  
                              }
                              ref.invalidate(profiAndLossProvider);
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_month),
                                      const SizedBox(width: 12),
                                      Text(field.value?.$1.toDateOnlyWithYear ?? context.l10n.nA),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  Text(context.l10n.to),
                                  const SizedBox(width: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_month),
                                      const SizedBox(width: 12),
                                      Text(field.value?.$2.toDateOnlyWithYear ?? context.l10n.nA),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      name: 'date_range',
                    ),
                  ],
                ),
                // const SizedBox(width: 12),
                // IntrinsicHeight(
                //   child: Align(
                //     alignment: const Alignment(0, 0.6),
                //     child: AppButton(
                //       onPress: () {
                //         ref.invalidate(profiAndLossProvider);
                //       },
                //       label: Text(context.l10n.go),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ref.watch(profiAndLossProvider).when(
                data: (data) => Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      decoration: AppStyles.boxDecoration,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  context.l10n.profitAndLoss,
                                  style: AppText.heading5.copyWith(color: AppColors.black),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  '(${context.l10n.from} ${startDate.toDateOnlyWithYear} ${context.l10n.to} ${endDate.toDateOnlyWithYear})',
                                  style: AppText.n20.copyWith(color: AppColors.black),
                                ),
                                const SizedBox(height: 40),

                                // Detailed Revenue Section - Web
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(context.l10n.revenueProducts, style: AppText.xLargeN.copyWith(color: AppColors.black)),
                                    Text(
                                      '$currency ${data.revenueProducts.toStringAsFixed(2)}',
                                      style: AppText.n20.copyWith(color: AppColors.black),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(context.l10n.revenueServices, style: AppText.xLargeN.copyWith(color: AppColors.black)),
                                    Text(
                                      '$currency ${data.revenueServices.toStringAsFixed(2)}',
                                      style: AppText.n20.copyWith(color: AppColors.black),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(context.l10n.revenueShipping, style: AppText.xLargeN.copyWith(color: AppColors.black)),
                                    Text(
                                      '$currency ${data.revenueShipping.toStringAsFixed(2)}',
                                      style: AppText.n20.copyWith(color: AppColors.black),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      context.l10n.discountsOnSales,
                                      style: AppText.xLargeN.copyWith(color: AppColors.black),
                                    ),
                                    Text(
                                      '$currency ${data.salesDiscountsTotal.toStringAsFixed(2)}',
                                      style: AppText.n20.copyWith(color: AppColors.black),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const DottedLine(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      context.l10n.totalSales,
                                      style:
                                          AppText.xLargeN.copyWith(color: AppColors.black, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '$currency ${data.netSalesRevenue.toStringAsFixed(2)}',
                                      style: AppText.n20.copyWith(color: AppColors.black, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Detailed COGS Section - Web
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(context.l10n.cogsProducts, style: AppText.xLargeN.copyWith(color: AppColors.black)),
                                    Text(
                                      '$currency ${data.cogsProductsTotal.toStringAsFixed(2)}',
                                      style: AppText.n20.copyWith(color: AppColors.black),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(context.l10n.freightIn, style: AppText.xLargeN.copyWith(color: AppColors.black)),
                                    Text(
                                      '$currency ${data.freightInTotal.toStringAsFixed(2)}',
                                      style: AppText.n20.copyWith(color: AppColors.black),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      context.l10n.discountsOnPurchases,
                                      style: AppText.xLargeN.copyWith(color: AppColors.black),
                                    ),
                                    Text(
                                      '$currency ${data.purchaseDiscountsTotal.toStringAsFixed(2)}',
                                      style: AppText.n20.copyWith(color: AppColors.black),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const DottedLine(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      context.l10n.totalPurchases,
                                      style:
                                          AppText.xLargeN.copyWith(color: AppColors.black, fontWeight: FontWeight.bold),
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
                            margin: const EdgeInsets.symmetric(vertical: 18),
                            padding: const EdgeInsets.all(18),
                            color: AppColors.lightPurple,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(context.l10n.grossProfit, style: AppText.xLargeB.copyWith(color: AppColors.black)),
                                Text(
                                  '$currency ${data.grossProfit.toStringAsFixed(2)}',
                                  style: AppText.xLargeB.copyWith(color: AppColors.black),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Detailed Other Income Section - Web
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(context.l10n.incomeGeneral, style: AppText.xLargeN.copyWith(color: AppColors.black)),
                                    Text(
                                      '$currency ${data.incomeGeneral.toStringAsFixed(2)}',
                                      style: AppText.n20.copyWith(color: AppColors.black),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      context.l10n.incomeStockOverage,
                                      style: AppText.xLargeN.copyWith(color: AppColors.black),
                                    ),
                                    Text(
                                      '$currency ${data.incomeStockOverage.toStringAsFixed(2)}',
                                      style: AppText.n20.copyWith(color: AppColors.black),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const DottedLine(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      context.l10n.totalIncomeOther,
                                      style:
                                          AppText.xLargeN.copyWith(color: AppColors.black, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '$currency ${data.totalOtherIncome.toStringAsFixed(2)}',
                                      style: AppText.n20.copyWith(color: AppColors.black, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Total Expenses (remains as is) - Web
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      context.l10n.totalExpenses,
                                      style: AppText.xLargeN.copyWith(color: AppColors.black),
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
                            margin: const EdgeInsets.symmetric(vertical: 18),
                            padding: const EdgeInsets.all(18),
                            color: AppColors.lightPurple,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  context.l10n.netProfitLoss,
                                  style: AppText.xLargeB.copyWith(color: AppColors.black),
                                ),
                                Text(
                                  '$currency ${data.netIncomeLoss}',
                                  style: AppText.xLargeB.copyWith(color: AppColors.black),
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
