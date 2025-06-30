import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

class ItemListScreenWeb extends ConsumerStatefulWidget {
  const ItemListScreenWeb({super.key});

  @override
  ConsumerState<ItemListScreenWeb> createState() => _ItemListScreenWebState();
}

class _ItemListScreenWebState extends ConsumerState<ItemListScreenWeb> {
  final debouncer = Debouncer(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    final itemNotifier = ref.watch(itemNotifierProvider.notifier);
    final itemState = ref.watch(itemNotifierProvider);

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
                      itemNotifier.setFilter(query: val ?? '');
                    });
                  },
                ),
              ),
              const SizedBox(width: 20),
              SizedBox(
                width: 200,
                child: AppDropDownForm<ItemType?>(
                  name: 'type',
                  label: null,
                  items: [
                    DropDownItems(
                      child: Text(context.l10n.all),
                    ),
                    ...ItemType.values.map(
                      (e) => DropDownItems(
                        value: e,
                        child: Text(e.name.displayCase),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    itemNotifier.setFilter(itemType: value);
                  },
                ),
              ),
              const SizedBox(width: 20),
              AppButton(
                onPress: () {
                  context.goNamed(AppRouter.importItem);
                },
                label: Text(context.l10n.import),
                color: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
              ),
              const SizedBox(width: 20),
              AppButton.icon(
                onPress: () {
                  context.goNamed(AppRouter.createItem);
                },
                label: Text(context.l10n.addItem),
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
                    columns: itemNotifier.itemColumns,
                    // ignore: prefer_const_literals_to_create_immutables
                    rows: [],
                    onLoaded: (PlutoGridOnLoadedEvent event) {
                      itemNotifier.setStateManager(
                        stateManager: event.stateManager,
                      );
                    },
                    configuration: AppStylesX.dataTableConfig,
                    noRowsWidget: const NoDataViewWidget(),
                  ),
                ),
                PaginationFooter(
                  onPageChanged: (value) {
                    itemNotifier.setFilter(pageNumber: value);
                  },
                  totalPages: (itemState.count / itemState.pageSize).ceil(),
                  currentPage: itemState.pageNumber,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
