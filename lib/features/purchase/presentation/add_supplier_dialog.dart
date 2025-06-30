import 'package:duxbe/features/purchase/purchase.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:phone_form_field/phone_form_field.dart';

class AddSupplierDialog extends ConsumerStatefulWidget {
  const AddSupplierDialog({super.key, this.supplierName});
  final String? supplierName;

  @override
  ConsumerState<AddSupplierDialog> createState() => _AddSuppllierDialogState();
}

class _AddSuppllierDialogState extends ConsumerState<AddSupplierDialog> {
  final _supplierAddFormKey = GlobalKey<FormBuilderState>();
  Future<void> _createSupplier() async {
    try {
      if (_supplierAddFormKey.currentState?.saveAndValidate() ?? false) {
        await ref
            .read(supplierNotifierProvider.notifier)
            .upsertSupplier(
              Supplier.fromJson(_supplierAddFormKey.currentState!.value),
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
      title: context.l10n.addSupplier,
      formKey: _supplierAddFormKey,
      onPositive: _createSupplier,
      isLoading: ref.watch(supplierNotifierProvider).status == SupplierStatus.loading,
      children: [
        AppTextForm<String>(
          label: context.l10n.supplierName,
          initialValue: widget.supplierName,
          name: 'name',
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(
              errorText: context.l10n.pleaseEnterTheSupplierName,
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
          validator: FormBuilderValidators.email(),
          inputFormatters: [LowerCaseTextFormatter()],
        ),
        const SizedBox(height: 16),
        AppTextForm<String>(
          label: context.l10n.address,
          minLines: 3,
          name: 'address',
        ),
        const SizedBox(height: 16),
        AppTextForm<double>(
          label: context.l10n.openingBalance,
          name: 'opening_balance',
        ),
        const SizedBox(height: 16),
        AppTextForm<String>(
          label: context.l10n.gstNumber,
          name: 'gst_number',
        ),
      ],
    );
  }
}
