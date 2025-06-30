import 'package:duxbe/features/reports/reports.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

class DailyTransactionReportScreenWeb extends ConsumerStatefulWidget {
  const DailyTransactionReportScreenWeb({super.key});

  @override
  ConsumerState<DailyTransactionReportScreenWeb> createState() =>
      _DailyTransactionReportScreenWebState();
}

class _DailyTransactionReportScreenWebState
    extends ConsumerState<DailyTransactionReportScreenWeb>
    with AutomaticKeepAliveClientMixin {
  final debouncer = Debouncer(milliseconds: 500);
  final _formKey = GlobalKey<FormBuilderState>();
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final dailyTransactionState = ref.watch(dailyTransactionNotifierProvider);
    final dailyTransactionNotifier =
        ref.watch(dailyTransactionNotifierProvider.notifier);
    return Column(
      children: [
        FormBuilder(
          onChanged: () {
            final value = _formKey.currentState!.instantValue;
            debouncer.run(() {
              dailyTransactionNotifier.setFilter(
                query: value['query'] as String?,
                fromDate: value['from_date'] as DateTime?,
                toDate: value['to_date'] as DateTime?,
                // paidOrDueList: value['due_status'] as bool?,
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
                child: AppDateTimeForm(
                  name: 'from_date',
                  hintText: context.l10n.fromDate,
                  label: null,
                  inputType: InputType.date,
                  showCloseButton: true,
                  valueTransformer: (value) => value,
                  onClear: () {
                    _formKey.currentState?.fields['to_date']?.didChange(null);
                    _formKey.currentState?.fields['to_date']?.reset();
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
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
                // onPress: () {},
                onPress: dailyTransactionNotifier.exportDailyTransaction,
                label: Text(context.l10n.export),
                icon: const Icon(Icons.table_rows_outlined),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ref
            .watch(
              dailyTransactionSummaryProvider(
                dailyTransactionState.fromDate,
                dailyTransactionState.toDate,
              ),
            )
            .when(
              data: (data) => Row(
                children: [
                  Expanded(
                    child: ReportCard(
                      color: const Color(0xFF9B9B9B),
                      title: context.l10n.remainingBalance,
                      value: data.netBalanceChange.toString(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ReportCard(
                      color: const Color(0xFF87BD7E),
                      title: context.l10n.totalPaymentsIn,
                      value: data.totalPaymentsIn.toString(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ReportCard(
                      color: const Color(0xFFE3AF7F),
                      title: context.l10n.totalPaymentsOut,
                      value: data.totalPaymentsOut.toString(),
                    ),
                  ),
                ],
              ),
              error: (error, stack) => Text(error.toString()),
              loading: () => const CircularProgressIndicator(),
            ),
        const SizedBox(height: 20),
        Expanded(
          child: PlutoGrid(
            mode: PlutoGridMode.readOnly,
            columns: dailyTransactionNotifier.dailyTransactionColumns,
            // ignore: prefer_const_literals_to_create_immutables
            rows: [],
            onLoaded: (PlutoGridOnLoadedEvent event) {
              dailyTransactionNotifier.setStateManager(event.stateManager);
            },
            configuration: AppStylesX.dataTableConfig,
            noRowsWidget: const NoDataViewWidget(),
          ),
        ),
        PaginationFooter(
          onPageChanged: (value) {
            dailyTransactionNotifier.setFilter(pageNumber: value);
          },
          totalPages:
              (dailyTransactionState.count / dailyTransactionState.pageSize)
                  .ceil(),
          currentPage: dailyTransactionState.pageNumber,
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
