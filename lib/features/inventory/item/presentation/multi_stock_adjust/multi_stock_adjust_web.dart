import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:uuid/uuid.dart';

class MultiStockAdjustScreenWeb extends ConsumerStatefulWidget {
  const MultiStockAdjustScreenWeb({super.key});

  @override
  ConsumerState<MultiStockAdjustScreenWeb> createState() => _MultiStockAdjustScreenWebState();
}

class _MultiStockAdjustScreenWebState extends ConsumerState<MultiStockAdjustScreenWeb> {
  final _formKey = GlobalKey<FormBuilderState>();
  @override
  Widget build(BuildContext context) {
    final adjustmentsNotifier = ref.watch(stockAdjustmentsNotifierProvider.notifier);
    final adjustmentsState = ref.watch(stockAdjustmentsNotifierProvider);

    return FormBuilder(
      clearValueOnUnregister: true,
      key: _formKey,
      child: SingleChildScrollView(
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
            FormBuilderField<List<String>>(
              name: 'adjusted_items',
              initialValue: [const Uuid().v4()],
              builder: (field) {
                return Table(
                  columnWidths: const <int, TableColumnWidth>{
                    0: IntrinsicColumnWidth(),
                    1: FlexColumnWidth(),
                    2: FlexColumnWidth(),
                    3: FlexColumnWidth(),
                    4: FlexColumnWidth(),
                    5: FlexColumnWidth(),
                    6: IntrinsicColumnWidth(),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: <TableRow>[
                    TableRow(
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                        border: Border.all(color: const Color(0xffE6E7EA)),
                        color: const Color(0xfffafafa),
                      ),
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(context.l10n.slNo, style: AppText.mediumM.copyWith(color: AppColors.title)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(context.l10n.itemName, style: AppText.mediumM.copyWith(color: AppColors.title)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            context.l10n.quantityAvailable,
                            style: AppText.mediumM.copyWith(color: AppColors.title),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            context.l10n.newQuantityOnHand,
                            style: AppText.mediumM.copyWith(color: AppColors.title),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            context.l10n.quantityAdjusted,
                            style: AppText.mediumM.copyWith(color: AppColors.title),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            context.l10n.unitPrice,
                            style: AppText.mediumM.copyWith(color: AppColors.title),
                          ),
                        ),
                        const SizedBox(),
                      ],
                    ),
                    ...List<TableRow>.generate(field.value!.length, (index) {
                      final item = field.value![index];
                      return TableRow(
                        key: ObjectKey(item),
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              '${index + 1}',
                              style: AppText.mediumM.copyWith(color: AppColors.title),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: AppTypeAheadForm<Item>(
                              validator: FormBuilderValidators.required(),
                              name: 'item-name-$item',
                              suggestionsCallback: (search) => ref
                                  .read(itemRepoProvider)
                                  .getItems(
                                    pageSize: 12,
                                    pageNumber: 1,
                                    query: search,
                                    itemType: ItemType.goods.name,
                                  )
                                  .then((value) => value.data),
                              itemBuilder: (context, suggestion) => ListTile(
                                title: Text(suggestion.name),
                              ),
                              selectionToTextTransformer: (suggestion) => suggestion.name,
                              valueTransformer: (p0) => p0?.itemId,
                              onSuggestionSelected: (suggestion) {
                                final fields = _formKey.currentState?.fields;
                                fields?['quantity-available-$item']?.didChange(suggestion.stockQuantity);
                                fields?['new-quantity-$item']?.didChange(suggestion.stockQuantity.toString());
                                fields?['quantity-adjusted-$item']?.didChange('0');
                                fields?['unit-price-$item']?.didChange(suggestion.purchasePrice.toString());
                                setState(() {});
                              },
                              onClear: () {
                                final fields = _formKey.currentState?.fields;
                                fields?['quantity-available-$item']?.didChange(null);
                                fields?['new-quantity-$item']?.didChange(null);
                                fields?['quantity-adjusted-$item']?.didChange(null);
                                fields?['unit-price-$item']?.didChange(null);
                                setState(() {});
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: FormBuilderField<double>(
                              name: 'quantity-available-$item',
                              builder: (quantity) {
                                return Text(
                                  quantity.value?.toString() ?? '',
                                  style: AppText.mediumM.copyWith(color: AppColors.title),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: AppTextForm<double>(
                              name: 'new-quantity-$item',
                              onFocusLose: (newQuantity) {
                                final fields = _formKey.currentState?.fields;
                                final items = fields?['item-name-$item']?.value as Item?;
                                if (newQuantity != null && items != null) {
                                  fields?['quantity-adjusted-$item']?.didChange(
                                    (newQuantity - items.stockQuantity).toString(),
                                  );
                                  setState(() {});
                                } else {
                                  fields?['quantity-adjusted-$item']?.didChange('0.0');
                                  setState(() {});
                                }
                              },
                              hintText: '0.0',
                              validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: AppTextForm<double>(
                              name: 'quantity-adjusted-$item',
                              hintText: 'Eg: +10, -10',
                              onFocusLose: (quantityAdjusted) {
                                final fields = _formKey.currentState?.fields;
                                final items = fields?['item-name-$item']?.value as Item?;
                                if (quantityAdjusted != null && items != null) {
                                  fields?['new-quantity-$item']?.didChange(
                                    (quantityAdjusted + items.stockQuantity).toString(),
                                  );
                                  setState(() {});
                                } else {
                                  fields?['new-quantity-$item']?.didChange('0.0');
                                  setState(() {});
                                }
                              },
                              validator: FormBuilderValidators.compose(
                                [FormBuilderValidators.required(), FormBuilderValidators.notZeroNumber()],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: AppTextForm<double>(
                              name: 'unit-price-$item',
                              hintText: 'Eg: 1000',
                              validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                field.didChange([...field.value!..remove(item)]);
                              });
                            },
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.red,
                            ),
                          ),
                        ],
                      );
                    }),
                    TableRow(
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                        border: Border.all(color: const Color(0xffE6E7EA)),
                        color: AppColors.white,
                      ),
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          child: TextButton.icon(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                field.didChange([...field.value!, const Uuid().v4()]);
                              });
                            },
                            label: Text(context.l10n.addNewRow),
                          ),
                        ),
                        const SizedBox(),
                        const SizedBox(),
                        const SizedBox(),
                        const SizedBox(),
                        const SizedBox(),
                        const SizedBox(),
                      ],
                    ),
                  ],
                );
              },
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
                  isLoading: adjustmentsState.status == StockAdjustmentsStatus.loading,
                  onPress: () {
                    // {
                    //   "reference_number": "sfddfds",
                    //   "reason": "Expired",
                    //   "adjusted_date": "2024-11-05 12:00:00.000",
                    //   "adjusted_items": [
                    //     {"current_quantity": 12, "new_quantity": 10, "adjusted_quantity": -2, "item_id": "asdfljfsd-sdfsjdfjsdf-sdfsdfdsf-d"},
                    //     {"current_quantity": 5, "new_quantity": 8, "adjusted_quantity": 3, "item_id": "qwerasdf-1234-5678-90ab-cdefghijklmn"}
                    //   ]
                    // }
                    if (_formKey.currentState?.saveAndValidate() ?? false) {
                      final value = Map<String, dynamic>.from(_formKey.currentState!.value);
                      final formData = {
                        'reference_number': value['reference_number'],
                        'reason': value['reason'],
                        'adjusted_date': (value['adjusted_date'] as DateTime).toIso8601String(),
                        'adjusted_items': (value['adjusted_items'] as List<String>)
                            .map(
                              (e) => {
                                'current_quantity': value['quantity-available-$e'],
                                'new_quantity': value['new-quantity-$e'],
                                'adjusted_quantity': value['quantity-adjusted-$e'],
                                'item_id': value['item-name-$e'],
                                'unit_price': value['unit-price-$e'],
                              },
                            )
                            .toList(),
                      };
                      adjustmentsNotifier.adjustStock(formData).then(AppRouter.pop);
                    }
                  },
                  label: Text(context.l10n.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
