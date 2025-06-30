import 'package:duxbe/features/reports/reports.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

class SalesReportScreenWeb extends ConsumerStatefulWidget {
  const SalesReportScreenWeb({super.key});

  @override
  ConsumerState<SalesReportScreenWeb> createState() =>
      _SalesReportScreenWebState();
}

class _SalesReportScreenWebState extends ConsumerState<SalesReportScreenWeb>
    with AutomaticKeepAliveClientMixin {
  final debouncer = Debouncer(milliseconds: 500);
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final saleReportState = ref.watch(salesReportNotifierProvider);
    final saleReportNotifier = ref.watch(salesReportNotifierProvider.notifier);
    return Column(
      children: [
        FormBuilder(
          onChanged: () {
            final value = _formKey.currentState!.instantValue;
            debouncer.run(() {
              saleReportNotifier.setFilter(
                query: value['query'] as String?,
                fromDate: value['from_date'] as DateTime?,
                toDate: value['to_date'] as DateTime?,
                paidOrDueList: value['due_status'] as bool?,
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
              Flexible(
                child: AppDropDownForm(
                  name: 'due_status',
                  label: null,
                  items: [
                    {'All': null},
                    {'Paid': true},
                    {'Due': false},
                  ]
                      .map(
                        (e) => DropDownItems(
                          value: e.values.first,
                          child: Text(e.keys.first),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: AppDateTimeForm(
                  name: 'from_date',
                  hintText: context.l10n.fromDate,
                  label: null,
                  inputType: InputType.date,
                  showCloseButton: true,
                  valueTransformer: (value) => value,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: AppDateTimeForm(
                  name: 'to_date',
                  hintText: context.l10n.toDate,
                  label: null,
                  inputType: InputType.date,
                  showCloseButton: true,
                  valueTransformer: (value) => value,
                ),
              ),
              const SizedBox(width: 8),
              AppButton.icon(
                style: ButtonStyles.secondary,
                onPress: saleReportNotifier.exportSales,
                label: Text(context.l10n.export),
                icon: const Icon(Icons.table_rows_outlined),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ref
            .watch(
              salesSummaryProvider(
                saleReportState.fromDate,
                saleReportState.toDate,
              ),
            )
            .when(
              data: (data) => Row(
                children: [
                  Expanded(
                    child: ReportCard(
                      color: const Color(0xFF9B9B9B),
                      title: context.l10n.totalSales,
                      value: data.totalSalesCount.toString(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ReportCard(
                      color: const Color(0xFF87BD7E),
                      title: context.l10n.unpaid,
                      value: data.totalDue.toString(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ReportCard(
                      color: const Color(0xFFE3AF7F),
                      title: context.l10n.totalAmount,
                      value: data.totalSalesAmount.toString(),
                    ),
                  ),
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
                  columns: saleReportNotifier.saleReportColumns,
                  // ignore: prefer_const_literals_to_create_immutables
                  rows: [],
                  onLoaded: (PlutoGridOnLoadedEvent event) {
                    saleReportNotifier.setStateManager(
                      stateManager: event.stateManager,
                    );
                  },
                  configuration: AppStylesX.dataTableConfig,
                  noRowsWidget: const NoDataViewWidget(),
                ),
              ),
              PaginationFooter(
                onPageChanged: (value) {
                  saleReportNotifier.setFilter(pageNumber: value);
                },
                totalPages:
                    (saleReportState.count / saleReportState.pageSize).ceil(),
                currentPage: saleReportState.pageNumber,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => false;
}
