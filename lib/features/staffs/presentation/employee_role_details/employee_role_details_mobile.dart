import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/staffs/staffs.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';

class EmployeeRoleDetailsScreenMobile extends ConsumerStatefulWidget {
  const EmployeeRoleDetailsScreenMobile({super.key, this.employeeRole});
  final StaffRole? employeeRole;
  @override
  ConsumerState<EmployeeRoleDetailsScreenMobile> createState() => _EmployeeRoleDetailsScreenMobileState();
}

class _EmployeeRoleDetailsScreenMobileState extends ConsumerState<EmployeeRoleDetailsScreenMobile> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _debouncer = Debouncer(milliseconds: 500);

  CheckBoxState getCheckBoxState(Permissions permissions) {
    final allTrue = permissions.view && permissions.edit && permissions.add && permissions.delete && permissions.print;
    final allFalse =
        !permissions.view && !permissions.edit && !permissions.add && !permissions.delete && !permissions.print;

    if (allTrue) return CheckBoxState.checked;
    if (allFalse) return CheckBoxState.unchecked;
    return CheckBoxState.indeterminate;
  }

  bool? checkState(CheckBoxState t) => switch (t) {
        CheckBoxState.checked => true,
        CheckBoxState.unchecked => false,
        CheckBoxState.indeterminate => null,
      };

  CheckBoxState getCheckBoxStateForAllModules() {
    final staffRoleDetailsState = ref.watch(
      employeeRoleDetailsNotifierProvider(role: widget.employeeRole),
    );

    final allTrue = staffRoleDetailsState.modules.every(
      (element) =>
          getCheckBoxState(element.permissions) == CheckBoxState.checked &&
          element.submenus.every(
            (element) => getCheckBoxState(element.permissions) == CheckBoxState.checked,
          ),
    );

    final allFalse = staffRoleDetailsState.modules.every(
      (element) =>
          getCheckBoxState(element.permissions) == CheckBoxState.unchecked &&
          element.submenus.every(
            (element) => getCheckBoxState(element.permissions) == CheckBoxState.unchecked,
          ),
    );
    if (allTrue) return CheckBoxState.checked;
    if (allFalse) return CheckBoxState.unchecked;
    return CheckBoxState.indeterminate;
  }

  // ignore: avoid_positional_boolean_parameters
  void updatePermissions(Permissions permissions, bool value) {
    permissions
      ..view = value
      ..edit = value
      ..add = value
      ..delete = value
      ..print = value;
  }

  @override
  Widget build(BuildContext context) {
    final staffRoleDetailsState = ref.watch(
      employeeRoleDetailsNotifierProvider(role: widget.employeeRole),
    );
    final employeeRoleDetailsNotifier = ref.watch(
      employeeRoleDetailsNotifierProvider(role: widget.employeeRole).notifier,
    );

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(context.l10n.userRole),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.viewPaddingOf(context).bottom == 0 ? 24 : MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppButton(
              onPress: () {
                final name = _formKey.currentState!.fields['name']!;
                if (name.validate()) {
                  employeeRoleDetailsNotifier
                      .saveRole(roleName: name.value.toString())
                      .then((value) => AppRouter.pop());
                }
              },
              isLoading: staffRoleDetailsState.status == EmployeeRoleDetailsStatus.loading,
              label: Text(context.l10n.save),
            ),
            const SizedBox(height: 12),
            AppButton(
              style: ButtonStyles.secondary,
              onPress: () => context.pop(),
              label: Text(context.l10n.cancel),
            ),
          ],
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: AppStyles.boxDecoration,
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextForm<String>(
                name: 'name',
                label: context.l10n.userRoleName,
                initialValue: widget.employeeRole?.name,
                onChanged: (staffRoleName) {
                  if (staffRoleName == null) return;
                  _debouncer.run(
                    () async {
                      final isUniqueName = await ref.read(staffRolesRepoProvider).checkUniqueEmployeeRoleName(
                            employeeRoleName: staffRoleName,
                          );
                      if (!isUniqueName || staffRoleName == 'Admin') {
                        _formKey.currentState!.fields['name']!.invalidate(
                          AppRouter.l10n.roleNameIsAlreadyUsed,
                        );
                      } else {
                        _formKey.currentState!.fields['name']!.validate();
                      }
                    },
                  );
                },
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: [
                    _buildHeaderRow(),
                    const SizedBox(height: 14),
                    ...staffRoleDetailsState.modules.map(_buildModuleSection),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    final staffRoleDetailsState = ref.watch(
      employeeRoleDetailsNotifierProvider(role: widget.employeeRole),
    );
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      borderOnForeground: false,
      child: CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        side: WidgetStateBorderSide.resolveWith(
          (states) => const BorderSide(color: AppColors.primaryColor),
        ),
        activeColor: AppColors.primaryColor,
        onChanged: (v) {
          for (final module in staffRoleDetailsState.modules) {
            updatePermissions(module.permissions, v ?? false);
            for (final subMenu in module.submenus) {
              updatePermissions(subMenu.permissions, v ?? false);
            }
          }
          setState(() {});
        },
        controlAffinity: ListTileControlAffinity.leading,
        tristate: true,
        tileColor: AppColors.tableHeaderColor,
        value: checkState(getCheckBoxStateForAllModules()),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            context.l10n.view.toUpperCase(),
            context.l10n.add.toUpperCase(),
            context.l10n.edit.toUpperCase(),
            context.l10n.delete.toUpperCase(),
            context.l10n.print.toUpperCase(),
          ]
              .asMap()
              .entries
              .map(
                (e) => SizedBox(
                  width: 46,
                  child: Text(
                    e.value,
                    style: AppText.largeN.copyWith(
                      color: AppColors.primaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: e.key == 0 ? TextAlign.start : TextAlign.center,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildModuleSection(Module module) {
    final moduleCheckboxState = getCheckBoxState(module.permissions);
    final allSubmenusChecked = module.submenus.every(
      (submenu) => getCheckBoxState(submenu.permissions) == CheckBoxState.checked,
    );
    final allSubmenusUnChecked = module.submenus.every(
      (submenu) => getCheckBoxState(submenu.permissions) == CheckBoxState.unchecked,
    );

    return Column(
      children: [
        _buildModuleRow(
          module,
          moduleCheckboxState == CheckBoxState.checked && allSubmenusChecked
              ? CheckBoxState.checked
              : moduleCheckboxState == CheckBoxState.unchecked && allSubmenusUnChecked
                  ? CheckBoxState.unchecked
                  : CheckBoxState.indeterminate,
        ),
        ...module.submenus.map(_buildSubmenuRow),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildModuleRow(Module module, CheckBoxState isChecked) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      borderOnForeground: false,
      child: CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        side: WidgetStateBorderSide.resolveWith(
          (states) => const BorderSide(color: AppColors.primaryColor),
        ),
        activeColor: AppColors.primaryColor,
        onChanged: (v) {
          updatePermissions(module.permissions, v ?? false);
          for (final submenu in module.submenus) {
            updatePermissions(submenu.permissions, v ?? false);
          }
          setState(() {});
        },
        controlAffinity: ListTileControlAffinity.leading,
        tileColor: AppColors.tableHeaderColor,
        value: checkState(isChecked),
        tristate: true,
        title: Row(
          children: [
            Expanded(
              child: Text(
                module.name,
                style: AppText.largeN.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            ),
            ..._buildModulePermissionCheckboxes(module),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmenuRow(Submenu submenu) {
    final checkBoxState = getCheckBoxState(submenu.permissions);
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      side: WidgetStateBorderSide.resolveWith(
        (states) => const BorderSide(color: AppColors.primaryColor),
      ),
      activeColor: AppColors.primaryColor,
      controlAffinity: ListTileControlAffinity.leading,
      value: checkState(checkBoxState),
      tristate: true,
      onChanged: (v) {
        updatePermissions(submenu.permissions, v ?? false);
        setState(() {});
      },
      title: Row(
        children: [
          Expanded(
            child: Text(
              submenu.linkName,
              style: AppText.largeN.copyWith(
                color: AppColors.primaryColor,
              ),
            ),
          ),
          ..._buildPermissionCheckboxes(submenu.permissions),
        ],
      ),
    );
  }

  List<Widget> _buildPermissionCheckboxes(Permissions permissions) {
    return [
      context.l10n.view.toUpperCase(),
      context.l10n.add.toUpperCase(),
      context.l10n.edit.toUpperCase(),
      context.l10n.delete.toUpperCase(),
      context.l10n.print.toUpperCase(),
    ]
        .map(
          (e) => Checkbox(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            side: WidgetStateBorderSide.resolveWith(
              (states) => const BorderSide(color: AppColors.primaryColor),
            ),
            activeColor: AppColors.primaryColor,
            value: switch (e) {
              'VIEW' => permissions.view,
              'ADD' => permissions.add,
              'EDIT' => permissions.edit,
              'DELETE' => permissions.delete,
              'PRINT' => permissions.print,
              _ => false,
            },
            onChanged: (v) {
              switch (e) {
                case 'VIEW':
                  permissions.view = v ?? false;
                case 'ADD':
                  permissions.add = v ?? false;
                case 'EDIT':
                  permissions.edit = v ?? false;
                case 'DELETE':
                  permissions.delete = v ?? false;
                case 'PRINT':
                  permissions.print = v ?? false;
              }
              setState(() {});
            },
          ),
        )
        .toList();
  }

  bool? _computeCheckboxState(
    bool modulePermission,
    List<Submenu> submenus,
    bool Function(Permissions) permissionCheck,
  ) {
    final allChecked = modulePermission && submenus.every((submenu) => permissionCheck(submenu.permissions));
    final allUnchecked = !modulePermission && submenus.every((submenu) => !permissionCheck(submenu.permissions));
    return allChecked
        ? true
        : allUnchecked
            ? false
            : null;
  }

  List<Widget> _buildModulePermissionCheckboxes(Module module) {
    final checkboxStates = {
      'VIEW': _computeCheckboxState(
        module.permissions.view,
        module.submenus,
        (perm) => perm.view,
      ),
      'ADD': _computeCheckboxState(
        module.permissions.add,
        module.submenus,
        (perm) => perm.add,
      ),
      'EDIT': _computeCheckboxState(
        module.permissions.edit,
        module.submenus,
        (perm) => perm.edit,
      ),
      'DELETE': _computeCheckboxState(
        module.permissions.delete,
        module.submenus,
        (perm) => perm.delete,
      ),
      'PRINT': _computeCheckboxState(
        module.permissions.print,
        module.submenus,
        (perm) => perm.print,
      ),
    };

    return checkboxStates.entries.map((entry) {
      final permissionType = entry.key;
      final isChecked = entry.value;

      return Checkbox(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        side: WidgetStateBorderSide.resolveWith(
          (states) => const BorderSide(color: AppColors.primaryColor),
        ),
        activeColor: AppColors.primaryColor,
        value: isChecked,
        tristate: true,
        onChanged: (bool? value) {
          setState(() {
            // Update module permissions based on the checkbox type
            switch (permissionType) {
              case 'VIEW':
                module.permissions.view = value ?? false;
              case 'ADD':
                module.permissions.add = value ?? false;
              case 'EDIT':
                module.permissions.edit = value ?? false;
              case 'DELETE':
                module.permissions.delete = value ?? false;
              case 'PRINT':
                module.permissions.print = value ?? false;
            }
            // Ensure that the submenus update accordingly
            for (final submenu in module.submenus) {
              switch (permissionType) {
                case 'VIEW':
                  submenu.permissions.view = value ?? false;
                case 'ADD':
                  submenu.permissions.add = value ?? false;
                case 'EDIT':
                  submenu.permissions.edit = value ?? false;
                case 'DELETE':
                  submenu.permissions.delete = value ?? false;
                case 'PRINT':
                  submenu.permissions.print = value ?? false;
              }
            }
          });
        },
      );
    }).toList();
  }
}
