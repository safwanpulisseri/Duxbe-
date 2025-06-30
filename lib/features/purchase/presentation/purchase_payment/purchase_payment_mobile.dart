import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/purchase/purchase.dart';
import 'package:duxbe/features/staffs/staffs.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';

part 'payment_keypad.dart';
part 'purchase_success.dart';

class PurchasePaymentScreenMobile extends ConsumerStatefulWidget {
  const PurchasePaymentScreenMobile({super.key});

  @override
  ConsumerState<PurchasePaymentScreenMobile> createState() => _PurchasePaymentScreenMobileState();
}

class _PurchasePaymentScreenMobileState extends ConsumerState<PurchasePaymentScreenMobile> {
  final TextEditingController _supplierName = TextEditingController();
  final _formKey = GlobalKey<FormBuilderState>();
  final border = const OutlineInputBorder(
    borderRadius: BorderRadius.only(
      topRight: Radius.circular(8),
      bottomRight: Radius.circular(8),
    ),
    borderSide: BorderSide(color: AppColors.stormyBlue),
  );

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);
    final purchaseState = ref.watch(purchaseNotifierProvider);
    final purchaseNotifier = ref.watch(purchaseNotifierProvider.notifier);
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(context.l10n.cart),
        actions: [
          SizedBox(
            width: 200,
            child: FormBuilderField<EmployeeModel>(
              name: 'employee',
              initialValue: ref.read(authNotifierProvider).user,
              builder: (field) {
                return DropdownSearch<EmployeeModel>(
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    itemBuilder: (context, item, isSelected, selected) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: item.image != null ? NetworkImage(item.image!) : null,
                          backgroundColor: AppColors.primaryColor,
                          child: Text(item.name.substring(0, 1)),
                        ),
                        title: Text(item.name),
                        trailing: field.value?.employeeId == item.employeeId
                            ? const Icon(
                                Icons.check_circle_outline_outlined,
                                size: 20,
                                color: AppColors.green,
                              )
                            : null,
                      );
                    },
                  ),
                  selectedItem: field.value,
                  compareFn: (item, selectedItem) => item.employeeId == selectedItem.employeeId,
                  dropdownBuilder: (context, selectedItem) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            context.l10n.assignedTo,
                            style: AppText.largeM.copyWith(color: AppColors.primaryColor),
                          ),
                          const SizedBox(width: 10),
                          CircleAvatar(
                            backgroundImage: selectedItem?.image != null ? NetworkImage(selectedItem!.image!) : null,
                            backgroundColor: AppColors.primaryColor,
                            radius: 12,
                            child: Text(selectedItem?.name.substring(0, 1) ?? ''),
                          ),
                        ],
                      ),
                    ],
                  ),
                  decoratorProps: const DropDownDecoratorProps(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  validator: FormBuilderValidators.required(),
                  items: (text, d) => ref
                      .read(staffRepoProvider)
                      .getEmployees(pageSize: 100, pageNumber: 1, query: text)
                      .then((value) => value.data),
                  onChanged: (value) {
                    field.didChange(value);
                  },
                  itemAsString: (item) => item.name,
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.viewPaddingOf(context).bottom == 0 ? 24 : MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: AppButton(
          onPress: () {
            if (!_formKey.currentState!.saveAndValidate()) {
              return;
            }
            if (purchaseState.supplier == null) {
              Alert.showSnackBar(
                'Please Select a Supplier',
                type: SnackBarType.warning,
              );
              return;
            }

            if (purchaseState.purchaseItems.isEmpty) {
              Alert.showSnackBar(
                context.l10n.cartIsEmpty,
                type: SnackBarType.warning,
              );
              return;
            }

            context.pushNamed(AppRouter.purchasePaymentKeypad);
          },
          label: Text(context.l10n.payment, style: AppText.mediumB),
          color: AppColors.green,
        ),
      ),
      body: FormBuilder(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  cacheExtent: 1000,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0x00fff9f0),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(color: const Color(0xFFF6E9D4)),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info, color: Color(0xFFE19C34)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              context.l10n.youCanUpdateThePrice,
                              style: AppText.smallN.copyWith(color: const Color(0xFFE19C34)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: AppTypeAheadForm<Supplier>(
                            name: 'supplier',
                            secondaryLabel: context.l10n.supplier,
                            controller: _supplierName,
                            onSuggestionSelected: purchaseNotifier.updateSupplier,
                            onClear: () {
                              purchaseNotifier.updateSupplier(null);
                            },
                            selectionToTextTransformer: (e) => '${e.name}${', ${e.phone}'}',
                            itemBuilder: (context, suggestion) {
                              return ListTile(
                                title: Text(suggestion.name),
                                subtitle: Text(suggestion.phone),
                              );
                            },
                            suggestionsCallback: (String search) async {
                              return ref
                                  .read(supplierRepoProvider)
                                  .getSuppliers(
                                    pageSize: 12,
                                    pageNumber: 1,
                                    query: search,
                                  )
                                  .then((value) => value.data);
                            },
                            noItemsFoundBuilder: (context) {
                              return TextFieldTapRegion(
                                child: ListTile(
                                  onTap: () {
                                    showDialog<void>(
                                      context: context,
                                      builder: (context) {
                                        return AddSupplierDialog(
                                          supplierName: _supplierName.text,
                                        );
                                      },
                                    );
                                  },
                                  leading: const Icon(Icons.add_box_outlined),
                                  title: Text(context.l10n.addSupplier),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        FormAddButton(
                          icon: const Icon(Icons.add),
                          onTap: () async {
                            final supplier = await showDialog<Supplier>(
                              context: context,
                              builder: (context) {
                                return AddSupplierDialog(
                                  supplierName: _supplierName.text,
                                );
                              },
                            );
                            if (supplier != null) {
                              _formKey.currentState?.fields['supplier']?.didChange(supplier);
                              purchaseNotifier.updateSupplier(supplier);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppTextForm<String>(
                      name: 'purchase_invoice',
                      hintText: context.l10n.enterPurchaseNumberHere,
                      validator: FormBuilderValidators.required(),
                      initialValue: purchaseState.purchaseInvoice,
                      onChanged: (value) {
                        if (value != null) {
                          purchaseNotifier.updatePurchaseInvoice(value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    ...purchaseState.purchaseItems.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Slidable(
                            // The end action pane is the one at the right or the bottom side.
                            endActionPane: ActionPane(
                              extentRatio: 0.2,
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    purchaseNotifier.removeItem(e.item.itemId!);
                                  },
                                  backgroundColor: const Color(0xFFFF6161),
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: context.l10n.delete,
                                ),
                              ],
                            ),

                            key: ValueKey(e.item),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.only(right: 16),
                              child: Row(
                                children: [
                                  if (e.item.images.isNotEmpty)
                                    SizedBox(
                                      width: 100,
                                      height: 100,
                                      child: CachedNetworkImage(
                                        imageUrl: e.item.images
                                                .firstWhereOrNull(
                                                  (element) => element.isThumbnail,
                                                )
                                                ?.url ??
                                            e.item.images.first.url!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  else
                                    SizedBox(
                                      width: 100,
                                      height: 100,
                                      child: NameAbbrWidget(name: e.item.name),
                                    ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              e.item.name,
                                              style: AppText.mediumM.copyWith(
                                                color: AppColors.black,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Builder(
                                              builder: (context) {
                                                final purchasePrice = _formKey.currentState
                                                    ?.fields['unit-price-${e.item.itemId}']?.value as double?;
                                                return Text(
                                                  '${e.quantity * (purchasePrice ?? e.item.purchasePrice)} $currency',
                                                  style: AppText.smallN.copyWith(
                                                    color: AppColors.stormyBlue,
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          e.item.quantity.toString() +
                                              (e.item.unit?.shortName ?? e.item.unit?.name ?? ''),
                                          style: AppText.smallN.copyWith(
                                            color: AppColors.stormyBlue,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            FormBuilderField<double>(
                                              name: 'unit-price-${e.item.itemId}',
                                              initialValue: e.item.purchasePrice,
                                              validator: FormBuilderValidators.required(
                                                errorText: context.l10n.pleaseEnterUnitPrice,
                                              ),
                                              builder: (unitPrice) {
                                                return IntrinsicWidth(
                                                  child: DoubleSpinnerField(
                                                    style: AppText.mediumM,
                                                    decoration: InputDecoration(
                                                      isDense: true,
                                                      contentPadding: const EdgeInsets.only(
                                                        left: 16,
                                                      ),
                                                      prefixText: currency,
                                                      prefixStyle: AppText.mediumM.copyWith(
                                                        color: AppColors.stormyBlue,
                                                      ),
                                                      border: const OutlineInputBorder(
                                                        borderRadius: BorderRadius.all(
                                                          Radius.circular(
                                                            6,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    min: 0,
                                                    showButtons: false,
                                                    value: unitPrice.value ?? 0,
                                                    onChanged: (value) {
                                                      unitPrice.didChange(value);
                                                      purchaseNotifier.updateItemUnitPrice(
                                                        e.item.itemId!,
                                                        value,
                                                      );
                                                    },
                                                  ),
                                                );
                                              },
                                            ),
                                            const SizedBox(width: 16),
                                            IntrinsicWidth(
                                              child: CartDoubleSpinnerField(
                                                min: 1,
                                                value: e.quantity,
                                                style: AppText.mediumM,
                                                onChanged: (value) {
                                                  purchaseNotifier.updateItemQuantity(
                                                    e.item.itemId!,
                                                    value,
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    IntrinsicHeight(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  context.pop();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        CupertinoIcons.add_circled,
                                        color: AppColors.stormyBlue,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        context.l10n.addMoreItems,
                                        style: AppText.mediumN.copyWith(
                                          color: AppColors.stormyBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const VerticalDivider(
                              color: AppColors.primaryColor,
                              thickness: 2,
                              width: 2,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  purchaseNotifier.resetForm();
                                  _formKey.currentState?.reset();
                                  context.pop();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        CupertinoIcons.clear_circled,
                                        color: AppColors.stormyBlue,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        context.l10n.clearCart,
                                        style: AppText.mediumN.copyWith(
                                          color: AppColors.stormyBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.billDetails,
                      style: AppText.largeM.copyWith(color: AppColors.black),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.l10n.itemTotal,
                                style: AppText.mediumM.copyWith(color: AppColors.stormyBlue),
                              ),
                              Text(
                                purchaseState.purchaseItems.length.toString(),
                                style: AppText.mediumM.copyWith(color: AppColors.stormyBlue),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.l10n.subTotal,
                                style: AppText.mediumM.copyWith(color: AppColors.stormyBlue),
                              ),
                              Text(
                                purchaseState.subtotal.toString(),
                                style: AppText.mediumM.copyWith(
                                  color: AppColors.stormyBlue,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.l10n.serviceShipping,
                                style: AppText.mediumM.copyWith(color: AppColors.stormyBlue),
                              ),
                              IntrinsicWidth(
                                child: FormBuilderField<double>(
                                  name: 'shipping',
                                  initialValue: purchaseState.shipping,
                                  builder: (shipping) {
                                    return Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: AppColors.stormyBlue,
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(8),
                                              bottomLeft: Radius.circular(8),
                                            ),
                                            border: Border.all(
                                              color: AppColors.stormyBlue,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            currency,
                                            style: AppText.mediumB.copyWith(
                                              color: AppColors.white,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: SizedBox(
                                            height: 36,
                                            child: DoubleSpinnerField(
                                              min: 0,
                                              style: AppText.mediumB.copyWith(
                                                color: AppColors.stormyBlue,
                                              ),
                                              decoration: InputDecoration(
                                                border: border,
                                                errorBorder: border,
                                                focusedBorder: border,
                                                enabledBorder: border,
                                                disabledBorder: border,
                                                contentPadding: EdgeInsets.zero,
                                                isCollapsed: true,
                                                isDense: true,
                                              ),
                                              onChanged: (value) {
                                                purchaseNotifier.updateShipping(value);
                                                shipping.didChange(value);
                                              },
                                              showButtons: false,
                                              value: shipping.value ?? 0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.l10n.discount,
                                style: AppText.mediumM.copyWith(color: AppColors.stormyBlue),
                              ),
                              Row(
                                children: [
                                  IntrinsicWidth(
                                    child: FormBuilderField<double>(
                                      name: 'discount-percent',
                                      initialValue: purchaseState.discountPercent,
                                      builder: (discountPercent) {
                                        return Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              height: 36,
                                              decoration: BoxDecoration(
                                                color: AppColors.stormyBlue,
                                                borderRadius: const BorderRadius.only(
                                                  topLeft: Radius.circular(8),
                                                  bottomLeft: Radius.circular(8),
                                                ),
                                                border: Border.all(
                                                  color: AppColors.stormyBlue,
                                                ),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                '%',
                                                style: AppText.mediumB.copyWith(
                                                  color: AppColors.white,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: SizedBox(
                                                height: 36,
                                                child: DoubleSpinnerField(
                                                  min: 0,
                                                  style: AppText.mediumB.copyWith(
                                                    color: AppColors.stormyBlue,
                                                  ),
                                                  decoration: InputDecoration(
                                                    border: border,
                                                    errorBorder: border,
                                                    focusedBorder: border,
                                                    enabledBorder: border,
                                                    disabledBorder: border,
                                                    contentPadding: EdgeInsets.zero,
                                                    isDense: true,
                                                  ),
                                                  onChanged: (value) {
                                                    discountPercent.didChange(value);
                                                    purchaseNotifier.updateDiscountPercent(
                                                      value,
                                                    );
                                                    _formKey.currentState?.fields['discount-amount']?.didChange(
                                                      (purchaseState.subtotal * (value / 100)).toPrecision(2),
                                                    );
                                                  },
                                                  showButtons: false,
                                                  value: discountPercent.value ?? 0,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  IntrinsicWidth(
                                    child: FormBuilderField<double>(
                                      name: 'discount-amount',
                                      initialValue: purchaseState.discountAmount,
                                      builder: (discountAmount) {
                                        return Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              height: 36,
                                              decoration: BoxDecoration(
                                                color: AppColors.stormyBlue,
                                                borderRadius: const BorderRadius.only(
                                                  topLeft: Radius.circular(8),
                                                  bottomLeft: Radius.circular(8),
                                                ),
                                                border: Border.all(
                                                  color: AppColors.stormyBlue,
                                                ),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                currency,
                                                style: AppText.mediumB.copyWith(
                                                  color: AppColors.white,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: SizedBox(
                                                height: 36,
                                                child: DoubleSpinnerField(
                                                  min: 0,
                                                  style: AppText.mediumB.copyWith(
                                                    color: AppColors.stormyBlue,
                                                  ),
                                                  decoration: InputDecoration(
                                                    border: border,
                                                    errorBorder: border,
                                                    focusedBorder: border,
                                                    enabledBorder: border,
                                                    disabledBorder: border,
                                                    contentPadding: EdgeInsets.zero,
                                                    isDense: true,
                                                  ),
                                                  onChanged: (value) {
                                                    discountAmount.didChange(value);
                                                    purchaseNotifier.updateDiscountAmount(
                                                      value,
                                                    );
                                                    _formKey.currentState?.fields['discount-percent']?.didChange(
                                                      discountAmount.value != null && purchaseState.subtotal > 0
                                                          ? ((discountAmount.value! / purchaseState.subtotal) * 100)
                                                              .toPrecision(2)
                                                          : 0,
                                                    );
                                                  },
                                                  showButtons: false,
                                                  value: discountAmount.value ?? 0,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.l10n.grandTotal,
                                style: AppText.mediumM.copyWith(color: AppColors.stormyBlue),
                              ),
                              Text(
                                '$currency ${purchaseState.grandTotal.toStringAsFixed(2)}',
                                style: AppText.mediumM.copyWith(
                                  color: AppColors.stormyBlue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ).withSpacing(spacing: 12),
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
