import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hancod_theme/hancod_theme.dart';

class AddBrandDialog extends ConsumerStatefulWidget {
  const AddBrandDialog({super.key, this.brand});
  final Brand? brand;
  @override
  ConsumerState<AddBrandDialog> createState() => _AddBrandDialogState();
}

class _AddBrandDialogState extends ConsumerState<AddBrandDialog> {
  final _brandFormKey = GlobalKey<FormBuilderState>();

  void _createBrand() {
    if (_brandFormKey.currentState?.saveAndValidate() ?? false) {
      ref
          .read(brandNotifierProvider.notifier)
          .upsertBrand(
            Brand.fromJson(_brandFormKey.currentState!.value).copyWith(brandId: widget.brand?.brandId),
          )
          .then(AppRouter.pop);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormAddDialog(
      title: context.l10n.addBrand,
      formKey: _brandFormKey,
      onPositive: _createBrand,
      isLoading: ref.watch(brandNotifierProvider).isLoading,
      children: [
        Row(
          children: [
            Expanded(
              child: AppTextForm(
                label: AppRouter.l10n.brandName,
                initialValue: widget.brand?.name,
                name: 'name',
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required<String>(
                    errorText: context.l10n.pleaseEnterTheBrandName,
                  ),
                ]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: AppTextForm<String>(
                initialValue: widget.brand?.description,
                minLines: 5,
                label: AppRouter.l10n.description,
                name: 'description',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
