import 'package:duxbe/features/reports/reports.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

class StockReportScreenWeb extends ConsumerStatefulWidget {
  const StockReportScreenWeb({super.key});

  @override
  ConsumerState<StockReportScreenWeb> createState() => _StockReportScreenWebState();
}

class _StockReportScreenWebState extends ConsumerState<StockReportScreenWeb> with AutomaticKeepAliveClientMixin {
  final debouncer = Debouncer(milliseconds: 500);
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final stockReportState = ref.watch(stockReportNotifierProvider);
    final stockReportNotifier = ref.watch(stockReportNotifierProvider.notifier);
    return Column(
      children: [
        FormBuilder(
          onChanged: () {
            final value = _formKey.currentState!.instantValue;
            debouncer.run(() {
              stockReportNotifier.setFilter(
                query: value['query'] as String?,
                stockStatus: value['stock_status'] as String?,
              );
            });
          },
          key: _formKey,
          child: Row(
            children: [
              Expanded(
                child: AppTextForm<String>(
                  hintText: context.l10n.search,
                  name: 'query',
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 200,
                child: AppDropDownForm(
                  name: 'stock_status',
                  label: null,
                  items: [
                    {'All': null},
                    {'In Stock': 'In Stock'},
                    {'Low Stock': 'Low Stock'},
                    {'Out of Stock': 'Out of Stock'},
                  ]
                      .map(
                        (e) => DropDownItems(value: e.values.first, child: Text(e.keys.first)),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(width: 8),
              AppButton.icon(
                style: ButtonStyles.secondary,
                onPress: stockReportNotifier.exportStockReport,
                label: Text(context.l10n.export),
                icon: const Icon(Icons.table_rows_outlined),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ref.watch(totalStockValueProvider).when(
              data: (data) => Row(
                children: [
                  Expanded(
                    child: ReportCard(
                      color: const Color(0xFFE3AF7F),
                      title: context.l10n.totalStockValue,
                      value: data.toStringAsFixed(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Spacer(),
                  const SizedBox(width: 8),
                  const Spacer(),
                ],
              ),
              error: (error, stack) => Text(error.toString()),
              loading: () => const CircularProgressIndicator(),
            ),
        const SizedBox(height: 20),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: PlutoGrid(
                  mode: PlutoGridMode.readOnly,
                  columns: stockReportNotifier.stockReportColumns,
                  // ignore: prefer_const_literals_to_create_immutables
                  rows: [],
                  onLoaded: (PlutoGridOnLoadedEvent event) {
                    stockReportNotifier.setStateManager(stateManager: event.stateManager);
                  },
                  configuration: AppStylesX.dataTableConfig,
                  noRowsWidget: const NoDataViewWidget(),
                ),
              ),
              PaginationFooter(
                onPageChanged: (value) {
                  stockReportNotifier.setFilter(pageNumber: value);
                },
                totalPages: (stockReportState.count / stockReportState.pageSize).ceil(),
                currentPage: stockReportState.pageNumber,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
