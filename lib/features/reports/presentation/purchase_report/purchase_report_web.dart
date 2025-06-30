import 'package:duxbe/features/reports/controller/purchase_report/purchase_report_notifier.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

class PurchaseReportScreenWeb extends ConsumerStatefulWidget {
  const PurchaseReportScreenWeb({super.key});

  @override
  ConsumerState<PurchaseReportScreenWeb> createState() => _PurchaseReportScreenWebState();
}

class _PurchaseReportScreenWebState extends ConsumerState<PurchaseReportScreenWeb> with AutomaticKeepAliveClientMixin {
  final debouncer = Debouncer(milliseconds: 500);
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final purchaseReportState = ref.watch(purchaseReportNotifierProvider);
    final purchaseReportNotifier = ref.watch(purchaseReportNotifierProvider.notifier);
    return Column(
      children: [
        FormBuilder(
          onChanged: () {
            final value = _formKey.currentState!.instantValue;
            debouncer.run(() {
              ref.read(purchaseReportNotifierProvider.notifier).setFilter(
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
                ),
              ),
              const SizedBox(width: 8),
              AppButton.icon(
                style: ButtonStyles.secondary,
                onPress: () {},
                label: Text(context.l10n.export),
                icon: const Icon(Icons.table_rows_outlined),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ref
            .watch(
              purchaseSummaryProvider(
                purchaseReportState.fromDate,
                purchaseReportState.toDate,
              ),
            )
            .when(
              data: (data) => Row(
                children: [
                  Expanded(
                    child: ReportCard(
                      color: const Color(0xFF9B9B9B),
                      title: context.l10n.totalPurchase,
                      value: data.totalPurchaseCount.toString(),
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
                      value: data.totalPurchaseAmount.toString(),
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
                  columns: purchaseReportNotifier.purchaseReportColumns,
                  // ignore: prefer_const_literals_to_create_immutables
                  rows: [],
                  onLoaded: (PlutoGridOnLoadedEvent event) {
                    ref.read(purchaseReportNotifierProvider.notifier).setStateManager(stateManager: event.stateManager);
                  },
                  configuration: AppStylesX.dataTableConfig,
                  noRowsWidget: const NoDataViewWidget(),
                ),
              ),
              PaginationFooter(
                onPageChanged: (value) {
                  purchaseReportNotifier.setFilter(pageNumber: value);
                },
                totalPages: (purchaseReportState.count / purchaseReportState.pageSize).ceil(),
                currentPage: purchaseReportState.pageNumber,
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
