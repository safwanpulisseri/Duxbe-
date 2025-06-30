import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';

class SingleStockAdjustScreenWeb extends ConsumerStatefulWidget {
  const SingleStockAdjustScreenWeb({super.key, this.item});
  final Item? item;
  @override
  ConsumerState<SingleStockAdjustScreenWeb> createState() => _SingleStockAdjustScreenWebState();
}

class _SingleStockAdjustScreenWebState extends ConsumerState<SingleStockAdjustScreenWeb> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final manageStockNotifier = ref.watch(manageStockNotifierProvider.notifier);
    final manageStockState = ref.watch(manageStockNotifierProvider);

    return FormBuilder(
      key: _formKey,
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: AppStyles.boxDecoration,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppTextForm<String>(
                        name: 'reference_number',
                        validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                        label: context.l10n.referenceNumber,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: AppTypeAheadForm<String>(
                        name: 'reason',
                        label: context.l10n.reason,
                        // Return reasons for stock adjustment
                        suggestionsCallback: (search) => ['Damaged', 'Expired', 'Lost', 'Stolen', 'Adjusted', 'Other']
                            .where((reason) => reason.toLowerCase().contains(search.toLowerCase()))
                            .toList(),
                        itemBuilder: (context, suggestion) => ListTile(title: Text(suggestion)),
                        validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: AppDateTimeForm(
                        initialValue: DateTime.now(),
                        name: 'adjusted_date',
                        validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                        label: context.l10n.date,
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Spacer(),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: AppStyles.boxDecoration,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.l10n.quantityAvailable, style: AppText.largeSB),
                          const SizedBox(height: 4),
                          Text(
                            context.l10n.currentQuantityBasedOnBillsAndInvoices,
                            style: AppText.largeN.copyWith(color: AppColors.outlineGrey),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: AppTextForm<double>(
                        initialValue: widget.item!.stockQuantity,
                        suffixIcon: Text(' ${widget.item?.unit?.shortName ?? widget.item?.unit?.name ?? ''}'),
                        enabled: false,
                        name: 'current_quantity',
                        validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text(context.l10n.newQuantityOnHand, style: AppText.largeSB),
                    ),
                    Expanded(
                      child: AppTextForm<double>(
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
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text(context.l10n.quantityAdjusted, style: AppText.largeSB),
                    ),
                    Expanded(
                      child: AppTextForm<double>(
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
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text(context.l10n.unitPrice, style: AppText.largeSB),
                    ),
                    Expanded(
                      child: AppTextForm<double>(
                        name: 'unit_price',
                        hintText: 'Eg: 1000',
                        initialValue: widget.item?.purchasePrice,
                        validator: FormBuilderValidators.compose(
                          [FormBuilderValidators.required(), FormBuilderValidators.notZeroNumber()],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton(
                style: ButtonStyles.secondary,
                onPress: context.pop,
                label: Text(context.l10n.cancel),
              ),
              const SizedBox(width: 12),
              AppButton(
                padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
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
                            'unit_price': value['unit_price'],
                            'item_id': widget.item!.itemId,
                          },
                        ],
                      };
                      manageStockNotifier.adjustStock(formData).then(AppRouter.pop);
                    }
                  }
                },
                label: Text(context.l10n.save),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
