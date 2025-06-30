import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

class UnitListScreenWeb extends ConsumerStatefulWidget {
  const UnitListScreenWeb({super.key});

  @override
  ConsumerState<UnitListScreenWeb> createState() => _UnitListScreenWebState();
}

class _UnitListScreenWebState extends ConsumerState<UnitListScreenWeb> {
  final debouncer = Debouncer(milliseconds: 500);
  @override
  Widget build(BuildContext context) {
    final unitNotifier = ref.watch(unitNotifierProvider.notifier);
    final unitState = ref.watch(unitNotifierProvider);

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
                      name: 'unit_search',
                      hintText: context.l10n.search,
                      onChanged: (val) {
                        debouncer.run(() {
                          unitNotifier.setFilter(query: val ?? '');
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
                        builder: (context) => const AddUnitDialog(),
                      );
                    },
                    label: Text(context.l10n.addUnit),
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
                        columns: unitNotifier.unitColumns,
                        // ignore: prefer_const_literals_to_create_immutables
                        rows: [],
                        onLoaded: (PlutoGridOnLoadedEvent event) {
                          unitNotifier.setStateManager(
                            stateManager: event.stateManager,
                          );
                        },
                        configuration: AppStylesX.dataTableConfig,
                        noRowsWidget: const NoDataViewWidget(),
                      ),
                    ),
                    PaginationFooter(
                      onPageChanged: (value) {
                        unitNotifier.setFilter(pageNumber: value);
                      },
                      totalPages: (unitState.count / unitState.pageSize).ceil(),
                      currentPage: unitState.pageNumber,
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
