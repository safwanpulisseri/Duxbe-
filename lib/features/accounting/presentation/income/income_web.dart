import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

class IncomeScreenWeb extends ConsumerStatefulWidget {
  const IncomeScreenWeb({super.key});

  @override
  ConsumerState<IncomeScreenWeb> createState() => _IncomeScreenWebState();
}

class _IncomeScreenWebState extends ConsumerState<IncomeScreenWeb> {
  final debouncer = Debouncer(milliseconds: 500);
  @override
  Widget build(BuildContext context) {
    final incomeListState = ref.watch(incomeNotifierProvider);
    final incomeListNotifier = ref.watch(incomeNotifierProvider.notifier);
    final currency = ref.watch(currencyProvider);
    final fiscalYear = ref.watch(currentFiscalPeriodProvider).valueOrNull;

    final start = fiscalYear?.$1 ?? DateTime.now().subtract(const Duration(days: 365));
    final end = fiscalYear?.$2 ?? DateTime.now();
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: AppStyles.boxDecoration,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsetsDirectional.all(12),
                  decoration: AppStyles.boxDecoration,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.income,
                            style: AppText.mediumSB.copyWith(color: AppColors.primaryColor),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$currency ${incomeListState.totalAmount}',
                            style: AppText.heading5.copyWith(color: AppColors.red),
                          ),
                        ],
                      ),
                      Assets.icons.incomes.svg(
                        colorFilter: const ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn),
                        height: 40,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: AppDateTimeForm(
                  name: 'fromDate',
                  label: null,
                  inputType: InputType.date,
                  showCloseButton: true,
                  initialValue: start,
                  onChanged: (fromDate) {
                    incomeListNotifier.setFilter(fromDate: fromDate);
                  },
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: AppDateTimeForm(
                  name: 'toDate',
                  label: null,
                  showCloseButton: true,
                  inputType: InputType.date,
                  initialValue: end,
                  onChanged: (toDate) {
                    incomeListNotifier.setFilter(toDate: toDate);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: AppTextForm<String>(
                  name: 'income_search',
                  hintText: context.l10n.searchIncome,
                  onChanged: (val) {
                    debouncer.run(() {
                      incomeListNotifier.setFilter(query: val);
                    });
                  },
                ),
              ),
              const SizedBox(width: 20),
              AppButton(
                style: ButtonStyles.secondary,
                onPress: () {
                  context.pushNamed(AppRouter.incomeCategory);
                },
                label: Text(context.l10n.incomeCategory),
              ),
              const SizedBox(width: 20),
              AppButton.icon(
                padding: const EdgeInsets.all(16),
                onPress: () {
                  context.pushNamed(AppRouter.createIncome);
                },
                label: Text(context.l10n.newIncome),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: PlutoGrid(
              mode: PlutoGridMode.readOnly,
              columns: incomeListNotifier.incomeColumns,
              // ignore: prefer_const_literals_to_create_immutables
              rows: [],
              onLoaded: (PlutoGridOnLoadedEvent event) {
                incomeListNotifier.setStateManager(
                  stateManager: event.stateManager,
                );
              },
              configuration: AppStylesX.dataTableConfig,
              noRowsWidget: const NoDataViewWidget(),
            ),
          ),
          PaginationFooter(
            onPageChanged: (value) {
              incomeListNotifier.setFilter(pageNumber: value);
            },
            totalPages: (incomeListState.count / incomeListState.pageSize).ceil(),
            currentPage: incomeListState.pageNumber,
          ),
        ],
      ),
    );
  }
}
