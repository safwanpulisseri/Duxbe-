import 'package:duxbe/features/inventory/item/controller/manage_stock/manage_stock_notifier.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

class ManageStockScreenWeb extends ConsumerStatefulWidget {
  const ManageStockScreenWeb({super.key});

  @override
  ConsumerState<ManageStockScreenWeb> createState() => _ManageStockScreenWebState();
}

class _ManageStockScreenWebState extends ConsumerState<ManageStockScreenWeb> {
  final debouncer = Debouncer(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    final manageStockNotifier = ref.watch(manageStockNotifierProvider.notifier);
    final manageStockState = ref.watch(manageStockNotifierProvider);

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: AppStyles.boxDecoration,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AppTextForm<String>(
                  name: 'item_search',
                  hintText: context.l10n.enterNameCodeOrCategory,
                  onChanged: (val) {
                    debouncer.run(() {
                      manageStockNotifier.setFilter(query: val ?? '');
                    });
                  },
                ),
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
                    columns: manageStockNotifier.itemColumns,
                    // ignore: prefer_const_literals_to_create_immutables
                    rows: [],
                    onLoaded: (PlutoGridOnLoadedEvent event) {
                      manageStockNotifier.setStateManager(
                        stateManager: event.stateManager,
                      );
                    },
                    configuration: AppStylesX.dataTableConfig,
                    noRowsWidget: const NoDataViewWidget(),
                  ),
                ),
                PaginationFooter(
                  onPageChanged: (value) {
                    manageStockNotifier.getItems(pageNumber: value);
                  },
                  totalPages: (manageStockState.count / manageStockState.pageSize).ceil(),
                  currentPage: manageStockState.pageNumber,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
