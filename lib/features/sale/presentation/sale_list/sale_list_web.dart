import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

class SaleListScreenWeb extends ConsumerStatefulWidget {
  const SaleListScreenWeb({super.key});

  @override
  ConsumerState<SaleListScreenWeb> createState() => _SaleListScreenWebState();
}

class _SaleListScreenWebState extends ConsumerState<SaleListScreenWeb> {
  final debouncer = Debouncer(milliseconds: 500);
  @override
  Widget build(BuildContext context) {
    final saleListNotifier = ref.watch(saleListNotifierProvider.notifier);
    final saleListState = ref.watch(saleListNotifierProvider);

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
                      name: 'sale_search',
                      hintText: context.l10n.search,
                      onChanged: (val) {
                        debouncer.run(() {
                          saleListNotifier.setFilter(query: val ?? '');
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  AppButton.icon(
                    padding: const EdgeInsets.all(16),
                    onPress: () {
                      context.goNamed(AppRouter.pos);
                    },
                    label: Text(context.l10n.createSale),
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
                        columns: saleListNotifier.supplierColumns,
                        // ignore: prefer_const_literals_to_create_immutables
                        rows: [],
                        onLoaded: (PlutoGridOnLoadedEvent event) {
                          saleListNotifier.setStateManager(
                            stateManager: event.stateManager,
                          );
                        },
                        configuration: AppStylesX.dataTableConfig,
                        noRowsWidget: const NoDataViewWidget(),
                      ),
                    ),
                    PaginationFooter(
                      onPageChanged: (value) {
                        saleListNotifier.setFilter(pageNumber: value);
                      },
                      totalPages: (saleListState.count / saleListState.pageSize).ceil(),
                      currentPage: saleListState.pageNumber,
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
