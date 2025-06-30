import 'dart:async';

import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/staffs/staffs.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'employee_notifier.freezed.dart';
part 'employee_notifier.g.dart';
part 'employee_state.dart';

@Riverpod(keepAlive: false)
class EmployeeNotifier extends _$EmployeeNotifier {
  late IStaffRepository _staffRepository;

  @override
  EmployeeState build() {
    _staffRepository = ref.watch(staffRepoProvider);
    // Watch for business changes
    ref.listen(businessNotifierProvider, (previous, next) {
      // Refresh the paging controller when business changes
      setFilter(pageNumber: 1);
    });

    state = EmployeeState();

    // This is to set infinte scrolling in mobile devices
    return state.copyWith(
      pagingController: PagingController<int, EmployeeModel>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener(
          (pageKey) async {
            final employees = await getEmployees(pageNumber: pageKey);
            final isLastPage = employees.data.length < state.pageSize;
            if (isLastPage) {
              state.pagingController!.appendLastPage(employees.data);
            } else {
              final nextPageKey = pageKey + 1;
              state.pagingController!.appendPage(employees.data, nextPageKey);
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
    Object? fromDate,
    Object? toDate,
  }) {
    state = state.copyWith(
      query: query ?? state.query,
      pageSize: pageSize ?? state.pageSize,
      pageNumber: pageNumber ?? state.pageNumber,
    );
    state.pagingController?.refresh();
    setTable();
  }

  Future<PaginatedResponse<EmployeeModel>> getEmployees({
    String? query,
    int? pageSize,
    int? pageNumber,
  }) async {
    try {
      final employees = await _staffRepository.getEmployees(
        query: query ?? state.query,
        pageSize: pageSize ?? state.pageSize,
        pageNumber: pageNumber ?? state.pageNumber,
      );
      return employees;
    } catch (e) {
      state = state.copyWith(
        status: EmployeeStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  final List<PlutoColumn> userListColumns = <PlutoColumn>[
    PlutoColumn(
      title:  AppRouter.l10n.slNo,
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
      field: 'name',
      titleSpan: TextSpan(
        text: AppRouter.l10n.name,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.role,
      field: 'role',
      titleSpan: TextSpan(
        text: AppRouter.l10n.role,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.email,
      field: 'email',
      titleSpan: TextSpan(
        text: AppRouter.l10n.email,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.phoneNo,
      field: 'phone',
      titleSpan: TextSpan(
        text: AppRouter.l10n.phoneNo,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      titleTextAlign: PlutoColumnTextAlign.center,
      title: AppRouter.l10n.actions,
      field: 'actions',
      titleSpan: TextSpan(
        text: AppRouter.l10n.actions,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      renderer: (rendererContext) {
        final employee = rendererContext.cell.value as EmployeeModel;
        final isNotEditable = employee.employeeId ==
                AppRouter.read(authNotifierProvider).user?.employeeId ||
            employee.role == Role.admin;
        return isNotEditable
            ? const SizedBox()
            : Align(
                child: MenuAnchor(
                  builder: (context, controller, child) {
                    return IconButton(
                      onPressed: controller.isOpen
                          ? controller.close
                          : controller.open,
                      icon: const Icon(Icons.more_horiz),
                    );
                  },
                  menuChildren: [
                    MenuItemButton(
                      leadingIcon: Assets.icons.edit.svg(width: 20),
                      style: MenuItemButton.styleFrom(
                        foregroundColor: AppColors.primaryColor,
                      ),
                      onPressed: () {
                        showDialog<void>(
                          context: AppRouter.rootContext,
                          builder: (context) {
                            return AddEmployeeDialog(employee: employee);
                          },
                        );
                      },
                      child: Text(AppRouter.l10n.edit),
                    ),
                    MenuItemButton(
                      leadingIcon: const Icon(Icons.person_remove_rounded,
                        color: AppColors.red,
                        size: 20,
                      ),
                      onPressed: () {
                        showDialog<void>(
                          context: AppRouter.rootContext,
                          builder: (context) {
                            return ConfirmationDialog(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              title: AppRouter.l10n.removeBranchAccess,
                              children: [
                                Text(
                                  AppRouter.l10n
                                      .areYouSureYouWantToRemoveThisUserFromAccessingThisBranch,
                                  style: AppText.mediumN
                                      .copyWith(color: AppColors.primaryColor),
                                ),
                              ],
                              onPositive: (ref) {
                                ref
                                    .read(employeeNotifierProvider.notifier)
                                    .removeEmployeeBranchAccess(
                                      employee.employeeId,
                                    )
                                    .then((value) => AppRouter.pop());
                              },
                            );
                          },
                        );
                      },
                      style: MenuItemButton.styleFrom(
                        foregroundColor: AppColors.red,
                      ),
                      child: Text(AppRouter.l10n.removeBranchAccess),
                    ),
                    MenuItemButton(
                      leadingIcon: Assets.icons.delete.svg(width: 20),
                      onPressed: () {
                        showDialog<void>(
                          context: AppRouter.rootContext,
                          builder: (context) {
                            return ConfirmationDialog(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              title: AppRouter.l10n.deleteUser,
                              children: [
                                Text(
                                  AppRouter.l10n.deleteThisUser,
                                  style: AppText.mediumN
                                      .copyWith(color: AppColors.primaryColor),
                                ),
                              ],
                              onPositive: (ref) {
                                ref
                                    .read(employeeNotifierProvider.notifier)
                                    .deleteEmployee(employee.employeeId)
                                    .then((value) => AppRouter.pop());
                              },
                            );
                          },
                        );
                      },
                      style: MenuItemButton.styleFrom(
                        foregroundColor: AppColors.red,
                      ),
                      child: Text(AppRouter.l10n.delete),
                    ),
                  ],
                ),
              );
      },
      backgroundColor: AppColors.tableHeaderColor,
    ),
  ];

  Future<void> setTable() async {
    if (state.stateManager == null) return;
    state.stateManager?.setShowLoading(true);
    state = state.copyWith(status: EmployeeStatus.loading);

    final employees = await getEmployees();
    state = state.copyWith(
      status: EmployeeStatus.success,
      staffs: employees.data,
      count: employees.count,
    );

    final businessId = ref.read(businessNotifierProvider)?.businessId;
    final baseIndex = (state.pageNumber - 1) * state.pageSize + 1;
    final rows = await PlutoGridStateManager.initializeRowsAsync(
      userListColumns,
      [
        for (int i = 0; i < state.staffs.length; i++)
          PlutoRow(
            cells: {
              'sl_no': PlutoCell(value: baseIndex + i),
              'name': PlutoCell(value: state.staffs[i].name),
              'role': PlutoCell(
                value: state.staffs[i].role?.name.displayCase,
                // value: state.staffs[i].employeeRoles
                //     .where((e) =>
                //         e.businessId == businessId || e.businessId == null,
                //     )
                //     .map((e) => e.name)
                //     .join(', '),
              ),
              'email': PlutoCell(value: state.staffs[i].email),
              'phone': PlutoCell(value: state.staffs[i].phone ?? ''),
              'actions': PlutoCell(value: state.staffs[i]),
            },
          ),
      ],
    );
    state.stateManager?.refRows.clear();
    state.stateManager?.refRows.addAll(rows);
    state.stateManager?.setShowLoading(false);
  }

  Future<void> createEmployee(Map<String, dynamic> user) async {
    try {
      state = state.copyWith(status: EmployeeStatus.loading);
      await _staffRepository.createEmployee(user);
      state = state.copyWith(status: EmployeeStatus.success);
      setFilter(pageNumber: 1);
      Alert.showSnackBar(
        AppRouter.l10n.userCreatedSuccessfully,
        type: SnackBarType.success,
      );
    } catch (e) {
      state = state.copyWith(status: EmployeeStatus.error, error: e.toString());
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<void> updateEmployeeBranchAccess(String employeeId) async {
    try {
      state = state.copyWith(status: EmployeeStatus.loading);
      await _staffRepository.updateEmployeeBranchAccess(employeeId);
      state = state.copyWith(status: EmployeeStatus.success);
      setFilter(pageNumber: 1);
      Alert.showSnackBar(
        AppRouter.l10n.userCreatedSuccessfully,
        type: SnackBarType.success,
      );
    } catch (e) {
      state = state.copyWith(status: EmployeeStatus.error, error: e.toString());
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<void> resetEmployeePassword(String email) async {
    try {
      state = state.copyWith(status: EmployeeStatus.loading);
      await _staffRepository.resetEmployeePassword(email);
      state = state.copyWith(status: EmployeeStatus.success);
      Alert.showSnackBar(
        AppRouter.l10n.resetPasswordLinkSentSuccessfullyToYourEmail,
        type: SnackBarType.success,
      );
    } catch (e) {
      state = state.copyWith(status: EmployeeStatus.error, error: e.toString());
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<void> removeEmployeeBranchAccess(String employeeId) async {
    try {
      state = state.copyWith(status: EmployeeStatus.loading);
      await _staffRepository.removeEmployeeBranchAccess(employeeId);
      state = state.copyWith(status: EmployeeStatus.success);
      setFilter(pageNumber: 1);
      Alert.showSnackBar(
        AppRouter.l10n.userAccessRevokedSuccessfully,
        type: SnackBarType.success,
      );
    } catch (e) {
      state = state.copyWith(status: EmployeeStatus.error, error: e.toString());
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<void> deleteEmployee(String employeeId) async {
    try {
      state = state.copyWith(status: EmployeeStatus.loading);
      await _staffRepository.deleteEmployee(employeeId);
      state = state.copyWith(status: EmployeeStatus.success);
      setFilter(pageNumber: 1);
      Alert.showSnackBar(AppRouter.l10n.userDeletedSuccessfully);
    } catch (e) {
      state = state.copyWith(status: EmployeeStatus.error, error: e.toString());
      final errorStr = e.toString();
      if (errorStr.contains('Outstanding balance')) {
        Alert.showSnackBar(
          AppRouter.l10n
              .unableToDeleteThisCustomerThereAreTransactionsWithThisCustomerPleaseSettleOrWriteOffTheBalanceFirst,
          type: SnackBarType.error,
        );
      } else {
        Alert.showSnackBar(AppRouter.l10n.unableToDeleteThisCustomer,
            type: SnackBarType.error,);
      }
    }
  }

  Future<void> updateEmployee(Map<String, dynamic> employee) async {
    try {
      state = state.copyWith(status: EmployeeStatus.loading);
      await _staffRepository.updateEmployee(employee);
      state = state.copyWith(status: EmployeeStatus.success);
      setFilter(pageNumber: 1);
      Alert.showSnackBar(
        AppRouter.l10n.employeeUpdatedSuccessfully,
        type: SnackBarType.success,
      );
    } catch (e) {
      state = state.copyWith(status: EmployeeStatus.error, error: e.toString());
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
    }
  }
}
