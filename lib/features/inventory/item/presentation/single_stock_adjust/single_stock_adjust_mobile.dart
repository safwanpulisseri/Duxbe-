import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hancod_theme/hancod_theme.dart';

class SingleStockAdjustScreenMobile extends ConsumerStatefulWidget {
  const SingleStockAdjustScreenMobile({super.key, this.item});
  final Item? item;
  @override
  ConsumerState<SingleStockAdjustScreenMobile> createState() => _SingleStockAdjustScreenMobileState();
}

class _SingleStockAdjustScreenMobileState extends ConsumerState<SingleStockAdjustScreenMobile> {
  final _formKey = GlobalKey<FormBuilderState>();
  @override
  Widget build(BuildContext context) {
    final manageStockNotifier = ref.watch(manageStockNotifierProvider.notifier);
    final manageStockState = ref.watch(manageStockNotifierProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(context.l10n.stockAdjustment),
      ),
      body: SafeArea(
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  children: [
                    AppTextForm<String>(
                      name: 'reference_number',
                      validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                      label: context.l10n.referenceNumber,
                    ),
                    const SizedBox(height: 12),
                    AppTypeAheadForm<String>(
                      name: 'reason',
                      label: context.l10n.reason,
                      // Return reasons for stock adjustment
                      suggestionsCallback: (search) => [
                        'Damaged',
                        'Expired',
                        'Lost',
                        'Stolen',
                        'Stock Adjustment',
                        'Other',
                      ].where((reason) => reason.toLowerCase().contains(search.toLowerCase())).toList(),
                      itemBuilder: (context, suggestion) => ListTile(title: Text(suggestion)),
                      validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                    ),
                    const SizedBox(height: 12),
                    AppDateTimeForm(
                      name: 'adjusted_date',
                      initialValue: DateTime.now(),
                      validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                      label: context.l10n.date,
                    ),
                    const SizedBox(height: 12),
                    AppTextForm<double>(
                      label: context.l10n.quantityAvailable,
                      initialValue: widget.item!.stockQuantity,
                      suffixIcon: Text(' ${widget.item?.unit?.shortName ?? widget.item?.unit?.name ?? ''}'),
                      enabled: false,
                      name: 'current_quantity',
                      validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                    ),
                    const SizedBox(height: 12),
                    AppTextForm<double>(
                      label: context.l10n.newQuantityOnHand,
                      onFocusLose: (newQuantity) {
                        _formKey.currentState?.fields['new_quantity']?.validate();
                        if (newQuantity != null) {
                          _formKey.currentState?.fields['adjusted_quantity']
                              ?.didChange((newQuantity - widget.item!.stockQuantity).toString());
                          setState(() {});
                        }
                      },
                      name: 'new_quantity',
                      initialValue: 0,
                      validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                    ),
                    const SizedBox(height: 12),
                    AppTextForm<double>(
                      label: context.l10n.quantityAdjusted,
                      name: 'adjusted_quantity',
                      onFocusLose: (adjustedQuantity) {
                        _formKey.currentState?.fields['adjusted_quantity']?.validate();
                        if (adjustedQuantity != null) {
                          _formKey.currentState?.fields['new_quantity']
                              ?.didChange((widget.item!.stockQuantity + adjustedQuantity).toString());
                          setState(() {});
                        }
                      },
                      hintText: 'Eg: +10, -10',
                      validator: FormBuilderValidators.compose(
                        [FormBuilderValidators.required(), FormBuilderValidators.notZeroNumber()],
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppTextForm<double>(
                      label: context.l10n.unitPrice,
                      name: 'unit_price',
                      hintText: 'Eg: 1000',
                      validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: AppButton(
                  isLoading: manageStockState.status == ManageStockStatus.loading,
                  onPress: () {
                    if (_formKey.currentState?.saveAndValidate() ?? false) {
                      if (_formKey.currentState?.saveAndValidate() ?? false) {
                        final value = Map<String, dynamic>.from(_formKey.currentState!.value);

                        final formData = {
                          'reference_number': value['reference_number'],
                          'reason': value['reason'],
                          'adjusted_date': (value['adjusted_date'] as DateTime).toIso8601String(),
                          'adjusted_items': [
                            {
                              'current_quantity': value['current_quantity'],
                              'new_quantity': value['new_quantity'],
                              'adjusted_quantity': value['adjusted_quantity'],
                              'item_id': widget.item!.itemId,
                              'unit_price': value['unit_price'],
                            },
                          ],
                        };
                        manageStockNotifier.adjustStock(formData).then(AppRouter.pop);
                      }
                    }
                  },
                  label: Text(context.l10n.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
