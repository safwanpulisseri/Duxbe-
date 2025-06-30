import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/features/invoice/invoice.dart';
import 'package:duxbe/features/invoice/presentation/create_quote/add_shipping_address.dart';
import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/features/staffs/staffs.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:uuid/uuid.dart';

class CreateCreditScreenWeb extends ConsumerStatefulWidget {
  const CreateCreditScreenWeb({super.key, this.creditNote});
  final CreditNote? creditNote;

  @override
  ConsumerState<CreateCreditScreenWeb> createState() =>
      _CreateCreditScreenWebState();
}

class _CreateCreditScreenWebState extends ConsumerState<CreateCreditScreenWeb> {
  final _formKey = GlobalKey<FormBuilderState>();

  /// Creates a divider with the given height
  Widget _buildDivider({
    Widget? child,
    double? height,
    BorderRadiusGeometry? borderRadius,
  }) {
    return Container(
      height: height ?? _dividerHeight,
      decoration: BoxDecoration(
        color: AppColors.textfieldFill,
        border: Border.all(color: AppColors.divider),
        borderRadius: borderRadius,
      ),
      padding: _screenPadding,
      child: child,
    );
  }

  final double _defaultSpacing = 20;
  final double _dividerHeight = 10;
  final EdgeInsets _screenPadding = const EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 16,
  );

  final TextEditingController _customerName = TextEditingController();
  @override
  void dispose() {
    _customerName.dispose();
    super.dispose();
  }

  Widget _buildItemTiles({
    required String label,
    required Widget child,
    Color? labelColor,
    bool enableDottedLine = true,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppText.m20.copyWith(
                color: labelColor ?? AppColors.stormyBlue,
              ),
            ),
            child,
          ],
        ),
        if (enableDottedLine)
          const DottedLine(
            height: 12,
            color: AppColors.stormyBlue,
          ),
      ],
    );
  }

  final border = const OutlineInputBorder(
    borderRadius: BorderRadius.only(
      topRight: Radius.circular(8),
      bottomRight: Radius.circular(8),
    ),
    borderSide: BorderSide(color: AppColors.stormyBlue),
  );

  void _updateAmount(String itemId) {
    final quantity = int.tryParse(
          _formKey.currentState?.fields['quantity-$itemId']?.value
                  ?.toString() ??
              '1',
        ) ??
        1;
    final rate = double.tryParse(
          _formKey.currentState?.fields['rate-$itemId']?.value?.toString() ??
              '0.0',
        ) ??
        0.0;

    final amount = quantity * rate;
    _formKey.currentState?.fields['amount-$itemId']
        ?.didChange(amount.toStringAsFixed(2));
    _updateSummary();
  }

  void _updateSummary() {
    if (_formKey.currentState == null) return;

    final items = _formKey.currentState!.fields['invoice_items']?.value
            as List<String>? ??
        [];
    double subtotal = 0;
    var totalItems = 0;

    for (final itemId in items) {
      final quantity = int.tryParse(
            _formKey.currentState!.fields['quantity-$itemId']?.value
                    ?.toString() ??
                '0',
          ) ??
          0;
      final rate = double.tryParse(
            _formKey.currentState!.fields['rate-$itemId']?.value?.toString() ??
                '0.0',
          ) ??
          0.0;
      subtotal += quantity * rate;
      totalItems += quantity;
    }

    double taxValue = 0;
    if (items.isNotEmpty) {
      final taxField =
          _formKey.currentState!.fields['tax-rate-${items.first}']?.value;
      if (taxField is Tax) {
        final taxRate = taxField.rate;
        if (taxRate > 0 && subtotal > 0) {
          taxValue = (subtotal * taxRate) / 100;
        }
      }
    }

    final shipping = double.tryParse(
          _formKey.currentState!.fields['shipping']?.value?.toString() ?? '0.0',
        ) ??
        0.0;
    final discountPercentValue = double.tryParse(
          _formKey.currentState!.fields['discount-percent']?.value
                  ?.toString() ??
              '0.0',
        ) ??
        0.0;
    final discountAmountValue = double.tryParse(
          _formKey.currentState!.fields['discount-amount']?.value?.toString() ??
              '0.0',
        ) ??
        0.0;

    double finalDiscountAmount = 0;
    var finalDiscountPercent = discountPercentValue;

    if (discountPercentValue > 0) {
      finalDiscountAmount = (subtotal * discountPercentValue) / 100;
    } else if (discountAmountValue > 0) {
      finalDiscountAmount = discountAmountValue;
      if (subtotal > 0) {
        finalDiscountPercent = (discountAmountValue / subtotal) * 100;
      } else {
        finalDiscountPercent = 0;
      }
    }

    final grandTotal = subtotal + taxValue + shipping - finalDiscountAmount;

    _formKey.currentState!.patchValue({
      'total-items': totalItems.toString(),
      'subtotal': subtotal.toStringAsFixed(2),
      'tax-value': taxValue.toStringAsFixed(2),
      'discount-percent': finalDiscountPercent.toStringAsFixed(2),
      'discount-amount': finalDiscountAmount.toStringAsFixed(2),
      'grand-total': grandTotal.toStringAsFixed(2),
    });

    if (mounted) {
      setState(() {});
    }
  }

  bool _itemsPopulated = false;

  @override
  void initState() {
    if (widget.creditNote != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final credit = widget.creditNote!;

        _formKey.currentState?.patchValue({
          'credit_note': credit.creditNoteCode ?? '',

          'note': credit.notes ?? '',
          'terms_and_conditions': credit.termsAndConditions ?? '',
          'shipping': credit.shippingCharges?.toString() ?? '0.00',
          'discount-amount': credit.discountAmount?.toString() ?? '0.00',
          'discount-percent':
              '0.00', // Reset discount percent when using fixed amount
          // Summary fields like 'total-items', 'subtotal', etc., will be populated by _updateSummary
        });
      });
    } else {
      Future(
        () async {
          _formKey.currentState?.fields['credit_note']?.didChange(
            await ref.read(creditNoteRepoProvider).getNextCreditNotCode(),
          );
          _formKey.currentState?.patchValue({
            'credit_note_date': DateTime.now(),
            'discount-percent':
                '0.00', // Reset discount percent when using fixed amount
            // Summary fields like 'total-items', 'subtotal', etc., will be populated by _updateSummary
          });
          setState(() {});
        },
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);
    final customer = ref.watch(createCreditNotifierProvider).customer;
    final createCreditState = ref.watch(createCreditNotifierProvider);
    final creditNotifier = ref.watch(createCreditNotifierProvider.notifier);
    final invoiceNotifier = ref.watch(createInvoiceNotifierProvider.notifier);

    return FormBuilder(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: AppStyles.boxDecoration,
              padding: _screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Customer Selection
                  Row(
                    children: [
                      Expanded(
                        child: AppTypeAheadForm<Customer>(
                          decoration: const InputDecoration(
                            suffixIcon: Icon(
                              CupertinoIcons.chevron_down,
                              color: AppColors.purple,
                              weight: 16,
                            ),
                          ),
                          name: 'customer',
                          label: '${context.l10n.customer} *',
                          initialValue: widget.creditNote?.customer,
                          selectionToTextTransformer: (suggestion) =>
                              suggestion.name,
                          itemBuilder: (context, suggestion) => ListTile(
                            title: Text(suggestion.name),
                          ),
                          suggestionsCallback: (String search) async {
                            try {
                              final response = await ref
                                  .read(customerRepoProvider)
                                  .getCustomers(
                                    pageSize: 100,
                                    pageNumber: 1,
                                    query: search,
                                  );
                              return response.data;
                            } catch (e) {
                              setState(() {});
                              return [];
                            }
                          },
                          onSuggestionSelected: (suggestion) {
                            _formKey.currentState?.fields['customer']
                                ?.didChange(suggestion);
                            setState(() {});
                            creditNotifier.setCustomer(customer: suggestion);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Padding(
                      //   padding: const EdgeInsets.only(top: 30),
                      //   child: AppButton.icon(
                      //     icon: const Icon(Icons.add),
                      //     onPress: () async {
                      //       final customer = await showDialog<Customer>(
                      //         context: context,
                      //         builder: (context) {
                      //           return AddCustomerDialog(
                      //             customerName: _customerName.text,
                      //           );
                      //         },
                      //       );
                      //       if (customer != null) {
                      //         _formKey.currentState?.fields['customer']
                      //             ?.didChange(customer);
                      //         _formKey.currentState?.fields['invoice']
                      //             ?.didChange(null);
                      //         creditNotifier.setCustomer(customer: customer);
                      //       }
                      //     },
                      //     label: Text(context.l10n.addCustomer),
                      //   ),
                      // ),

                      const Spacer(),
                    ],
                  ),

                  SizedBox(height: _defaultSpacing),

                  // Address Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Billing Address
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTypeAheadForm<CustomerAddress>(
                              decoration: const InputDecoration(
                                suffixIcon: Icon(
                                  CupertinoIcons.chevron_down,
                                  color: AppColors.purple,
                                  weight: 16,
                                ),
                              ),
                              itemBuilder: (context, suggestion) => ListTile(
                                title: Text(suggestion.address ?? ''),
                                subtitle: Text(
                                  '${suggestion.city}, ${suggestion.state}, ${suggestion.zipcode}, ${suggestion.country}',
                                ),
                              ),
                              name: 'billing_address',
                              label: context.l10n.billingAddress,
                              initialValue: widget
                                  .creditNote?.invoiceDetails?.billingAddress,
                              selectionToTextTransformer: (suggestion) =>
                                  suggestion.address ?? '',
                              suggestionsCallback: (String search) async {
                                final addresses =
                                    await invoiceNotifier.getCustomerAddresses(
                                  customerId: (_formKey
                                              .currentState
                                              ?.fields['customer']
                                              ?.value as Customer)
                                          .customerId ??
                                      '',
                                );
                                return addresses;
                              },
                              onSuggestionSelected: (suggestion) {
                                ref
                                    .read(
                                      createCreditNotifierProvider.notifier,
                                    )
                                    .setAddress(
                                      address: suggestion,
                                      type: 'billing',
                                    );
                                _formKey.currentState?.fields['billing_address']
                                    ?.didChange(suggestion);
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              createCreditState.billingAddress == null
                                  ? customer?.address ??
                                      context.l10n.noBillingAddressAvailable
                                  : '${createCreditState.billingAddress?.address}, \n${createCreditState.billingAddress?.city}, ${createCreditState.billingAddress?.state} \n${createCreditState.billingAddress?.zipcode}, ${createCreditState.billingAddress?.country}',
                              style: AppText.mediumN.copyWith(
                                color: AppColors.black,
                                height: 1.8,
                              ),
                              textAlign: TextAlign.left,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () async {
                                if (createCreditState.customer != null) {
                                  final adress =
                                      await showDialog<CustomerAddress>(
                                    context: AppRouter.rootContext,
                                    builder: (context) => AddShippingAddress(
                                      customerId: createCreditState
                                              .customer?.customerId ??
                                          '',
                                      type: ShippingAddressType.billing,
                                    ),
                                  );
                                  if (adress != null) {
                                    ref
                                        .read(
                                          createCreditNotifierProvider.notifier,
                                        )
                                        .setAddress(
                                          address: adress,
                                          type: 'billing',
                                        );
                                  }
                                } else {
                                  Alert.showSnackBar(
                                    context.l10n.pleaseSelectACustomerFirst,
                                    type: SnackBarType.warning,
                                  );
                                }
                              },
                              child: Text(context.l10n.newAddress),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: _defaultSpacing),

                      // Shipping Address
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTypeAheadForm<CustomerAddress>(
                              decoration: const InputDecoration(
                                suffixIcon: Icon(
                                  CupertinoIcons.chevron_down,
                                  color: AppColors.purple,
                                  weight: 16,
                                ),
                              ),
                              itemBuilder: (context, suggestion) => ListTile(
                                title: Text(suggestion.address ?? ''),
                                subtitle: Text(
                                  '${suggestion.city}, ${suggestion.state}, ${suggestion.zipcode}, ${suggestion.country}',
                                ),
                              ),
                              name: 'shipping_address',
                              label: context.l10n.shippingAddress,
                              initialValue: widget
                                  .creditNote?.invoiceDetails?.billingAddress,
                              selectionToTextTransformer: (suggestion) =>
                                  suggestion.address ?? '',
                              suggestionsCallback: (String search) async {
                                final addresses =
                                    await invoiceNotifier.getCustomerAddresses(
                                  customerId: (_formKey
                                              .currentState
                                              ?.fields['customer']
                                              ?.value as Customer)
                                          .customerId ??
                                      '',
                                );
                                return addresses;
                              },
                              onSuggestionSelected: (suggestion) {
                                ref
                                    .read(
                                      createCreditNotifierProvider.notifier,
                                    )
                                    .setAddress(
                                      address: suggestion,
                                      type: 'shipping',
                                    );
                                _formKey
                                    .currentState?.fields['shipping_address']
                                    ?.didChange(suggestion);
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              createCreditState.shippingAddress == null
                                  ? customer?.address ??
                                      context.l10n.noShippingAddressAvailable
                                  : '${createCreditState.shippingAddress?.address}, \n${createCreditState.shippingAddress?.city}, ${createCreditState.shippingAddress?.state} \n${createCreditState.shippingAddress?.zipcode}, ${createCreditState.shippingAddress?.country}',
                              style: AppText.mediumN.copyWith(
                                color: AppColors.black,
                                height: 1.8,
                              ),
                              textAlign: TextAlign.left,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () async {
                                if (createCreditState.customer != null) {
                                  final adress =
                                      await showDialog<CustomerAddress>(
                                    context: AppRouter.rootContext,
                                    builder: (context) => AddShippingAddress(
                                      customerId: createCreditState
                                              .customer?.customerId ??
                                          '',
                                      type: ShippingAddressType.shipping,
                                    ),
                                  );
                                  if (adress != null) {
                                    ref
                                        .read(
                                          createCreditNotifierProvider.notifier,
                                        )
                                        .setAddress(
                                          address: adress,
                                          type: 'shipping',
                                        );
                                  }
                                } else {
                                  Alert.showSnackBar(
                                    context.l10n.pleaseSelectACustomerFirst,
                                    type: SnackBarType.warning,
                                  );
                                }
                              },
                              child: Text(context.l10n.newAddress),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: _defaultSpacing),
                  _buildDivider(),
                  SizedBox(height: _defaultSpacing),

                  Row(
                    children: [
                      Expanded(
                        child: AppTypeAheadForm<Invoice>(
                          name: 'invoice',
                          label: '${context.l10n.invoice} *',
                          initialValue: widget.creditNote?.invoiceDetails,
                          selectionToTextTransformer: (suggestion) =>
                              suggestion.invoiceCode!,
                          // enabled: widget.purchase == null,
                          itemBuilder: (context, suggestion) {
                            return ListTile(
                              title: Text(suggestion.invoiceCode!),
                            );
                          },
                          suggestionsCallback: (String search) async {
                            return ref
                                .read(creditNoteRepoProvider)
                                .getInvoices(
                                  pageSize: 100,
                                  pageNumber: 1,
                                  query: search,
                                  customerId: (_formKey
                                          .currentState
                                          ?.fields['customer']
                                          ?.value as Customer?)
                                      ?.customerId,
                                )
                                .then((value) => value.data);
                          },
                          onSuggestionSelected: (suggestion) {
                            // 1. Patch the customer from the selected invoice
                            _formKey.currentState?.patchValue({
                              'customer': suggestion.customer,
                            });

                            // 2. Prepare to populate items
                            final invoiceItems = suggestion
                                .invoiceItems; // Assuming this property exists on your Invoice model

                            if (invoiceItems.isEmpty) {
                              // If the selected invoice has no items, clear the list
                              _formKey.currentState?.fields['invoice_items']
                                  ?.didChange([]);
                              _updateSummary();
                              setState(() {});
                              return;
                            }

                            // 3. Generate new unique IDs and a map of values to patch
                            final newUuids = <String>[];
                            final valuesToPatch = <String, dynamic>{};

                            for (final itemDetail in invoiceItems) {
                              final uuid = const Uuid().v4();
                              newUuids.add(uuid);

                              final amount = itemDetail.quantity! *
                                  (itemDetail.unitPrice ?? 0.0);

                              // Add the data for this item to our patch map
                              // NOTE: The form fields 'item-name-*' and 'tax-rate-*' expect full objects (Item and Tax),
                              // not just strings. Make sure your 'itemDetail' provides these.
                              valuesToPatch['item-name-$uuid'] =
                                  itemDetail.item;
                              valuesToPatch['quantity-$uuid'] =
                                  itemDetail.quantity.toString();
                              valuesToPatch['rate-$uuid'] =
                                  itemDetail.unitPrice?.toStringAsFixed(2);
                              // valuesToPatch['tax-rate-$uuid'] = 0;
                              valuesToPatch['amount-$uuid'] =
                                  amount.toStringAsFixed(2);
                            }

                            // 4. Update the FormBuilderField with the new list of IDs.
                            // This will trigger a rebuild and create the new (empty) rows.
                            _formKey.currentState?.fields['invoice_items']
                                ?.didChange(newUuids);

                            // 5. CRUCIAL: Patch the values *after* the rebuild is complete.
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted && _formKey.currentState != null) {
                                _formKey.currentState!
                                    .patchValue(valuesToPatch);
                                // After patching, recalculate all totals.
                                _updateSummary();
                              }
                            });

                            // 6. Trigger the rebuild.
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
                      SizedBox(width: _defaultSpacing),
                      Expanded(
                        child: AppTextForm<String>(
                          name: 'reason',
                          label: context.l10n.reason,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter a reason';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  SizedBox(height: _defaultSpacing),
                  _buildDivider(),
                  SizedBox(height: _defaultSpacing),

                  // Quote Details
                  Row(
                    children: [
                      Expanded(
                        child: AppTextForm<String>(
                          name: 'credit_note',
                          label: '${context.l10n.creditNote}*',
                          initialValue: widget.creditNote?.creditNoteCode ?? '',
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter a credit note number';
                            }
                            return null;
                          },
                          style: AppText.largeM.copyWith(
                            color: AppColors.darkBlue,
                          ),
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
                      SizedBox(width: _defaultSpacing),
                      Expanded(
                        child: AppTextForm<String>(
                          name: 'reference',
                          label: context.l10n.reference,
                          initialValue: widget.creditNote?.reference ?? '',
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter a reference';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: AppDateTimeForm(
                          name: 'credit_note_date',
                          inputType: InputType.date,
                          label: '${context.l10n.date}*',
                          initialValue: widget.creditNote?.creditNoteDate ??
                              DateTime.now(),
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a date';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: _defaultSpacing),
                      Expanded(
                        child: AppTypeAheadForm<EmployeeModel>(
                          name: 'sales_person',
                          label: '${context.l10n.salesPerson}#*',
                          selectionToTextTransformer: (suggestion) =>
                              suggestion.name,
                          itemBuilder: (context, suggestion) => ListTile(
                            title: Text(suggestion.name),
                          ),
                          initialValue: ref.read(authNotifierProvider).user,
                          suggestionsCallback: (String search) async {
                            try {
                              final response = await ref
                                  .read(staffRepoProvider)
                                  .getEmployees(
                                    pageSize: 100,
                                    pageNumber: 1,
                                    query: search,
                                  )
                                  .then((value) => value.data);
                              return response;
                            } catch (e) {
                              setState(() {});
                              return [];
                            }
                          },
                          onSuggestionSelected: (suggestion) {
                            _formKey.currentState?.fields['sales_person']
                                ?.didChange(suggestion);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  FormBuilderField<List<String>>(
                    name: 'invoice_items',
                    initialValue:
                        // ignore: use_if_null_to_convert_nulls_to_bools
                        widget.creditNote?.creditNoteItems?.isNotEmpty == true
                            ? widget.creditNote?.creditNoteItems
                                ?.map((e) =>
                                    e.creditNoteItemId ?? const Uuid().v4())
                                .toList()
                            : [const Uuid().v4()],
                    builder: (field) {
                      if (widget.creditNote != null &&
                          widget.creditNote!.creditNoteItems!.isNotEmpty &&
                          !_itemsPopulated) {
                        _itemsPopulated = true;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          // First populate all item fields
                          for (final invoiceItemModel
                              in widget.creditNote!.creditNoteItems!) {
                            final itemId = invoiceItemModel.creditNoteItemId;

                            _formKey.currentState?.fields['item-name-$itemId']
                                ?.didChange(invoiceItemModel.item);
                            _formKey.currentState?.fields['quantity-$itemId']
                                ?.didChange(
                              invoiceItemModel.quantity?.toString() ?? '1',
                            );
                            _formKey.currentState?.fields['rate-$itemId']
                                ?.didChange(
                              invoiceItemModel.unitPrice?.toString() ?? '0.0',
                            );

                            // Calculate and set initial amount for this item based on model data
                            final amount = invoiceItemModel.totalPrice ??
                                ((invoiceItemModel.quantity ?? 0) *
                                    (invoiceItemModel.unitPrice ?? 0.0));
                            _formKey.currentState?.fields['amount-$itemId']
                                ?.didChange(amount.toStringAsFixed(2));
                          }

                          // Call _updateSummary() once after all item fields are populated.
                          // This will read the form's current item data and calculate all summary totals.
                          _updateSummary();

                          // _updateSummary calls setState, so an additional setState here might be redundant.
                        });
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Table Header
                          _buildDivider(
                            height: 70,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Row(
                                    children: [Text(context.l10n.itemDetails)],
                                  ),
                                ),
                                Expanded(
                                  child: Text(context.l10n.quantity),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(context.l10n.rate),
                                ),
                                Expanded(
                                  child: Text(context.l10n.tax),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(context.l10n.amount),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Rows
                          ...List<Widget>.generate(field.value!.length,
                              (index) {
                            final item = field.value![index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: const Color(0xFFE9ECEF)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  // Item Search Field
                                  Expanded(
                                    flex: 4,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: AppTypeAheadForm<Item>(
                                        name: 'item-name-$item',
                                        validator:
                                            FormBuilderValidators.required(),
                                        hintText:
                                            '${context.l10n.searchForAnItem}...',
                                        suggestionsCallback: (search) async {
                                          // This is the key logic for ad-hoc items.
                                          // Create a special "ad-hoc" item based on the user's input.
                                          // Its itemId MUST be null.
                                          final adHocItem = Item.empty()
                                              .copyWith(name: search);

                                          // Fetch existing items from your API
                                          final apiItems = await ref
                                              .read(
                                                quoteNotifierProvider.notifier,
                                              )
                                              .getItems(
                                                pageNumber: 1,
                                                query: search,
                                                pageSize: 20,
                                              );

                                          // Show the "Add new..." option first if the user has typed something.
                                          if (search.isNotEmpty) {
                                            return [adHocItem, ...apiItems];
                                          }
                                          return apiItems;
                                        },
                                        itemBuilder: (context, suggestion) {
                                          // Differentiate the UI for an ad-hoc item vs an existing one.
                                          if (suggestion.itemId == null) {
                                            return ListTile(
                                              leading: const Icon(
                                                Icons.add_circle_outline,
                                                color: Colors.purple,
                                              ),
                                              title: Text(
                                                suggestion.name,
                                              ),
                                            );
                                          }
                                          // Original builder for existing items from API
                                          return ListTile(
                                            title: Text(suggestion.name),
                                            subtitle: Text(
                                              'Rate: ${suggestion.salePrice.toStringAsFixed(2)}',
                                            ),
                                          );
                                        },
                                        selectionToTextTransformer:
                                            (suggestion) => suggestion.name,
                                        onSuggestionSelected: (suggestion) {
                                          // 1. Explicitly save the selected 'Item' object to the form's state.
                                          // This is the step that was missing.
                                          _formKey.currentState
                                              ?.fields['item-name-$item']
                                              ?.didChange(suggestion);

                                          // 2. Now perform your other side-effects, like updating the rate.
                                          _formKey.currentState?.patchValue({
                                            'rate-$item': suggestion.salePrice
                                                .toStringAsFixed(2),
                                          });

                                          // 3. Recalculate the amount for the row.
                                          _updateAmount(item);
                                        },
                                      ),
                                    ),
                                  ),

                                  // Quantity Field
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: AppTextForm<String>(
                                        name: 'quantity-$item',
                                        initialValue: '1',
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          // print('Quantity changed to: $value for item $item');
                                          if (value != null) {
                                            _updateAmount(item);
                                          }
                                        },
                                        validator:
                                            FormBuilderValidators.compose([
                                          FormBuilderValidators.required(),
                                          FormBuilderValidators.min(1),
                                        ]),
                                      ),
                                    ),
                                  ),

                                  // Rate Field
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: AppTextForm<String>(
                                        name: 'rate-$item',
                                        initialValue: '0.0',
                                        keyboardType: const TextInputType
                                            .numberWithOptions(
                                          decimal: true,
                                        ),
                                        onChanged: (value) {
                                          // print('Rate changed to: $value for item $item');
                                          if (value != null) {
                                            _updateAmount(item);
                                          }
                                        },
                                        validator:
                                            FormBuilderValidators.compose([
                                          FormBuilderValidators.required(),
                                          FormBuilderValidators.min(0),
                                        ]),
                                      ),
                                    ),
                                  ),

                                  // Tax Rate Field
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: AppTypeAheadForm<Tax>(
                                        decoration: const InputDecoration(
                                          suffixIcon: Icon(
                                            CupertinoIcons.chevron_down,
                                            color: AppColors.purple,
                                            weight: 16,
                                          ),
                                        ),
                                        name: 'tax-rate-$item',
                                        selectionToTextTransformer: (e) =>
                                            '${e.name} (${e.rate}%)',
                                        onSuggestionSelected: (suggestion) {
                                          _formKey.currentState
                                              ?.fields['tax-rate-$item']
                                              ?.didChange(suggestion);
                                          _updateAmount(item);
                                        },
                                        itemBuilder: (context, suggestion) {
                                          return ListTile(
                                            title: Text(
                                              '${suggestion.name} (${suggestion.rate}%)',
                                            ),
                                          );
                                        },
                                        suggestionsCallback: (String search) =>
                                            ref
                                                .read(taxRepoProvider)
                                                .getTaxes(
                                                  query: search,
                                                  pageSize: 20,
                                                  pageNumber: 1,
                                                )
                                                .then((value) => value.data),
                                      ),
                                    ),
                                  ),

                                  // Amount Field (read-only)
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: AppTextForm<String>(
                                        name: 'amount-$item',
                                        enabled: false, // Make it read-only
                                        keyboardType: const TextInputType
                                            .numberWithOptions(
                                          decimal: true,
                                        ),
                                        validator:
                                            FormBuilderValidators.compose([
                                          FormBuilderValidators.required(),
                                          FormBuilderValidators.min(0.0),
                                        ]),
                                      ),
                                    ),
                                  ),

                                  // Delete Button
                                  SizedBox(
                                    width: 48,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          field.didChange(
                                            [...field.value!..removeAt(index)],
                                          );
                                          _updateSummary();
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 20),
                          _buildDivider(height: 8),
                          const SizedBox(height: 20),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ///MARK:Add Item
                              Expanded(
                                child: Row(
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          field.didChange([
                                            ...field.value!,
                                            const Uuid().v4(),
                                          ]);
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.add,
                                            color: AppColors.purple,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            context.l10n.addNewRow,
                                            style: AppText.mediumSB.copyWith(
                                              color: AppColors.brandViolet,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Expanded(
                                child: Column(
                                  children: [
                                    //total items
                                    _buildItemTiles(
                                      label: context.l10n.totalItems,
                                      child: FormBuilderField<String>(
                                        name: 'total-items',
                                        builder:
                                            (FormFieldState<String?> field) {
                                          return Text(
                                            field.value?.toString() ?? '0',
                                            style: AppText.mediumSB.copyWith(
                                              fontSize: 20,
                                              color: AppColors.black,
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    //sub total
                                    _buildItemTiles(
                                      label: context.l10n.subTotal,
                                      child: FormBuilderField<String>(
                                        name: 'subtotal',
                                        builder:
                                            (FormFieldState<String?> field) {
                                          return Text(
                                            field.value?.toString() ?? '0.00',
                                            style: AppText.mediumSB.copyWith(
                                              fontSize: 20,
                                              color: AppColors.black,
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    //Service/shipping
                                    _buildItemTiles(
                                      label: context.l10n.serviceShipping,
                                      child: IntrinsicWidth(
                                        child: FormBuilderField<String>(
                                          name: 'shipping',
                                          initialValue: '0.00',
                                          builder: (shipping) {
                                            return Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  height: 42,
                                                  decoration: BoxDecoration(
                                                    color: AppColors.stormyBlue,
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(8),
                                                      bottomLeft:
                                                          Radius.circular(8),
                                                    ),
                                                    border: Border.all(
                                                      color:
                                                          AppColors.stormyBlue,
                                                    ),
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    currency,
                                                    style: AppText.xLargeM
                                                        .copyWith(
                                                      color: AppColors.white,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: DoubleSpinnerField(
                                                    min: 0,
                                                    style: AppText.xLargeM
                                                        .copyWith(
                                                      color: AppColors
                                                          .primaryColor,
                                                    ),
                                                    decoration: InputDecoration(
                                                      border: border,
                                                      errorBorder: border,
                                                      focusedBorder: border,
                                                      enabledBorder: border,
                                                      disabledBorder: border,
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      isDense: true,
                                                    ),
                                                    onChanged: (value) {
                                                      shipping.didChange(
                                                        value.toString(),
                                                      );
                                                      _updateSummary();
                                                    },
                                                    showButtons: false,
                                                    value: double.tryParse(
                                                          shipping.value
                                                                  ?.toString() ??
                                                              '0.0',
                                                        ) ??
                                                        0.0,
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ),

                                    //VAT/GST
                                    _buildItemTiles(
                                      label: context.l10n.vatGst,
                                      child: FormBuilderField<String>(
                                        name: 'tax-value',
                                        builder:
                                            (FormFieldState<String?> field) {
                                          return Text(
                                            field.value?.toString() ?? '0.00',
                                            style: AppText.mediumSB.copyWith(
                                              fontSize: 20,
                                              color: AppColors.black,
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    //Discount
                                    _buildItemTiles(
                                      label: context.l10n.discount,
                                      child: Row(
                                        children: [
                                          IntrinsicWidth(
                                            child: FormBuilderField<String>(
                                              name: 'discount-percent',
                                              initialValue: '0.00',
                                              builder: (discountPercent) {
                                                return Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                        8,
                                                      ),
                                                      height: 42,
                                                      decoration: BoxDecoration(
                                                        color: AppColors
                                                            .stormyBlue,
                                                        borderRadius:
                                                            const BorderRadius
                                                                .only(
                                                          topLeft:
                                                              Radius.circular(
                                                            8,
                                                          ),
                                                          bottomLeft:
                                                              Radius.circular(
                                                            8,
                                                          ),
                                                        ),
                                                        border: Border.all(
                                                          color: AppColors
                                                              .stormyBlue,
                                                        ),
                                                      ),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        '%',
                                                        style: AppText.xLargeM
                                                            .copyWith(
                                                          color:
                                                              AppColors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: DoubleSpinnerField(
                                                        min: 0,
                                                        style: AppText.xLargeM
                                                            .copyWith(
                                                          color: AppColors
                                                              .primaryColor,
                                                        ),
                                                        decoration:
                                                            InputDecoration(
                                                          border: border,
                                                          errorBorder: border,
                                                          focusedBorder: border,
                                                          enabledBorder: border,
                                                          disabledBorder:
                                                              border,
                                                          contentPadding:
                                                              EdgeInsets.zero,
                                                          isDense: true,
                                                        ),
                                                        onChanged: (value) {
                                                          discountPercent
                                                              .didChange(
                                                            value.toString(),
                                                          );
                                                          // When percent changes, clear the fixed amount discount
                                                          _formKey.currentState
                                                              ?.patchValue({
                                                            'discount-amount':
                                                                '0.00',
                                                          });
                                                          _updateSummary();
                                                        },
                                                        showButtons: false,
                                                        value: double.tryParse(
                                                              discountPercent
                                                                      .value
                                                                      ?.toString() ??
                                                                  '0.0',
                                                            ) ??
                                                            0.0,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          IntrinsicWidth(
                                            child: FormBuilderField<String>(
                                              name: 'discount-amount',
                                              initialValue: '0.00',
                                              builder: (discountAmount) {
                                                return Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                        8,
                                                      ),
                                                      height: 42,
                                                      decoration: BoxDecoration(
                                                        color: AppColors
                                                            .stormyBlue,
                                                        borderRadius:
                                                            const BorderRadius
                                                                .only(
                                                          topLeft:
                                                              Radius.circular(
                                                            8,
                                                          ),
                                                          bottomLeft:
                                                              Radius.circular(
                                                            8,
                                                          ),
                                                        ),
                                                        border: Border.all(
                                                          color: AppColors
                                                              .stormyBlue,
                                                        ),
                                                      ),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        currency,
                                                        style: AppText.xLargeM
                                                            .copyWith(
                                                          color:
                                                              AppColors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: DoubleSpinnerField(
                                                        min: 0,
                                                        style: AppText.xLargeM
                                                            .copyWith(
                                                          color: AppColors
                                                              .primaryColor,
                                                        ),
                                                        decoration:
                                                            InputDecoration(
                                                          border: border,
                                                          errorBorder: border,
                                                          focusedBorder: border,
                                                          enabledBorder: border,
                                                          disabledBorder:
                                                              border,
                                                          contentPadding:
                                                              EdgeInsets.zero,
                                                          isDense: true,
                                                        ),
                                                        onChanged: (value) {
                                                          discountAmount
                                                              .didChange(
                                                            value.toString(),
                                                          );
                                                          // When fixed amount changes, clear the percent discount
                                                          _formKey.currentState
                                                              ?.patchValue({
                                                            'discount-percent':
                                                                '0.00',
                                                          });
                                                          _updateSummary();
                                                        },
                                                        showButtons: false,
                                                        value: double.tryParse(
                                                              discountAmount
                                                                      .value
                                                                      ?.toString() ??
                                                                  '0.0',
                                                            ) ??
                                                            0.0,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    //Grand Total
                                    _buildItemTiles(
                                      labelColor: AppColors.black,
                                      label: context.l10n.grandTotal,
                                      child: FormBuilderField<String>(
                                        name: 'grand-total',
                                        builder:
                                            (FormFieldState<String?> field) {
                                          return Text(
                                            field.value?.toString() ?? '0.00',
                                            style: AppText.b28.copyWith(
                                              fontSize: 20,
                                              color: AppColors.black,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // Add Item Button

                          // Total Amount
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildDivider(height: 8),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(context.l10n.note, style: AppText.mediumSB),
                      ),
                      Expanded(
                        flex: 4,
                        child: AppTextForm<String>(
                          name: 'note',
                          hintText: context.l10n.enterNoteHere,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.l10n.termsAndConditions,
                          style: AppText.mediumSB,
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: AppTextForm<String>(
                          minLines: 3,
                          hintText: context.l10n.enterTermsAndConditionsHere,
                          name: 'terms_and_conditions',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Spacer(
                  flex: 4,
                ),
                Expanded(
                  child: AppButton(
                    style: ButtonStyles.secondary,
                    color: AppColors.primaryColor,
                    onPress: () {},
                    label: Text(
                      context.l10n.cancel,
                      style: AppText.heading5,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    color: AppColors.primaryColor,
                    onPress: () async {
                      if (_formKey.currentState?.saveAndValidate() ?? false) {
                        final formData = _formKey.currentState!.value;

                        // Validate required fields
                        if (formData['invoice'] == null) {
                          Alert.showSnackBar(
                            '${context.l10n.select} ${context.l10n.invoice}',
                            type: SnackBarType.error,
                          );
                          return;
                        }
                        if (formData['reason'] == null) {
                          Alert.showSnackBar(
                            'Please enter a reason',
                            type: SnackBarType.error,
                          );
                          return;
                        }
                        if (formData['reference'] == null) {
                          Alert.showSnackBar(
                            'Please enter a reference',
                            type: SnackBarType.error,
                          );
                          return;
                        }
                        if (formData['credit_note_date'] == null) {
                          Alert.showSnackBar(
                            'Please select a credit note date',
                            type: SnackBarType.error,
                          );
                          return;
                        }

                        // Get all invoice items

                        final items = formData['invoice_items'] as List<String>;
                        final creditNoteItems = <Map<String, dynamic>>[];

                        for (final itemId in items) {
                          final itemField = formData['item-name-$itemId'];
                          if (itemField != null && itemField is Item) {
                            // final itemName = formData['item-name-$itemId'] as Item;
                            final Map<String, dynamic> itemJson;
                            // Check if the item has a real itemId.
                            if (itemField.itemId != null) {
                              // It's an EXISTING item, so include 'item_id'.
                              itemJson = {
                                'item_id': itemField.itemId,
                                'quantity': int.tryParse(
                                      formData['quantity-$itemId']
                                              ?.toString() ??
                                          '0',
                                    ) ??
                                    0,
                                'unit_price': double.tryParse(
                                      formData['rate-$itemId']?.toString() ??
                                          '0.0',
                                    ) ??
                                    0.0,
                              };
                            } else {
                              // It's an AD-HOC item, so include 'item_name' instead.
                              itemJson = {
                                'item_name':
                                    itemField.name, // Use the item's name
                                'item_description':
                                    '', // You can add a description field if you want
                                'quantity': int.tryParse(
                                      formData['quantity-$itemId']
                                              ?.toString() ??
                                          '0',
                                    ) ??
                                    0,
                                'unit_price': double.tryParse(
                                      formData['rate-$itemId']?.toString() ??
                                          '0.0',
                                    ) ??
                                    0.0,
                              };
                            }

                            creditNoteItems.add(itemJson);
                          }
                        }

                        if (creditNoteItems.isEmpty) {
                          Alert.showSnackBar(
                            'Please add at least one item',
                            type: SnackBarType.error,
                          );
                          return;
                        }
                        final creditData = {
                          'invoice_id':
                              (formData['invoice'] as Invoice).invoiceId,
                          'reason': formData['reason'].toString(),
                          // 'billing_address': formData['billing_address'],
                          // 'shipping_address': formData['shipping_address'],
                          'reference': formData['reference'].toString(),
                          'credit_note_date':
                              (formData['credit_note_date'] as DateTime)
                                  .toIso8601String(),
                          'notes': formData['note']?.toString(),
                          'terms_and_conditions':
                              formData['terms_and_conditions']?.toString(),
                          'tax_total': double.tryParse(
                                formData['tax-value']?.toString() ?? '0.0',
                              ) ??
                              0.0,
                          'credit_note_code':
                              formData['credit_note']?.toString(),
                          'shipping_charges': double.tryParse(
                                formData['shipping']?.toString() ?? '0.0',
                              ) ??
                              0.0,
                          'discount_amount': double.tryParse(
                                formData['discount-amount']?.toString() ??
                                    '0.0',
                              ) ??
                              0.0,
                          'credit_note_items': creditNoteItems,
                          'grand_total': double.tryParse(
                                formData['grand-total']?.toString() ?? '0.0',
                              ) ??
                              0.0,
                        };
                        try {
                          if (widget.creditNote == null) {
                            await ref
                                .read(createCreditNotifierProvider.notifier)
                                .createCredit(creditData);
                            _formKey.currentState!.reset();
                          } else {
                            await ref
                                .read(createCreditNotifierProvider.notifier)
                                .editCredit(
                                  creditData,
                                  widget.creditNote!.creditNoteId!,
                                );
                            _formKey.currentState!.reset();
                          }

                        } catch (e) {
                          // Error is already handled in the notifier
                          debugPrint(e.toString());
                        }
                      }
                    },
                    label: Text(
                      context.l10n.save,
                      style: AppText.heading5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
