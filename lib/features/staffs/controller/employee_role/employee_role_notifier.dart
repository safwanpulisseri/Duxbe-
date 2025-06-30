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

part 'employee_role_notifier.freezed.dart';
part 'employee_role_notifier.g.dart';
part 'employee_role_state.dart';

@riverpod
Future<StaffRole?> employeeRole(
  EmployeeRoleRef ref,
  String? staffRoleId,
) async =>
    staffRoleId == null ? null : ref.watch(staffRolesRepoProvider).getStaffRoleWithId(staffRoleId: staffRoleId);

@Riverpod(keepAlive: false)
class EmployeeRoleNotifier extends _$EmployeeRoleNotifier {
  late IStaffRolesRepository _staffRoleRepository;

  @override
  EmployeeRoleState build() {
    _staffRoleRepository = ref.watch(staffRolesRepoProvider);
    // Watch for business changes
    ref.listen(businessNotifierProvider, (previous, next) {
      // Refresh the paging controller when business changes
      setFilter(pageNumber: 1);
    });

    state = const EmployeeRoleState();
    // This is to set infinte scrolling in mobile devices
    return state.copyWith(
      pagingController: PagingController<int, StaffRole>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener(
          (pageKey) async {
            final staffRoles = await getStaffRoles(pageNumber: pageKey);
            final isLastPage = staffRoles.data.length < state.pageSize;
            if (isLastPage) {
              state.pagingController!.appendLastPage(staffRoles.data);
            } else {
              final nextPageKey = pageKey + 1;
              state.pagingController!.appendPage(staffRoles.data, nextPageKey);
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
  }) {
    state = state.copyWith(
      query: query ?? state.query,
      pageSize: pageSize ?? state.pageSize,
      pageNumber: pageNumber ?? state.pageNumber,
    );
    state.pagingController?.refresh();
    setTable();
  }

  Future<PaginatedResponse<StaffRole>> getStaffRoles({
    String? query,
    int? pageSize,
    int? pageNumber,
  }) async {
    try {
      final staffRoles = await _staffRoleRepository.getStaffRoles(
        query: query ?? state.query,
        pageSize: pageSize ?? state.pageSize,
        pageNumber: pageNumber ?? state.pageNumber,
      );
      return staffRoles;
    } catch (e) {
      state = state.copyWith(
        status: EmployeeRoleStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  final List<PlutoColumn> staffRoleColumns = <PlutoColumn>[
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
      title: AppRouter.l10n.role,
      field: 'role',
      titleSpan: TextSpan(
        text: AppRouter.l10n.role,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    // PlutoColumn(
    //   title: 'Description',
    //   field: 'description',
    //   titleSpan: TextSpan(
    //     text: AppRouter.l10n.description,
    //     style: AppText.largeSB.copyWith(color: AppColors.primaryColor)
    //   ),
    //   type: PlutoColumnType.text(),
    //   backgroundColor: AppColors.tableHeaderColor,
    // ),
    PlutoColumn(
      titleTextAlign: PlutoColumnTextAlign.center,
        title: AppRouter.l10n.actions,
      field: 'actions',
      titleSpan: TextSpan(
        text: AppRouter.l10n.actions,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
      textAlign: PlutoColumnTextAlign.end,
      renderer: (rendererContext) {
        final staffRole = rendererContext.cell.value as StaffRole;
        return !staffRole.editable
            ? const SizedBox()
            : Align(
                child: MenuAnchor(
                  builder: (context, controller, child) {
                    return IconButton(
                      onPressed: controller.isOpen ? controller.close : controller.open,
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
                        AppRouter.pushNamed(
                          AppRouter.userRoleDetails,
                          pathParameters: {'id': staffRole.employeeRoleId!},
                        );
                      },
                      child: Text(AppRouter.l10n.edit),
                    ),
                    MenuItemButton(
                      leadingIcon: Assets.icons.delete.svg(width: 20),
                      onPressed: () {
                        showDialog<void>(
                          context: AppRouter.rootContext,
                          builder: (context) {
                            return ConfirmationDialog(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              title: AppRouter.l10n.deleteUserRole,
                              children: [
                                Text(
                                  context.l10n.areYouSureYouWantToDeleteThisUserRole,
                                  style: AppText.mediumN.copyWith(color: AppColors.primaryColor),
                                ),
                              ],
                              onPositive: (ref) {
                                ref
                                    .read(employeeRoleNotifierProvider.notifier)
                                    .deleteStaffRole(staffRole.employeeRoleId!);
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
    ),
  ];

  Future<void> setTable() async {
    if (state.stateManager == null) return;
    state.stateManager?.setShowLoading(true);
    state = state.copyWith(status: EmployeeRoleStatus.loading);
    final employees = await getStaffRoles();
    state = state.copyWith(
      status: EmployeeRoleStatus.success,
      staffRoles: employees.data,
      count: employees.count,
    );

    final baseIndex = (state.pageNumber - 1) * state.pageSize + 1;
    final rows = await PlutoGridStateManager.initializeRowsAsync(
      staffRoleColumns,
      [
        for (int i = 0; i < state.staffRoles.length; i++)
          PlutoRow(
            cells: {
              'sl_no': PlutoCell(value: baseIndex + i),
              'role': PlutoCell(value: state.staffRoles[i].name),
              // 'description':
              //     PlutoCell(value: state.staffRoles[i].description ?? ''),
              'actions': PlutoCell(value: state.staffRoles[i]),
            },
          ),
      ],
    );
    state.stateManager?.refRows.clear();
    state.stateManager?.refRows.addAll(rows);
    state.stateManager?.setShowLoading(false);
  }

  Future<void> deleteStaffRole(String staffRoleId) async {
    try {
      state = state.copyWith(status: EmployeeRoleStatus.loading);
      await _staffRoleRepository.deleteStaffRole(staffRoleId);
      state = state.copyWith(status: EmployeeRoleStatus.success);
      setFilter(pageNumber: 1);
      Alert.showSnackBar(
        AppRouter.l10n.employeeRoleDeletedSuccessfully,
        type: SnackBarType.success,
      );
    } catch (e) {
      state = state.copyWith(
        status: EmployeeRoleStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }
}
