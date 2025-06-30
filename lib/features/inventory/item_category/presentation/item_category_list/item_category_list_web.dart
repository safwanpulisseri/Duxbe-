import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

class ItemCategoryListScreenWeb extends ConsumerStatefulWidget {
  const ItemCategoryListScreenWeb({super.key});

  @override
  ConsumerState<ItemCategoryListScreenWeb> createState() => _ItemCategoryListScreenWebState();
}

class _ItemCategoryListScreenWebState extends ConsumerState<ItemCategoryListScreenWeb> {
  final debouncer = Debouncer(milliseconds: 500);
  @override
  Widget build(BuildContext context) {
    final itemCategoryNotifier = ref.watch(itemCategoryNotifierProvider.notifier);
    final itemCategoryState = ref.watch(itemCategoryNotifierProvider);

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
                      name: 'category_search',
                      hintText: context.l10n.search,
                      onChanged: (val) {
                        debouncer.run(() {
                          itemCategoryNotifier.getItemCategories(
                            query: val ?? '',
                          );
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  AppButton.icon(
                    padding: const EdgeInsets.all(16),
                    onPress: () {
                      showDialog<void>(
                        context: context,
                        builder: (context) => const AddCategoryDialog(),
                      );
                    },
                    label: Text(context.l10n.addCategory),
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
                        columns: itemCategoryNotifier.categoryColumns,
                        // ignore: prefer_const_literals_to_create_immutables
                        rows: [],
                        onLoaded: (PlutoGridOnLoadedEvent event) {
                          itemCategoryNotifier.setStateManager(
                            stateManager: event.stateManager,
                          );
                        },
                        configuration: AppStylesX.dataTableConfig,
                        noRowsWidget: const NoDataViewWidget(),
                      ),
                    ),
                    PaginationFooter(
                      onPageChanged: (value) {
                        itemCategoryNotifier.setFilter(
                          pageNumber: value,
                        );
                      },
                      totalPages: (itemCategoryState.count / itemCategoryState.pageSize).ceil(),
                      currentPage: itemCategoryState.pageNumber,
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
