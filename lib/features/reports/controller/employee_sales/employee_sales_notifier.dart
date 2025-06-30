import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/reports/reports.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'employee_sales_notifier.freezed.dart';
part 'employee_sales_notifier.g.dart';
part 'employee_sales_state.dart';

@Riverpod(keepAlive: true)
Future<EmployeeSalesSummary> employeeSalesSummary(
  EmployeeSalesSummaryRef ref,
  String? query,
  int? pageSize,
  int? pageNumber,
  DateTime? startDate,
  DateTime? endDate,
) async =>
    ref.watch(reportRepoProvider).getEmployeeSalesSummary(
        query: query ?? '',
        pageSize: pageSize ?? 10,
        pageNumber: pageNumber ?? 1,
        fromDate: startDate,
        toDate: endDate,);

@Riverpod(keepAlive: false)
class EmployeeSalesNotifier extends _$EmployeeSalesNotifier {
  late IReportRepository _reportRepository;
  @override
  EmployeeSalesState build() {
    _reportRepository = ref.watch(reportRepoProvider);
    ref.listen(businessNotifierProvider, (previous, next) {
      setFilter(pageNumber: 1);
    });

    state = EmployeeSalesState.initial();

    return state.copyWith(
      pagingController: PagingController<int, EmployeeSales>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener(
          (pageKey) async {
            final due = await getEmployeeSalesReport(pageNumber: pageKey);
            final isLastPage = due.length < state.pageSize;
            if (isLastPage) {
              state.pagingController!.appendLastPage(due);
            } else {
              final nextPageKey = pageKey + 1;
              state.pagingController!.appendPage(due, nextPageKey);
            }
          },
        ),
    );
  }

  void setStateManager({required PlutoGridStateManager stateManager}) {
    state = state.copyWith(stateManager: stateManager);
    setTable();
  }

  void setFilter({
    String? query,
    int? pageSize,
    int? pageNumber,
    Object? fromDate = freezed,
    Object? toDate = freezed,
  }) {
    state = state.copyWith(
      query: query ?? state.query,
      pageSize: pageSize ?? state.pageSize,
      pageNumber: pageNumber ?? state.pageNumber,
      fromDate: fromDate == freezed ? state.fromDate : fromDate as DateTime?,
      toDate: toDate == freezed ? state.toDate : toDate as DateTime?,
    );
    state.pagingController?.refresh();
    setTable();
  }

  Future<List<EmployeeSales>> getEmployeeSalesReport({
    String? query,
    int? pageSize,
    int? pageNumber,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final employeeSales = await _reportRepository.getEmployeeSalesReport(
        query: query ?? state.query,
        pageSize: pageSize ?? state.pageSize,
        pageNumber: pageNumber ?? state.pageNumber,
        fromDate: fromDate ?? state.fromDate,
        toDate: toDate ?? state.toDate,
      );
      return employeeSales;
    } catch (e) {
      state = state.copyWith(
        status: EmployeeSalesStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<void> setTable({
    String? query,
    int? pageSize,
    int? pageNumber,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    state.stateManager?.setShowLoading(true);
    state = state.copyWith(status: EmployeeSalesStatus.loading);
    final employeeSales = await getEmployeeSalesReport();
    state = state.copyWith(
      status: EmployeeSalesStatus.success,
      employeeSales: employeeSales,
      pageNumber: pageNumber ?? state.pageNumber,
    );

    final baseIndex = (state.pageNumber - 1) * state.pageSize + 1;
    final rows = await PlutoGridStateManager.initializeRowsAsync(
      employeeSalesColumns,
      [
        for (int i = 0; i < state.employeeSales.length; i++)
          PlutoRow(
            cells: {
              'sl_no': PlutoCell(value: baseIndex + i),
              'employee_name':
                  PlutoCell(value: state.employeeSales[i].employeeName),
              'employee_role': PlutoCell(
                value: state.employeeSales[i].employeeRole.displayCase,
              ),
              'employee_code':
                  PlutoCell(value: state.employeeSales[i].employeeCode ?? ''),
              'total_items_sold':
                  PlutoCell(value: state.employeeSales[i].totalItemsSold),
              'total_revenue_generated': PlutoCell(
                value: state.employeeSales[i].totalRevenueGenerated,
              ),
            },
          ),
      ],
    );
    state.stateManager?.refRows.clear();
    state.stateManager?.refRows.addAll(rows);
    state.stateManager?.setShowLoading(false);
  }

  final List<PlutoColumn> employeeSalesColumns = <PlutoColumn>[
    PlutoColumn(
      title: AppRouter.l10n.slNo,
      field: 'sl_no',
      width: 24,
      titleSpan: TextSpan(
        text: AppRouter.l10n.slNo,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.name,
      field: 'employee_name',
      titleSpan: TextSpan(
        text: AppRouter.l10n.name,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.employeeRole,
      field: 'employee_role',
      titleSpan: TextSpan(
        text: AppRouter.l10n.employeeRole,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.employeeCode,
      field: 'employee_code',
      titleSpan: TextSpan(
        text: AppRouter.l10n.employeeCode,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.totalItemsSold,
      field: 'total_items_sold',
      titleSpan: TextSpan(
        text: AppRouter.l10n.totalItemsSold,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.totalRevenueGenerated,
      field: 'total_revenue_generated',
      titleSpan: TextSpan(
        text: AppRouter.l10n.totalRevenueGenerated,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
  ];
}
