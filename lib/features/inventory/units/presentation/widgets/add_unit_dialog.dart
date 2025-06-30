import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hancod_theme/hancod_theme.dart';

class AddUnitDialog extends ConsumerStatefulWidget {
  const AddUnitDialog({super.key, this.unit});
  final Unit? unit;
  @override
  ConsumerState<AddUnitDialog> createState() => _AddUnitDialogState();
}

class _AddUnitDialogState extends ConsumerState<AddUnitDialog> {
  final _unitFormKey = GlobalKey<FormBuilderState>();
  void _createUnit() {
    if (_unitFormKey.currentState?.saveAndValidate() ?? false) {
      ref
          .read(unitNotifierProvider.notifier)
          .upsertUnit(
            Unit.fromJson(_unitFormKey.currentState!.value).copyWith(unitId: widget.unit?.unitId),
          )
          .then(AppRouter.pop);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormAddDialog(
      formKey: _unitFormKey,
      title: context.l10n.addUnit,
      isLoading: ref.watch(unitNotifierProvider).isLoading,
      onPositive: _createUnit,
      children: [
        Row(
          children: [
            Expanded(
              child: AppTextForm<String>(
                label: AppRouter.l10n.unitName,
                initialValue: widget.unit?.name,
                name: 'name',
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: context.l10n.pleaseEnterTheUnitName,
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
                label: context.l10n.shortName,
                name: 'short_name',
                initialValue: widget.unit?.shortName,
                validator: FormBuilderValidators.required(
                  errorText: context.l10n.pleaseAddUnitShortName,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
