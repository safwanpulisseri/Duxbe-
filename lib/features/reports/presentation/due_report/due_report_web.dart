import 'package:duxbe/features/reports/reports.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

class DueReportScreenWeb extends ConsumerStatefulWidget {
  const DueReportScreenWeb({super.key});

  @override
  ConsumerState<DueReportScreenWeb> createState() => _DueReportScreenWebState();
}

class _DueReportScreenWebState extends ConsumerState<DueReportScreenWeb> with AutomaticKeepAliveClientMixin {
  final debouncer = Debouncer(milliseconds: 500);
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final dueReportState = ref.watch(dueReportNotifierProvider);
    final dueReportNotifier = ref.watch(dueReportNotifierProvider.notifier);
    return Column(
      children: [
        FormBuilder(
          onChanged: () {
            final value = _formKey.currentState!.instantValue;
            debouncer.run(() {
              dueReportNotifier.setFilter(
                query: value['query'] as String?,
                salesOrPurchase: value['sales_or_purchase'] as bool?,
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
                  name: 'sales_or_purchase',
                  label: null,
                  items: [
                    {'All': null},
                    {'Sales Due': true},
                    {'Purchase Due': false},
                  ]
                      .map(
                        (e) => DropDownItems(value: e.values.first, child: Text(e.keys.first)),
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
                onPress: dueReportNotifier.exportDueReport,
                label: Text(context.l10n.export),
                icon: const Icon(Icons.table_rows_outlined),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ref
            .watch(
              totalDuesSummaryProvider(
                dueReportState.fromDate,
                dueReportState.toDate,
              ),
            )
            .when(
              data: (data) => Row(
                children: [
                  Expanded(
                    child: ReportCard(
                      color: const Color(0xFF87BD7E),
                      title: context.l10n.salesDue,
                      value: data.totalSalesDue.toString(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ReportCard(
                      color: const Color(0xFFE3AF7F),
                      title: context.l10n.purchaseDue,
                      value: data.totalPurchaseDue.toString(),
                    ),
                  ),
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
                  columns: dueReportNotifier.dueReportColumns,
                  // ignore: prefer_const_literals_to_create_immutables
                  rows: [],
                  onLoaded: (PlutoGridOnLoadedEvent event) {
                    dueReportNotifier.setStateManager(stateManager: event.stateManager);
                  },
                  configuration: AppStylesX.dataTableConfig,
                  noRowsWidget: const NoDataViewWidget(),
                ),
              ),
              PaginationFooter(
                onPageChanged: (value) {
                  dueReportNotifier.setFilter(pageNumber: value);
                },
                totalPages: (dueReportState.count / dueReportState.pageSize).ceil(),
                currentPage: dueReportState.pageNumber,
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
