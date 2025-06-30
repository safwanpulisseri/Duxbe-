import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

class ExpenseCategoryScreenWeb extends ConsumerStatefulWidget {
  const ExpenseCategoryScreenWeb({super.key});

  @override
  ConsumerState<ExpenseCategoryScreenWeb> createState() => _ExpenseCategoryScreenWebState();
}

class _ExpenseCategoryScreenWebState extends ConsumerState<ExpenseCategoryScreenWeb> {
  final debouncer = Debouncer(milliseconds: 500);
  @override
  Widget build(BuildContext context) {
    final expenseCategoryNotifier = ref.watch(expenseCategoryNotifierProvider.notifier);
    final expenseCategoryState = ref.watch(expenseCategoryNotifierProvider);

    return switch (ref.watch(authNotifierProvider).status) {
      AuthStatus.success => Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: AppStyles.boxDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: AppTextForm<String>(
                      name: 'expense_category_search',
                      hintText: 'Search Expense Category',
                      onChanged: (val) {
                        debouncer.run(() {
                          expenseCategoryNotifier.setFilter(query: val ?? '');
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  AppButton.icon(
                    padding: const EdgeInsets.all(16),
                    onPress: () {
                      showDialog<void>(
                        context: AppRouter.rootContext,
                        builder: (context) => const AddTransactionCategoryDialog(
                          type: TransactionCategoryType.expense,
                        ),
                      );
                    },
                    label: Text(context.l10n.addExpenseCategory),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: PlutoGrid(
                        mode: PlutoGridMode.readOnly,
                        columns: expenseCategoryNotifier.categoryColumns,
                        // ignore: prefer_const_literals_to_create_immutables
                        rows: [],
                        onLoaded: (PlutoGridOnLoadedEvent event) {
                          expenseCategoryNotifier.setStateManager(
                            stateManager: event.stateManager,
                          );
                        },
                        configuration: AppStylesX.dataTableConfig,
                        noRowsWidget: const NoDataViewWidget(),
                      ),
                    ),
                    PaginationFooter(
                      onPageChanged: (value) {
                        expenseCategoryNotifier.setFilter(pageNumber: value);
                      },
                      totalPages: (expenseCategoryState.count / expenseCategoryState.pageSize).ceil(),
                      currentPage: expenseCategoryState.pageNumber,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      _ => const SizedBox(),
    };
  }
}
