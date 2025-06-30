import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:phone_form_field/phone_form_field.dart';

class AddCustomerDialog extends ConsumerStatefulWidget {
  const AddCustomerDialog({super.key, this.customerName});
  final String? customerName;

  @override
  ConsumerState<AddCustomerDialog> createState() => _AddSuppllierDialogState();
}

class _AddSuppllierDialogState extends ConsumerState<AddCustomerDialog> {
  final _customerAddFormKey = GlobalKey<FormBuilderState>();
  Future<void> _createCustomer() async {
    try {
      if (_customerAddFormKey.currentState?.saveAndValidate() ?? false) {
        await ref
            .read(customerNotifierProvider.notifier)
            .upsertCustomer(
              Customer.fromJson(_customerAddFormKey.currentState!.value),
            )
            .then((value) {
          if (mounted) {
            context.pop(value);
          }
        });
      }
    } catch (e) {
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormAddDialog(
      title: context.l10n.addCustomer,
      formKey: _customerAddFormKey,
      onPositive: _createCustomer,
      isLoading: ref.watch(customerNotifierProvider).status == CustomerStatus.loading,
      children: [
        AppTextForm<String>(
          label: context.l10n.customerName,
          name: 'name',
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(
              errorText: context.l10n.pleaseEnterTheCustomerName,
            ),
          ]),
        ),
        const SizedBox(height: 16),
        AppPhoneNumberForm(
          label: context.l10n.phoneNo,
          name: 'phone',
          initialValue: ref.read(countryCodeProvider),
          mobileValidator: PhoneValidator.compose(
            [
              PhoneValidator.required(context),
              PhoneValidator.validMobile(context),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppTextForm<String>(
          label: context.l10n.email,
          name: 'email',
          validator: FormBuilderValidators.email(checkNullOrEmpty: false),
          inputFormatters: [LowerCaseTextFormatter()],
        ),
        const SizedBox(height: 16),
        AppTextForm<String>(
          label: context.l10n.address,
          minLines: 3,
          name: 'address',
        ),
      ],
    );
  }
}
