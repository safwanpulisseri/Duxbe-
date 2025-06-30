import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/staffs/staffs.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

class EmployeeRoleListScreenWeb extends ConsumerStatefulWidget {
  const EmployeeRoleListScreenWeb({super.key});

  @override
  ConsumerState<EmployeeRoleListScreenWeb> createState() => _EmployeeRoleListScreenWebState();
}

class _EmployeeRoleListScreenWebState extends ConsumerState<EmployeeRoleListScreenWeb> {
  final debouncer = Debouncer(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    final employeeRoleNotifier = ref.watch(employeeRoleNotifierProvider.notifier);
    final employeeRoleState = ref.watch(employeeRoleNotifierProvider);
    return switch (ref.watch(authNotifierProvider).status) {
      AuthStatus.success => Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: AppStyles.boxDecoration,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: AppTextForm<String>(
                      name: 'user_role_search',
                      hintText: context.l10n.enterRoleName,
                      onChanged: (val) {
                        debouncer.run(() {
                          employeeRoleNotifier.setFilter(
                            query: val ?? '',
                          );
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  AppButton.icon(
                    padding: const EdgeInsets.all(16),
                    onPress: () {
                      context.pushNamed(AppRouter.createUserRole);
                    },
                    label: Text(context.l10n.addUserRole),
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
                        columns: employeeRoleNotifier.staffRoleColumns,
                        // ignore: prefer_const_literals_to_create_immutables
                        rows: [],
                        onLoaded: (PlutoGridOnLoadedEvent event) {
                          employeeRoleNotifier.setStateManager(
                            stateManager: event.stateManager,
                          );
                        },
                        configuration: AppStylesX.dataTableConfig,
                        noRowsWidget: const NoDataViewWidget(),
                      ),
                    ),
                    PaginationFooter(
                      onPageChanged: (value) {
                        employeeRoleNotifier.setFilter(
                          pageNumber: value,
                        );
                      },
                      totalPages: (employeeRoleState.count / employeeRoleState.pageSize).ceil(),
                      currentPage: employeeRoleState.pageNumber,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      _ => const SizedBox(),
    };
  }
}
