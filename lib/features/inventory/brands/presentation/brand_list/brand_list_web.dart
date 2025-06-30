import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

class BrandListScreenWeb extends ConsumerStatefulWidget {
  const BrandListScreenWeb({super.key});

  @override
  ConsumerState<BrandListScreenWeb> createState() => _BrandListScreenWebState();
}

class _BrandListScreenWebState extends ConsumerState<BrandListScreenWeb> {
  final debouncer = Debouncer(milliseconds: 500);
  @override
  Widget build(BuildContext context) {
    final brandNotifier = ref.watch(brandNotifierProvider.notifier);
    final brandState = ref.watch(brandNotifierProvider);

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
                      name: 'brand_search',
                      hintText: context.l10n.search,
                      onChanged: (val) {
                        debouncer.run(() {
                          brandNotifier.getBrands(query: val ?? '');
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
                        builder: (context) => const AddBrandDialog(),
                      );
                    },
                    label: Text(context.l10n.addBrand),
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
                        columns: brandNotifier.brandColumns,
                        // ignore: prefer_const_literals_to_create_immutables
                        rows: [],
                        onLoaded: (PlutoGridOnLoadedEvent event) {
                          brandNotifier.setStateManager(
                            stateManager: event.stateManager,
                          );
                        },
                        configuration: AppStylesX.dataTableConfig,
                        noRowsWidget: const NoDataViewWidget(),
                      ),
                    ),
                    PaginationFooter(
                      onPageChanged: (value) {
                        brandNotifier.setFilter(pageNumber: value);
                      },
                      totalPages: (brandState.count / brandState.pageSize).ceil(),
                      currentPage: brandState.pageNumber,
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
