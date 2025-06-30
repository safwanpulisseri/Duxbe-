import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';

class MultiStockAdjustment {
  MultiStockAdjustment({
    required this.item,
    required this.currentQuantity,
    required this.newQuantity,
    required this.adjustedQuantity,
    required this.unitPrice,
  });
  final Item item;
  final double currentQuantity;
  final double newQuantity;
  final double adjustedQuantity;
  final double unitPrice;
}

class MultiStockAdjustScreenMobile extends ConsumerStatefulWidget {
  const MultiStockAdjustScreenMobile({super.key});

  @override
  ConsumerState<MultiStockAdjustScreenMobile> createState() => _MultiStockAdjustScreenMobileState();
}

class _MultiStockAdjustScreenMobileState extends ConsumerState<MultiStockAdjustScreenMobile> {
  final _formKey = GlobalKey<FormBuilderState>();

  Future<MultiStockAdjustment?> _addAdjustment() async {
    return showModalBottomSheet<MultiStockAdjustment>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: const _AddAdjustmentBottomSheet(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final adjustmentsNotifier = ref.watch(stockAdjustmentsNotifierProvider.notifier);
    final adjustmentsState = ref.watch(stockAdjustmentsNotifierProvider);
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(context.l10n.stockAdjustment),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.viewPaddingOf(context).bottom == 0 ? 24 : MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: AppButton(
          isLoading: adjustmentsState.status == StockAdjustmentsStatus.loading,
          onPress: () {
            if (_formKey.currentState?.saveAndValidate() ?? false) {
              final value = Map<String, dynamic>.from(_formKey.currentState!.value);
              final formData = {
                'reference_number': value['reference_number'],
                'reason': value['reason'],
                'adjusted_date': (value['adjusted_date'] as DateTime).toIso8601String(),
                'adjusted_items': adjustmentsState.multiStockAdjustments
                    .map(
                      (e) => {
                        'current_quantity': e.currentQuantity,
                        'new_quantity': e.newQuantity,
                        'adjusted_quantity': e.adjustedQuantity,
                        'item_id': e.item.itemId,
                        'unit_price': e.unitPrice,
                      },
                    )
                    .toList(),
              };
              adjustmentsNotifier.adjustStock(formData).then(AppRouter.pop);
            }
          },
          label: Text(context.l10n.save),
        ),
      ),
      body: SafeArea(
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  children: [
                    AppTextForm<String>(
                      name: 'reference_number',
                      validator: FormBuilderValidators.compose(
                        [FormBuilderValidators.required()],
                      ),
                      label: context.l10n.referenceNumber,
                    ),
                    const SizedBox(height: 16),
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
                      ]
                          .where(
                            (reason) => reason.toLowerCase().contains(search.toLowerCase()),
                          )
                          .toList(),
                      itemBuilder: (context, suggestion) => ListTile(title: Text(suggestion)),
                      validator: FormBuilderValidators.compose(
                        [FormBuilderValidators.required()],
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppDateTimeForm(
                      initialValue: DateTime.now(),
                      name: 'adjusted_date',
                      validator: FormBuilderValidators.compose(
                        [FormBuilderValidators.required()],
                      ),
                      label: context.l10n.date,
                    ),
                    const SizedBox(height: 16),
                    FormBuilderField<List<MultiStockAdjustment>>(
                      name: 'adjusted_items',
                      // ignore: prefer_const_literals_to_create_immutables
                      initialValue: [],
                      builder: (field) {
                        return Column(
                          children: [
                            Ink(
                              padding: const EdgeInsets.all(6),
                              decoration: AppStyles.boxDecoration,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(6).resolve(TextDirection.ltr),
                                splashColor: Colors.transparent,
                                onTap: () {
                                  _addAdjustment().then((value) {
                                    if (value != null) {
                                      field.didChange([...?field.value, value]);
                                      adjustmentsNotifier.addAdjustment(value);
                                    }
                                  });
                                },
                                child: Ink(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    color: AppColors.lightPurple,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          context.l10n.addStockAdjustment,
                                          style: AppText.largeM.copyWith(
                                            color: AppColors.black,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.add,
                                          color: AppColors.black,
                                          size: 26,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            for (final adjustment in adjustmentsState.multiStockAdjustments) ...[
                              Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: AppStyles.boxDecoration,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xffFFF5F5),
                                        ),
                                        height: 30,
                                        child: IconButton(
                                          onPressed: () {
                                            adjustmentsNotifier.removeAdjustment(adjustment);
                                          },
                                          icon: Assets.icons.delete.svg(height: 18),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Table(
                                      border: const TableBorder(),
                                      children: [
                                        TableRow(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 8,
                                                right: 8,
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    context.l10n.itemName,
                                                    style: AppText.smallN.copyWith(color: AppColors.stormyBlue),
                                                  ),
                                                  Text(
                                                    adjustment.item.name,
                                                    style: AppText.mediumSB,
                                                  ),
                                                ],
                                              ).withSpacing(spacing: 4),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 8,
                                                left: 8,
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    context.l10n.quantityAvailable,
                                                    style: AppText.smallN.copyWith(color: AppColors.stormyBlue),
                                                  ),
                                                  Text(
                                                    adjustment.item.quantity.toString(),
                                                    style: AppText.mediumSB,
                                                  ),
                                                ],
                                              ).withSpacing(spacing: 4),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 8,
                                                right: 8,
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    context.l10n.newQuantityHand,
                                                    style: AppText.smallN.copyWith(color: AppColors.stormyBlue),
                                                  ),
                                                  Text(
                                                    adjustment.newQuantity.toString(),
                                                    style: AppText.mediumSB,
                                                  ),
                                                ],
                                              ).withSpacing(spacing: 4),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 8,
                                                left: 8,
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    context.l10n.quantityAdjusted,
                                                    style: AppText.smallN.copyWith(color: AppColors.stormyBlue),
                                                  ),
                                                  Text(
                                                    adjustment.adjustedQuantity.toString(),
                                                    style: AppText.mediumSB,
                                                  ),
                                                ],
                                              ).withSpacing(spacing: 4),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 8,
                                                right: 8,
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    context.l10n.unitPrice,
                                                    style: AppText.smallN.copyWith(color: AppColors.stormyBlue),
                                                  ),
                                                  Text(
                                                    adjustment.unitPrice.toString(),
                                                  ),
                                                ],
                                              ).withSpacing(spacing: 4),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddAdjustmentBottomSheet extends ConsumerStatefulWidget {
  const _AddAdjustmentBottomSheet();

  @override
  ConsumerState<_AddAdjustmentBottomSheet> createState() => _AddAdjustmentBottomSheetState();
}

