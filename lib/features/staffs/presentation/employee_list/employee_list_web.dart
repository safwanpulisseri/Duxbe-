import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/organization/organization.dart';
import 'package:duxbe/features/staffs/staffs.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

part 'widgets/add_employee_dialog.dart';

class EmployeeListScreenWeb extends ConsumerStatefulWidget {
  const EmployeeListScreenWeb({super.key});

  @override
  ConsumerState<EmployeeListScreenWeb> createState() => _EmployeeListScreenWebState();
}

class _EmployeeListScreenWebState extends ConsumerState<EmployeeListScreenWeb> {
  final debouncer = Debouncer(milliseconds: 500);
  @override
  Widget build(BuildContext context) {
    final staffListNotifier = ref.watch(employeeNotifierProvider.notifier);
    final staffListState = ref.watch(employeeNotifierProvider);
    final organizationState = ref.watch(organizationNotifierProvider);

    return switch (ref.watch(authNotifierProvider).status) {
      AuthStatus.success => Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: AppStyles.boxDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: AppTextForm<String>(
                      name: 'employee_search',
                      hintText: context.l10n.search,
                      onChanged: (val) {
                        debouncer.run(() {
                          staffListNotifier.setFilter(query: val ?? '');
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  AppButton.icon(
                    padding: const EdgeInsets.all(16),
                    onPress: () {
                      final usersCountThreshold =
                          organizationState?.activeAddonsList?.fold(0, (previousValue, element) {
                                final usersAddonCount = element.addonId == 1 ? 1 : 0;
                                final branchUserAddonCount = element.addonId == 2 ? 3 : 0;
                                return previousValue + usersAddonCount + branchUserAddonCount;
                              }) ??
                              0;
                      if (usersCountThreshold <= staffListState.count) {
                        showDialog<void>(
                          context: context,
                          builder: (context) => const AddEmployeeDialog(),
                        );
                      } else {
                        Alert.showSnackBar(context.l10n.youHaveReachedTheMaximumNumberOfEmployees);
                      }
                    },
                    label: Text(context.l10n.addUser),
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
                        columns: staffListNotifier.userListColumns,
                        // ignore: prefer_const_literals_to_create_immutables
                        rows: [],
                        onLoaded: (PlutoGridOnLoadedEvent event) {
                          staffListNotifier.setStateManager(
                            stateManager: event.stateManager,
                          );
                        },
                        configuration: AppStylesX.dataTableConfig,
                        noRowsWidget: const NoDataViewWidget(),
                      ),
                    ),
                    PaginationFooter(
                      onPageChanged: (value) {
                        staffListNotifier.setFilter(pageNumber: value);
                      },
                      totalPages: (staffListState.count / staffListState.pageSize).ceil(),
                      currentPage: staffListState.pageNumber,
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
