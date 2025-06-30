part of '../employee_list_web.dart';

class AddEmployeeDialog extends ConsumerStatefulWidget {
  const AddEmployeeDialog({super.key, this.employee});
  final EmployeeModel? employee;

  @override
  ConsumerState<AddEmployeeDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends ConsumerState<AddEmployeeDialog> {
  final _userAddFormKey = GlobalKey<FormBuilderState>();
  Future<void> _createUser() async {
    if (_userAddFormKey.currentState!.saveAndValidate()) {
      final value = _userAddFormKey.currentState!.value;
      if (widget.employee == null) {
        final employee = _userAddFormKey.currentState!.value['user'] as EmployeeModel?;
        if (employee != null) {
          await ref
              .read(employeeNotifierProvider.notifier)
              .updateEmployeeBranchAccess(employee.employeeId)
              .then((value) => AppRouter.pop());
          return;
        }
        await ref.read(employeeNotifierProvider.notifier).createEmployee(value).then((value) => AppRouter.pop());
      } else {
        await ref.read(employeeNotifierProvider.notifier).updateEmployee({
          'employee_id': widget.employee!.employeeId,
          ...value,
        }).then((value) => AppRouter.pop());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormAddDialog(
      title: widget.employee != null ? context.l10n.editUser : context.l10n.addUser,
      formKey: _userAddFormKey,
      isLoading: ref.watch(employeeNotifierProvider).isLoading,
      onPositive: _createUser,
      children: [
        if (widget.employee == null) ...[
          AppTypeAheadForm<EmployeeModel>(
            name: 'user',
            label: '${context.l10n.addExistingUserFromOtherBranch} *',
            onSuggestionSelected: (suggestion) {
              _userAddFormKey.currentState!.save();
              setState(() {});
            },
            suggestionsCallback: (pattern) async {
              return ref
                  .read(staffRepoProvider)
                  .getEmployees(pageSize: 30, pageNumber: 1, fromOtherBranch: true)
                  .then((value) => value.data);
            },
            itemBuilder: (context, item) {
              return ListTile(
                title: Text(item.name),
              );
            },
            selectionToTextTransformer: (item) => item.name,
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.orCreateNewUser,
            style: AppText.mediumB.copyWith(color: AppColors.primaryColor),
          ),
          const SizedBox(height: 16),
        ],
        AppTextForm<String>(
          name: 'name',
          label: context.l10n.userName,
          initialValue: widget.employee?.name,
          validator: FormBuilderValidators.compose([
            if (_userAddFormKey.currentState?.value['user'] == null)
              FormBuilderValidators.required(
                errorText: context.l10n.pleaseEnterTheUserName,
              ),
          ]),
        ),
        const SizedBox(height: 16),
        AppTextForm<String>(
          name: 'email',
          label: context.l10n.email,
          initialValue: widget.employee?.email,
          validator: FormBuilderValidators.compose([
            if (_userAddFormKey.currentState?.value['user'] == null) FormBuilderValidators.required(),
            FormBuilderValidators.email(checkNullOrEmpty: false),
          ]),
          inputFormatters: [LowerCaseTextFormatter()],
        ),
        const SizedBox(height: 16),
        AppPhoneNumberForm(
          name: 'phone',
          label: context.l10n.phoneNo,
          initialValue: widget.employee?.phone == null
              ? ref.read(countryCodeProvider)
              : PhoneNumber.parse(widget.employee?.phone ?? ''),
          mobileValidator: PhoneValidator.compose(
            [
              if (_userAddFormKey.currentState?.value['user'] == null) PhoneValidator.required(context),
              PhoneValidator.validMobile(context),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppMultiSelectDropdownForm<String>(
          name: 'roles',
          label: context.l10n.roles,
          future: () => ref.read(staffRolesRepoProvider).getStaffRoles(pageSize: 100, pageNumber: 1).then(
                (value) => value.data
                    .map(
                      (e) => DropdownItem(
                        value: e.employeeRoleId!,
                        label: e.name,
                        selected:
                            widget.employee?.employeeRoles.map((e) => e.roleId).contains(e.employeeRoleId) ?? false,
                      ),
                    )
                    .toList(),
              ),
        ),
        if (widget.employee != null) ...[
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () async {
                await ref
                    .read(employeeNotifierProvider.notifier)
                    .resetEmployeePassword(widget.employee!.email)
                    .then((value) => AppRouter.pop());
              },
              child: Text(context.l10n.resetPassword),
            ),
          ),
        ],
      ],
    );
  }
}
