import 'package:duxbe/features/purchase/purchase.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:uuid/uuid.dart';

class PurchaseReturnDetailsScreenWeb extends ConsumerStatefulWidget {
  const PurchaseReturnDetailsScreenWeb({required this.purchase, super.key});
  final PurchaseView? purchase;

  @override
  ConsumerState<PurchaseReturnDetailsScreenWeb> createState() => _PurchaseReturnDetailsScreenWebState();
}

class _PurchaseReturnDetailsScreenWebState extends ConsumerState<PurchaseReturnDetailsScreenWeb> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isUpdatingFields = false;

  @override
  void initState() {
    Future(
      () async {
        _formKey.currentState?.fields['return_invoice']?.didChange(await ref.read(purchaseRepoProvider).getNextPurchaseReturnCode());
        setState(() {});
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _formKey,
      onChanged: () {
        if (_isUpdatingFields) return;

        try {
          _isUpdatingFields = true; // Start updating fields

          // Get all required fields upfront to avoid multiple accesses
          final fields = _formKey.currentState?.fields;
          if (fields == null) return;

          final purchase = fields['invoice']?.value as PurchaseView?;
          if (purchase == null) return;

          final returnedItems = fields['returned_items']?.value as List<String?>? ?? [];
          if (returnedItems.isEmpty) return;

          // Only calculate if there are actual changes to relevant fields
          var shouldRecalculate = false;
          for (final itemId in returnedItems) {
            if ((fields['quantity-adjusted-$itemId']?.isDirty ?? false) || (fields['item-name-$itemId']?.isDirty ?? false)) {
              shouldRecalculate = true;
              break;
            }
          }

          if (!shouldRecalculate) return;

          // Calculate return amount
          final returnAmount = returnedItems.fold<double>(0, (previous, itemId) {
            if (itemId == null) return previous;

            final saleItem = fields['item-name-$itemId']?.value as PurchaseItemView?;
            if (saleItem == null) return previous;

            final unitPrice = saleItem.unitPrice;
            final quantityAdjusted = double.tryParse(fields['quantity-adjusted-$itemId']?.value?.toString() ?? '0') ?? 0.0;
            final discountPercent = double.tryParse(fields['total_discount_percent']?.value?.toString() ?? '0') ?? 0.0;

            final itemReturnAmount = unitPrice - (unitPrice * discountPercent / 100);

            return previous + (itemReturnAmount * quantityAdjusted);
          });

          // Only update if values have actually changed
          final currentReturnAmount = double.tryParse(fields['return_amount']?.value?.toString() ?? '0') ?? 0.0;

          if (returnAmount != currentReturnAmount) {
            fields['return_amount']?.didChange(returnAmount.toStringAsFixed(2));

            final newDue = (purchase.dueAmount) + returnAmount;
            fields['new_due']?.didChange(newDue.toStringAsFixed(2));
          }
        } finally {
          _isUpdatingFields = false; // End updating fields
        }
      },
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    decoration: AppStyles.boxDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: AppTypeAheadForm<PurchaseView>(
                                name: 'invoice',
                                label: '${context.l10n.selectPurchaseInvoice} *',
                                initialValue: widget.purchase,
                                selectionToTextTransformer: (suggestion) => suggestion.invoiceNo,
                                enabled: widget.purchase == null,
                                itemBuilder: (context, suggestion) {
                                  return ListTile(
                                    title: Text(suggestion.invoiceNo),
                                  );
                                },
                                suggestionsCallback: (String search) async {
                                  return ref
                                      .read(purchaseRepoProvider)
                                      .getPurchases(
                                        pageSize: 100,
                                        pageNumber: 1,
                                        query: search,
                                        supplierId: (_formKey.currentState?.fields['supplier']?.value as Supplier?)?.supplierId,
                                      )
                                      .then((value) => value.data);
                                },
                                onSuggestionSelected: (suggestion) {
                                  // set supplier
                                  _formKey.currentState?.patchValue({
                                    'supplier': suggestion.supplier,
                                    'total_discount_percent':
                                        (suggestion.discountAmount / suggestion.subTotal * 100).toStringAsFixed(2),
                                    'total_discount_amount': suggestion.discountAmount.toStringAsFixed(2),
                                    'invoice_tax_amount': suggestion.taxAmount.toStringAsFixed(2),
                                    'invoice_total': suggestion.totalAmount.toStringAsFixed(2),
                                    'total_paid': suggestion.paidAmount.toStringAsFixed(2),
                                    'return_amount': '0',
                                    'new_due': suggestion.dueAmount.toStringAsFixed(2),
                                  });
                                  setState(() {});
                                },
                                onClear: () {
                                  _formKey.currentState?.patchValue({
                                    'customer': null,
                                    'total_discount_percent': '0',
                                    'total_discount_amount': '0',
                                    'invoice_tax_amount': '0',
                                    'invoice_total': '0',
                                    'total_paid': '0',
                                    'return_amount': '0',
                                    'new_due': '0',
                                  });
                                  setState(() {});
                                },
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: AppTextForm<String>(
                                name: 'return_invoice',
                                style: AppText.largeM.copyWith(
                                  color: AppColors.darkBlue,
                                ),
                                label: context.l10n.returnInvoice,
                                validator: FormBuilderValidators.required(),
                                isReadOnly: true,
                                decoration: InputDecoration(
                                  fillColor: AppColors.lightPurple,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            // return reason
                            Expanded(
                              child: AppTextForm<String>(
                                name: 'return_reason',
                                label: '${context.l10n.returnReason} *',
                                validator: FormBuilderValidators.required(),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: AppTypeAheadForm<Supplier>(
                                name: 'supplier',
                                label: '${context.l10n.supplier} *',
                                initialValue: widget.purchase?.supplier,
                                selectionToTextTransformer: (suggestion) => suggestion.name,
                                enabled: widget.purchase == null,
                                itemBuilder: (context, suggestion) {
                                  return ListTile(
                                    title: Text(suggestion.name),
                                  );
                                },
                                suggestionsCallback: (String search) async {
                                  return ref
                                      .read(supplierRepoProvider)
                                      .getSuppliers(pageSize: 100, pageNumber: 1, query: search)
                                      .then((value) => value.data);
                                },
                                onSuggestionSelected: (suggestion) {
                                  // clear invoice
                                  _formKey.currentState?.fields['invoice']?.didChange(null);
                                  setState(() {});
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        FormBuilderField<List<String>>(
                          name: 'returned_items',
                          initialValue: [const Uuid().v4()],
                          builder: (field) {
                            return Table(
                              columnWidths: const <int, TableColumnWidth>{
                                0: IntrinsicColumnWidth(),
                                1: FlexColumnWidth(),
                                2: FlexColumnWidth(),
                                3: FlexColumnWidth(),
                                4: FlexColumnWidth(),
                                5: IntrinsicColumnWidth(),
                              },
                              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                              children: <TableRow>[
                                TableRow(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
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
                                      child: Text(context.l10n.quantityAvailable, style: AppText.mediumM.copyWith(color: AppColors.title)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Text(context.l10n.newQuantityOnHand, style: AppText.mediumM.copyWith(color: AppColors.title)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Text(context.l10n.quantityAdjusted, style: AppText.mediumM.copyWith(color: AppColors.title)),
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
                                        child: AppTypeAheadForm<PurchaseItemView>(
                                          validator: FormBuilderValidators.required(),
                                          name: 'item-name-$item',
                                          suggestionsCallback: (search) {
                                            final purchase = _formKey.currentState?.fields['invoice']?.value as PurchaseView?;
                                            if (purchase == null) return [];

                                            // remove existing items
                                            return List.from(purchase.purchaseItems)
                                              ..removeWhere((element) {
                                                for (var i = 0; i < field.value!.length; i++) {
                                                  final item =
                                                      _formKey.currentState?.fields['item-name-${field.value![i]}']?.value as PurchaseItemView?;
                                                  if (element.itemId == item?.itemId) return true;
                                                }
                                                return false;
                                              })
                                              ..where((element) => element.item.name.contains(search));
                                          },
                                          itemBuilder: (context, suggestion) => ListTile(
                                            title: Text(suggestion.item.name),
                                          ),
                                          selectionToTextTransformer: (suggestion) => suggestion.item.name,
                                          valueTransformer: (p0) => p0?.itemId,
                                          onSuggestionSelected: (suggestion) {
                                            final fields = _formKey.currentState?.fields;
                                            fields?['quantity-available-$item']?.didChange(suggestion.quantity);
                                            fields?['new-quantity-$item']?.didChange(suggestion.quantity.toString());
                                            fields?['quantity-adjusted-$item']?.didChange('0');
                                            setState(() {});
                                          },
                                          onClear: () {
                                            final fields = _formKey.currentState?.fields;
                                            fields?['quantity-available-$item']?.didChange(null);
                                            fields?['new-quantity-$item']?.didChange(null);
                                            fields?['quantity-adjusted-$item']?.didChange(null);
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
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          name: 'new-quantity-$item',
                                          onFocusLose: (newQuantity) {
                                            final fields = _formKey.currentState?.fields;
                                            final items = fields?['item-name-$item']?.value as PurchaseItemView?;
                                            if (newQuantity != null && items != null) {
                                              fields?['quantity-adjusted-$item']?.didChange(
                                                (newQuantity - items.quantity).toString(),
                                              );
                                              setState(() {});
                                            } else {
                                              fields?['quantity-adjusted-$item']?.didChange('0.0');
                                              setState(() {});
                                            }
                                          },
                                          hintText: '0.0',
                                          validator: FormBuilderValidators.compose([
                                            FormBuilderValidators.required(),
                                            // should be between 0 and quantity-available-$item
                                            FormBuilderValidators.between(
                                              0,
                                              _formKey.currentState?.fields['quantity-available-$item']?.value as double? ?? 0,
                                            ),
                                          ]),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: AppTextForm<double>(
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          name: 'quantity-adjusted-$item',
                                          hintText: 'Eg: +10, -10',
                                          onFocusLose: (quantityAdjusted) {
                                            final fields = _formKey.currentState?.fields;
                                            final items = fields?['item-name-$item']?.value as PurchaseItemView?;
                                            if (quantityAdjusted != null && items != null) {
                                              fields?['new-quantity-$item']?.didChange(
                                                (quantityAdjusted + items.quantity).toString(),
                                              );
                                              setState(() {});
                                            } else {
                                              fields?['new-quantity-$item']?.didChange('0.0');
                                              setState(() {});
                                            }
                                          },
                                          validator: FormBuilderValidators.compose([
                                            FormBuilderValidators.required(),
                                            FormBuilderValidators.notZeroNumber(),
                                            // should be between 0 and -(quantity-available-$item)
                                            FormBuilderValidators.between(
                                              -(_formKey.currentState?.fields['quantity-available-$item']?.value as double? ?? 0),
                                              0,
                                            ),
                                          ]),
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
                                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
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
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        GridView(
                          shrinkWrap: true,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisExtent: 90, crossAxisSpacing: 16),
                          children: [
                            AppTextForm<double>(
                              name: 'total_discount_percent',
                              isReadOnly: true,
                              label: context.l10n.totalDiscount,
                            ),
                            AppTextForm<double>(
                              name: 'total_discount_amount',
                              isReadOnly: true,
                              label: context.l10n.totalDiscountAmount,
                            ),
                            AppTextForm<double>(
                              name: 'invoice_tax_amount',
                              isReadOnly: true,
                              label: context.l10n.invoiceTax,
                            ),
                            AppTextForm<double>(
                              name: 'return_amount',
                              isReadOnly: true,
                              label: context.l10n.returnAmount,
                            ),
                            AppTextForm<double>(
                              name: 'invoice_total',
                              isReadOnly: true,
                              label: context.l10n.invoiceTotal,
                            ),
                            AppTextForm<double>(
                              name: 'total_paid',
                              isReadOnly: true,
                              label: context.l10n.totalPaid,
                            ),
                            AppTextForm<double>(
                              name: 'new_due',
                              isReadOnly: true,
                              label: context.l10n.newDue,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    decoration: AppStyles.boxDecoration,
                    child: Column(
                      children: [
                        AppTextForm<String>(
                          name: 'note',
                          minLines: 3,
                          label: context.l10n.note,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        AppDateTimeForm(name: 'return_date', label: context.l10n.returnDate),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton(
                style: ButtonStyles.secondary,
                label: Text(context.l10n.cancel),
                onPress: () => context.pop(),
              ),
              const SizedBox(width: 20),
              AppButton(
                width: 300,
                isLoading: ref.watch(purchaseReturnNotifierProvider).status == PurchaseReturnStatus.loading,
                label: Text(context.l10n.save),
                onPress: () {
                  if (_formKey.currentState?.saveAndValidate() ?? false) {
                    final returnInvoice = _formKey.currentState?.fields['return_invoice']?.value as String;
                    final returnReason = _formKey.currentState?.fields['return_reason']?.value as String;
                    final note = _formKey.currentState?.fields['note']?.value as String? ?? '';
                    final returnDate = _formKey.currentState?.fields['return_date']?.value as DateTime? ?? DateTime.now();
                    final returnedItemIds = _formKey.currentState?.fields['returned_items']?.value as List<String>? ?? [];
                    final returnAmount =
                        double.parse(_formKey.currentState?.fields['return_amount']?.value.toString() ?? '0');

                    // Create items list
                    final items = returnedItemIds.map((itemId) {
                      final purchaseItem = _formKey.currentState?.fields['item-name-$itemId']?.value as PurchaseItemView;
                      final quantityAdjusted = double.parse(_formKey.currentState?.fields['quantity-adjusted-$itemId']?.value.toString() ?? '0');

                      return {
                        'item_id': purchaseItem.itemId, // Generate new ID for return item
                        'original_item_id': purchaseItem.purchaseItemId,
                        'quantity': quantityAdjusted.abs(), // Convert to positive number
                        'unit_price': purchaseItem.unitPrice,
                      };
                    }).toList();

                    final purchase = _formKey.currentState?.fields['invoice']?.value as PurchaseView;

                    final submitJson = {
                      'purchase_id': purchase.purchaseId,
                      'business_id': purchase.businessId,
                      'return_invoice': returnInvoice,
                      'return_date': returnDate.toUtc().toIso8601String(),
                      'reason': returnReason,
                      'notes': note,
                      'items': items,
                      'return_amount': returnAmount,
                    };

                    // Now you can submit this JSON to your API
                    ref.read(purchaseReturnNotifierProvider.notifier).createPurchaseReturn(data: CreatePurchaseReturn.fromJson(submitJson)).then((_) {
                      if (context.mounted) context.pop();
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
