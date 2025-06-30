import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

class IncomeCategoryScreenWeb extends ConsumerStatefulWidget {
  const IncomeCategoryScreenWeb({super.key});

  @override
  ConsumerState<IncomeCategoryScreenWeb> createState() => _IncomeCategoryScreenWebState();
}

class _IncomeCategoryScreenWebState extends ConsumerState<IncomeCategoryScreenWeb> {
  final debouncer = Debouncer(milliseconds: 500);
  @override
  Widget build(BuildContext context) {
    final incomeCategoryNotifier = ref.watch(incomeCategoryNotifierProvider.notifier);
    final incomeCategoryState = ref.watch(incomeCategoryNotifierProvider);

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
                      name: 'income_category_search',
                      hintText: 'Search with category name',
                      onChanged: (val) {
                        debouncer.run(() {
                          incomeCategoryNotifier.setFilter(query: val ?? '');
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
                          type: TransactionCategoryType.income,
                        ),
                      );
                    },
                    label: Text(context.l10n.addIncomeCategory),
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
                        columns: incomeCategoryNotifier.categoryColumns,
                        // ignore: prefer_const_literals_to_create_immutables
                        rows: [],
                        onLoaded: (PlutoGridOnLoadedEvent event) {
                          incomeCategoryNotifier.setStateManager(
                            stateManager: event.stateManager,
                          );
                        },
                        configuration: AppStylesX.dataTableConfig,
                        noRowsWidget: const NoDataViewWidget(),
                      ),
                    ),
                    PaginationFooter(
                      onPageChanged: (value) {
                        incomeCategoryNotifier.setFilter(pageNumber: value);
                      },
                      totalPages: (incomeCategoryState.count / incomeCategoryState.pageSize).ceil(),
                      currentPage: incomeCategoryState.pageNumber,
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
