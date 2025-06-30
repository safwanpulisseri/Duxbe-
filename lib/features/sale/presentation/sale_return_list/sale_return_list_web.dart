import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/sale/controller/sale_return/sale_return_notifier.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

class SaleReturnListScreenWeb extends ConsumerStatefulWidget {
  const SaleReturnListScreenWeb({super.key});

  @override
  ConsumerState<SaleReturnListScreenWeb> createState() => _SaleReturnListScreenWebState();
}

class _SaleReturnListScreenWebState extends ConsumerState<SaleReturnListScreenWeb> {
  final debouncer = Debouncer(milliseconds: 500);
  @override
  Widget build(BuildContext context) {
    final saleReturnNotifier = ref.watch(saleReturnNotifierProvider.notifier);
    final saleReturnState = ref.watch(saleReturnNotifierProvider);

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
                          saleReturnNotifier.getSaleReturns(query: val ?? '');
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  AppButton.icon(
                    padding: const EdgeInsets.all(16),
                    onPress: () {
                      context.goNamed(AppRouter.createSaleReturn);
                    },
                    label: Text(context.l10n.createSaleReturn),
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
                        columns: saleReturnNotifier.supplierColumns,
                        // ignore: prefer_const_literals_to_create_immutables
                        rows: [],
                        onLoaded: (PlutoGridOnLoadedEvent event) {
                          saleReturnNotifier.setStateManager(
                            stateManager: event.stateManager,
                          );
                        },
                        configuration: AppStylesX.dataTableConfig,
                        noRowsWidget: const NoDataViewWidget(),
                      ),
                    ),
                    PaginationFooter(
                      onPageChanged: (value) {
                        saleReturnNotifier.getSaleReturns(pageNumber: value);
                      },
                      totalPages: (saleReturnState.count / saleReturnState.pageSize).ceil(),
                      currentPage: saleReturnState.pageNumber,
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
