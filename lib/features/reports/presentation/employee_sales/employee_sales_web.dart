import 'package:duxbe/features/reports/controller/employee_sales/employee_sales_notifier.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

class EmployeeSalesScreenWeb extends ConsumerStatefulWidget {
  const EmployeeSalesScreenWeb({super.key});

  @override
  ConsumerState<EmployeeSalesScreenWeb> createState() =>
      _EmployeeSalesScreenWebState();
}

class _EmployeeSalesScreenWebState extends ConsumerState<EmployeeSalesScreenWeb>
    with AutomaticKeepAliveClientMixin {
  final debouncer = Debouncer(milliseconds: 500);
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final employeeSalesState = ref.watch(employeeSalesNotifierProvider);
    final employeeSalesNotifier =
        ref.watch(employeeSalesNotifierProvider.notifier);
    return Column(
      children: [
        FormBuilder(
          onChanged: () {
            final value = _formKey.currentState!.instantValue;
            debouncer.run(() {
              employeeSalesNotifier.setFilter(
                query: value['query'] as String?,
                fromDate: value['from_date'] as DateTime?,
                toDate: value['to_date'] as DateTime?,
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
            ],
          ),
        ),
        const SizedBox(height: 20),
        ref.watch(employeeSalesSummaryProvider(
          employeeSalesState.query,
           employeeSalesState.pageSize,
         employeeSalesState.pageNumber,
        employeeSalesState.fromDate,
         employeeSalesState.toDate,
              ),
            )
            .when(
              data: (data) {
          return Row(
          children: [
            Expanded(
              child: ReportCard(
                color: const Color(0xFF87BD7E),
                title: context.l10n.totalItemsSold,
                value: data.totalItemsSold.toString(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ReportCard(
                color: const Color(0xFFE3AF7F),
                title: context.l10n.totalRevenueGenerated,
                value: data.totalRevenueGenerated.toStringAsFixed(2),
              ),
            ),
            // const SizedBox(width: 8),
            // const Spacer(),
          ],
        );
        }, error: (error, stack) => Text(error.toString()),
              loading: () => const CircularProgressIndicator(),),
        const SizedBox(height: 20),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: PlutoGrid(
                  mode: PlutoGridMode.readOnly,
                  columns: employeeSalesNotifier.employeeSalesColumns,
                  // ignore: prefer_const_literals_to_create_immutables
                  rows: [],
                  onLoaded: (PlutoGridOnLoadedEvent event) {
                    employeeSalesNotifier.setStateManager(
                      stateManager: event.stateManager,
                    );
                  },
                  configuration: AppStylesX.dataTableConfig,
                  noRowsWidget: const NoDataViewWidget(),
                ),
              ),
              PaginationFooter(
                onPageChanged: (value) {
                  employeeSalesNotifier.setFilter(pageNumber: value);
                },
                totalPages:
                    (employeeSalesState.count / employeeSalesState.pageSize)
                        .ceil(),
                currentPage: employeeSalesState.pageNumber,
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
