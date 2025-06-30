part of './tax_settings_web.dart';

class AddTaxDialog extends ConsumerStatefulWidget {
  const AddTaxDialog({super.key, this.tax});
  final Tax? tax;
  @override
  ConsumerState<AddTaxDialog> createState() => _AddTaxDialogState();
}

class _AddTaxDialogState extends ConsumerState<AddTaxDialog> {
  final _taxFormKey = GlobalKey<FormBuilderState>();
  void _createTax() {
    final business = ref.read(branchProvider)!;
    try {
      if (_taxFormKey.currentState?.saveAndValidate() ?? false) {
        ref
            .read(taxNotifierProvider(business.businessId).notifier)
            .upsertTax(
              Tax.fromJson(_taxFormKey.currentState!.value).copyWith(
                taxId: widget.tax?.taxId,
              ),
            )
            .then((value) {
          if (mounted) {
            context.pop();
          }
        });
      }
    } catch (e) {
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final businessId = ref.read(businessNotifierProvider)!.businessId;
    return FormAddDialog(
      isLoading: ref.watch(taxNotifierProvider(businessId)).status == TaxStatus.loading,
      title: context.l10n.addTax,
      formKey: _taxFormKey,
      onPositive: _createTax,
      children: [
        Row(
          children: [
            Expanded(
              child: AppTextForm<String>(
                label: context.l10n.taxName,
                name: 'name',
                validator: FormBuilderValidators.required(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: AppTextForm<double>(
                label: context.l10n.rate,
                name: 'rate',
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.max(100),
                  FormBuilderValidators.min(1),
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
                label: context.l10n.type,
                name: 'type',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
