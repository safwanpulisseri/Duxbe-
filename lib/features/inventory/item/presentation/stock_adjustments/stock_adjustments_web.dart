import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

class StockAdjustmentsScreenWeb extends ConsumerStatefulWidget {
  const StockAdjustmentsScreenWeb({super.key});

  @override
  ConsumerState<StockAdjustmentsScreenWeb> createState() => _StockAdjustmentsScreenWebState();
}

class _StockAdjustmentsScreenWebState extends ConsumerState<StockAdjustmentsScreenWeb> {
  final debouncer = Debouncer(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    final adjustmentsNotifier = ref.watch(stockAdjustmentsNotifierProvider.notifier);
    final adjustmentsState = ref.watch(stockAdjustmentsNotifierProvider);

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
                  name: 'adjustment_search',
                  hintText: context.l10n.enterNameCodeOrCategory,
                  onChanged: (val) {
                    debouncer.run(() {
                      adjustmentsNotifier.getStockAdjustments(query: val ?? '');
                    });
                  },
                ),
              ),
              const SizedBox(width: 20),
              AppButton.icon(
                icon: const Icon(Icons.add),
                onPress: () {
                  context.goNamed(AppRouter.multiStockAdjust);
                },
                label: Text(context.l10n.newAdjustment),
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
                    columns: adjustmentsNotifier.adjustedColumns,
                    // ignore: prefer_const_literals_to_create_immutables
                    rows: [],
                    onLoaded: (PlutoGridOnLoadedEvent event) {
                      adjustmentsNotifier.setStateManager(
                        stateManager: event.stateManager,
                      );
                    },
                    configuration: AppStylesX.dataTableConfig,
                    noRowsWidget: const NoDataViewWidget(),
                  ),
                ),
                PaginationFooter(
                  onPageChanged: (value) {
                    adjustmentsNotifier.getStockAdjustments(pageNumber: value);
                  },
                  totalPages: (adjustmentsState.count / adjustmentsState.pageSize).ceil(),
                  currentPage: adjustmentsState.pageNumber,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
