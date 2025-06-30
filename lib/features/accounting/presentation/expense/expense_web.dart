import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

class ExpenseScreenWeb extends ConsumerStatefulWidget {
  const ExpenseScreenWeb({super.key});

  @override
  ConsumerState<ExpenseScreenWeb> createState() => _ExpenseScreenWebState();
}

class _ExpenseScreenWebState extends ConsumerState<ExpenseScreenWeb> {
  final debouncer = Debouncer(milliseconds: 500);
  @override
  Widget build(BuildContext context) {
    final expenseListState = ref.watch(expenseNotifierProvider);
    final expenseListNotifier = ref.watch(expenseNotifierProvider.notifier);
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
                            context.l10n.expense,
                            style: AppText.mediumSB.copyWith(color: AppColors.primaryColor),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$currency ${expenseListState.totalAmount}',
                            style: AppText.heading5.copyWith(color: AppColors.red),
                          ),
                        ],
                      ),
                      Assets.icons.expenses.svg(
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
                  initialValue: start,
                  showCloseButton: true,
                  onChanged: (fromDate) {
                    expenseListNotifier.setFilter(fromDate: fromDate);
                  },
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: AppDateTimeForm(
                  name: 'toDate',
                  label: null,
                  initialValue: end,
                  showCloseButton: true,
                  inputType: InputType.date,
                  onChanged: (toDate) {
                    expenseListNotifier.setFilter(toDate: toDate);
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
                  name: 'expense_search',
                  hintText: context.l10n.searchExpense,
                  onChanged: (val) {
                    debouncer.run(() {
                      expenseListNotifier.setFilter(query: val);
                    });
                  },
                ),
              ),
              const SizedBox(width: 20),
              AppButton(
                style: ButtonStyles.secondary,
                onPress: () {
                  context.pushNamed(AppRouter.expenseCategory);
                },
                label: Text(context.l10n.expenseCategory),
              ),
              const SizedBox(width: 20),
              AppButton.icon(
                padding: const EdgeInsets.all(16),
                onPress: () {
                  context.pushNamed(AppRouter.createExpense);
                },
                label: Text(context.l10n.newExpense),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: PlutoGrid(
              mode: PlutoGridMode.readOnly,
              columns: expenseListNotifier.expenseColumns,
              // ignore: prefer_const_literals_to_create_immutables
              rows: [],
              onLoaded: (PlutoGridOnLoadedEvent event) {
                expenseListNotifier.setStateManager(
                  stateManager: event.stateManager,
                );
              },
              configuration: AppStylesX.dataTableConfig,
              noRowsWidget: const NoDataViewWidget(),
            ),
          ),
          PaginationFooter(
            onPageChanged: (value) {
              expenseListNotifier.setFilter(pageNumber: value);
            },
            totalPages: (expenseListState.count / expenseListState.pageSize).ceil(),
            currentPage: expenseListState.pageNumber,
          ),
        ],
      ),
    );
  }
}