class _AddAdjustmentBottomSheetState extends ConsumerState<_AddAdjustmentBottomSheet> {
  final _formKey = GlobalKey<FormBuilderState>();
  @override
  Widget build(BuildContext context) {
    final item = _formKey.currentState?.fields['name']?.value as Item?;
    return FormBuilder(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(context.l10n.stockAdjustment),
              const SizedBox(height: 16),
              AppTypeAheadForm<Item>(
                label: context.l10n.productName,
                name: 'name',
                suggestionsCallback: (search) => ref
                    .read(itemRepoProvider)
                    .getItems(
                      pageSize: 20,
                      pageNumber: 1,
                      query: search,
                      itemType: ItemType.goods.name,
                    )
                    .then((value) => value.data),
                itemBuilder: (context, suggestion) => ListTile(
                  title: Text(suggestion.name),
                ),
                selectionToTextTransformer: (suggestion) => suggestion.name,
                validator: FormBuilderValidators.required(),
                onSuggestionSelected: (suggestion) {
                  final fields = _formKey.currentState?.fields;
                  fields?['current_quantity']?.didChange(suggestion.stockQuantity.toString());
                  fields?['new_quantity']?.didChange(suggestion.stockQuantity.toString());
                  fields?['adjusted_quantity']?.didChange('0');
                  fields?['unit_price']?.didChange(suggestion.purchasePrice.toString());
                  setState(() {});
                },
                onClear: () {
                  final fields = _formKey.currentState?.fields;
                  fields?['current_quantity']?.didChange(null);
                  fields?['new_quantity']?.didChange(null);
                  fields?['adjusted_quantity']?.didChange(null);
                  fields?['unit_price']?.didChange(null);
                  setState(() {});
                },
              ),
              const SizedBox(height: 12),
              AppTextForm<double>(
                label: context.l10n.quantityAvailable,
                suffixIcon: Text(' ${item?.unit?.shortName ?? item?.unit?.name ?? ''}'),
                enabled: false,
                name: 'current_quantity',
                validator: FormBuilderValidators.compose(
                  [FormBuilderValidators.required()],
                ),
              ),
              const SizedBox(height: 12),
              AppTextForm<double>(
                label: context.l10n.newQuantityOnHand,
                onFocusLose: (newQuantity) {
                  _formKey.currentState?.fields['new_quantity']?.validate();
                  if (newQuantity != null) {
                    _formKey.currentState?.fields['adjusted_quantity']?.didChange(
                      (newQuantity - item!.stockQuantity).toString(),
                    );
                    setState(() {});
                  }
                },
                name: 'new_quantity',
                initialValue: 0,
                validator: FormBuilderValidators.compose(
                  [FormBuilderValidators.required()],
                ),
              ),
              const SizedBox(height: 12),
              AppTextForm<double>(
                label: context.l10n.quantityAdjusted,
                name: 'adjusted_quantity',
                onFocusLose: (adjustedQuantity) {
                  _formKey.currentState?.fields['adjusted_quantity']?.validate();
                  if (adjustedQuantity != null) {
                    _formKey.currentState?.fields['new_quantity']?.didChange(
                      (item!.stockQuantity + adjustedQuantity).toString(),
                    );
                    setState(() {});
                  }
                },
                hintText: 'Eg: +10, -10',
                validator: FormBuilderValidators.compose(
                  [
                    FormBuilderValidators.required(),
                    FormBuilderValidators.notZeroNumber(),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AppTextForm<double>(
                label: context.l10n.unitPrice,
                name: 'unit_price',
                validator: FormBuilderValidators.compose(
                  [
                    FormBuilderValidators.required(),
                    FormBuilderValidators.notZeroNumber(),
                  ],
                ),
              ),
              AppButton(
                onPress: () {
                  if (_formKey.currentState?.saveAndValidate() ?? false) {
                    context.pop(
                      MultiStockAdjustment(
                        item: item!,
                        currentQuantity: item.stockQuantity,
                        newQuantity: double.tryParse(
                              _formKey.currentState?.fields['new_quantity']?.value as String,
                            ) ??
                            0,
                        adjustedQuantity: double.tryParse(
                              _formKey.currentState?.fields['adjusted_quantity']?.value as String,
                            ) ??
                            0,
                        unitPrice: double.tryParse(
                              _formKey.currentState?.fields['unit_price']?.value as String,
                            ) ??
                            0,
                      ),
                    );
                  }
                },
                label: Text(context.l10n.add),
              ),
              const SizedBox(height: 12),
              AppButton(
                style: ButtonStyles.cancel,
                onPress: () {
                  context.pop();
                },
                label: Text(context.l10n.cancel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
