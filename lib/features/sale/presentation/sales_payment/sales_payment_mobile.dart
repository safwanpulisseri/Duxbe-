import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/features/sale/sale.dart';
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
import 'package:intl/intl.dart'; // For date formatting

part 'mobile_hold_bill_dialog.dart';
part 'payment_keypad.dart';
part 'sales_success.dart';

class SalesPaymentScreenMobile extends ConsumerStatefulWidget {
  const SalesPaymentScreenMobile({super.key});

  @override
  ConsumerState<SalesPaymentScreenMobile> createState() => _SalesPaymentScreenMobileState();
}

class _SalesPaymentScreenMobileState extends ConsumerState<SalesPaymentScreenMobile> {
  final TextEditingController _customerName = TextEditingController();
  final _formKey = GlobalKey<FormBuilderState>();
  final border = const OutlineInputBorder(
    borderRadius: BorderRadius.only(
      topRight: Radius.circular(8),
      bottomRight: Radius.circular(8),
    ),
    borderSide: BorderSide(color: AppColors.stormyBlue),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        // _customerName.text = salesState.customer?.name ?? '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);
    final salesState = ref.watch(salesNotifierProvider);
    final salesNotifier = ref.watch(salesNotifierProvider.notifier);
    final branch = ref.watch(businessNotifierProvider);
    final l10n = AppLocalizations.of(context);

    // Localization fallbacks
    final cartIsEmptyText = l10n.cartIsEmpty;
    final orderModeWarningText = l10n.orderModeIsNotAvailableForWalkInCustomer;
    final paymentText = l10n.payment;
    final holdBillText = l10n.holdBill;
    final cartIsEmptyToHoldText = l10n.cartIsEmptyCannotHold;
    final recallBillBaseText = l10n.recallBill;
    final walkinCustomerWarningText = l10n.walkInCustomerIsNotAllowedInThisBranch;
    String recallBillButtonText(int count) {
      try {
        return '$recallBillBaseText ($count)';
      } catch (e) {
        return '$recallBillBaseText ($count)';
      }
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        title: Text(l10n.cart),
        actions: [
          SizedBox(
            width: 200,
            child: FormBuilderField<EmployeeModel>(
              name: 'employee',
              initialValue: salesState.employee ?? ref.read(authNotifierProvider).user,
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
                          Text(context.l10n.assignedTo, style: AppText.largeM.copyWith(color: AppColors.primaryColor)),
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
                    salesNotifier.updateEmployee(value);
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
          top: 6,
          bottom: MediaQuery.viewPaddingOf(context).bottom == 0 ? 12 : MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppButton(
              onPress: () {
                if (!_formKey.currentState!.saveAndValidate()) {
                  return;
                }
                try {
                  if (salesState.customer == null && !(branch?.allowWalkinCustomer ?? false)) {
                    throw AppException(
                      salesState.orderMode
                          ? AppRouter.l10n.customerRequiredOrder
                          : AppRouter.l10n.walkinCustomerIsNotAllowed,
                    );
                  }

                  if (salesState.saleItems.isEmpty) {
                    throw AppException(AppRouter.l10n.pleaseSelectAtLeastOneItem);
                  }

                  if (salesState.saleItems.any((e) => e.quantity == 0 || e.unitPrice == 0)) {
                    throw AppException(AppRouter.l10n.quantityOrUnitPriceCannotBeZero);
                  }
                  context.pushNamed(AppRouter.salePaymentKeypad);
                } on Exception catch (e) {
                  Alert.showSnackBar(
                    e.toString(),
                    type: SnackBarType.warning,
                  );
                }
              },
              label: Text(paymentText, style: AppText.mediumB),
              color: AppColors.green,
            ),
            const SizedBox(height: 10),
            AppButton(
              style: ButtonStyles.secondary,
              onPress: () {
                if (salesState.saleItems.isEmpty) {
                  Alert.showSnackBar(
                    cartIsEmptyToHoldText,
                    type: SnackBarType.warning,
                  );
                  return;
                }

                final formData = _formKey.currentState!.instantValue;
                final cartToHold = {
                  'held_time': DateTime.now().toIso8601String(),
                  'saleItems': salesState.saleItems.map((si) => si.toJson()).toList(),
                  'customer': salesState.customer?.toJson(),
                  'employee': salesState.employee?.toJson(),
                  'shipping': formData['shipping'] ?? salesState.shipping,
                  'discount-percent': formData['discount-percent'] ?? salesState.discountPercent,
                  'discount-amount': formData['discount-amount'] ?? salesState.discountAmount,
                  'orderMode': salesState.orderMode,
                  'customFieldValues': salesState.customFieldValues,
                  'grandTotal': salesState.grandTotal,
                };

                salesNotifier
                  ..holdCart(cartToHold)
                  ..resetForm();
                _formKey.currentState?.reset();
                _customerName.clear();
                context.pop();
              },
              label: Text(holdBillText),
            ),
            const SizedBox(height: 10),
            if (salesState.heldCarts.isNotEmpty) ...[
              AppButton(
                style: ButtonStyles.secondary,
                onPress: () async {
                  final result = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (dialogContext) => Consumer(
                      builder: (context, ref, child) {
                        return MobileHoldBillDialog(
                          onDelete: (cartData) {},
                          onRecall: (cartData) {},
                        );
                      },
                    ),
                  );

                  if (result != null) {
                    final recalledCartData = result;
                    salesNotifier.recallCart(recalledCartData);

                    final newSalesState = ref.read(salesNotifierProvider);

                    _formKey.currentState?.reset();

                    _formKey.currentState?.patchValue({
                      'shipping': newSalesState.shipping,
                      'discount-percent': newSalesState.discountPercent,
                      'discount-amount': newSalesState.discountAmount,
                    });

                    if (newSalesState.customer?.phone != null) {
                      _customerName.text =
                          '${newSalesState.customer!.name}${newSalesState.customer!.phone!.isNotEmpty ? ', ${newSalesState.customer!.phone}' : ''}';
                      _formKey.currentState?.fields['customer']?.didChange(newSalesState.customer);
                    } else {
                      _customerName.clear();
                      _formKey.currentState?.fields['customer']?.didChange(null);
                    }

                    for (final saleItem in newSalesState.saleItems) {
                      _formKey.currentState?.fields['unit-price-${saleItem.item.itemId}']
                          ?.didChange(saleItem.unitPrice);
                    }

                    setState(() {});
                    Alert.showSnackBar(
                      'Bill recalled successfully.',
                      type: SnackBarType.success,
                    );
                  }
                },
                label: Text(recallBillButtonText(salesState.heldCarts.length)),
              ),
            ],
          ],
        ),
      ),
      body: FormBuilder(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          child: AppTypeAheadForm<Customer>(
                            name: 'customer',
                            secondaryLabel: context.l10n.customer,
                            initialValue: salesState.customer,
                            controller: _customerName,
                            selectionToTextTransformer: (e) => '${e.name}${', ${e.phone ?? 'N/A'} '}',
                            itemBuilder: (context, suggestion) {
                              return ListTile(
                                title: Text(suggestion.name),
                                subtitle: suggestion.phone == null ? null : Text(suggestion.phone!),
                              );
                            },
                            suggestionsCallback: (String search) async {
                              return ref
                                  .read(customerRepoProvider)
                                  .getCustomers(
                                    pageSize: 12,
                                    pageNumber: 1,
                                    query: search,
                                  )
                                  .then((value) => value.data);
                            },
                            onSuggestionSelected: salesNotifier.updateCustomer,
                            onClear: () {
                              salesNotifier.updateCustomer(null);
                            },
                            noItemsFoundBuilder: (context) {
                              return TextFieldTapRegion(
                                child: ListTile(
                                  onTap: () {
                                    showDialog<void>(
                                      context: context,
                                      builder: (context) {
                                        return AddCustomerDialog(
                                          customerName: _customerName.text,
                                        );
                                      },
                                    );
                                  },
                                  leading: const Icon(Icons.add_box_outlined),
                                  title: Text(context.l10n.addCustomer),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        FormAddButton(
                          icon: const Icon(Icons.add),
                          onTap: () async {
                            final customer = await showDialog<Customer>(
                              context: context,
                              builder: (context) {
                                return AddCustomerDialog(
                                  customerName: _customerName.text,
                                );
                              },
                            );
                            if (customer != null) {
                              _formKey.currentState?.fields['customer']?.didChange(customer);
                              salesNotifier.updateCustomer(customer);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...salesState.saleItems.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Slidable(
                            endActionPane: ActionPane(
                              extentRatio: 0.2,
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    salesNotifier.removeItem(e.item.itemId!);
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                e.item.name,
                                                style: AppText.mediumM.copyWith(color: AppColors.black),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Builder(
                                              builder: (context) {
                                                final salePrice = _formKey.currentState
                                                    ?.fields['unit-price-${e.item.itemId}']?.value as double?;
                                                return Text(
                                                  '${e.quantity * (salePrice ?? e.item.salePrice)} $currency',
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
                                        ...e.selectedSubServices
                                            .map(
                                              (e) => Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    e.name,
                                                    style: AppText.smallN.copyWith(
                                                      color: AppColors.grey,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    e.additionalPrice.toString(),
                                                    style: AppText.smallN.copyWith(
                                                      color: AppColors.stormyBlue,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                            .expand(
                                              (e) => [
                                                e,
                                                const SizedBox(height: 4),
                                              ],
                                            ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            FormBuilderField<double>(
                                              name: 'unit-price-${e.item.itemId}',
                                              initialValue: e.item.salePrice,
                                              validator: FormBuilderValidators.required(
                                                errorText: context.l10n.pleaseEnterUnitPrice,
                                              ),
                                              builder: (unitPrice) {
                                                return ConstrainedBox(
                                                  constraints: const BoxConstraints(
                                                    maxWidth: 100,
                                                  ),
                                                  child: IntrinsicWidth(
                                                    child: DoubleSpinnerField(
                                                      style: AppText.mediumM,
                                                      decoration: InputDecoration(
                                                        isDense: true,
                                                        contentPadding: const EdgeInsets.only(left: 16),
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
                                                      showButtons: false,
                                                      value: unitPrice.value ?? e.unitPrice,
                                                      min: 0,
                                                      onChanged: (value) {
                                                        if (value >= 0) {
                                                          unitPrice.didChange(value);
                                                          salesNotifier.updateItemUnitPrice(
                                                            e.item.itemId!,
                                                            value,
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            const SizedBox(width: 16),
                                            IntrinsicWidth(
                                              child: CartDoubleSpinnerField(
                                                keyboardType: const TextInputType.numberWithOptions(
                                                  decimal: true,
                                                ),
                                                min: 1,
                                                value: e.quantity,
                                                style: AppText.mediumM,
                                                onChanged: (value) async {
                                                  final allowSalesWhenOutOfStock = ref
                                                          .read(
                                                            businessNotifierProvider,
                                                          )
                                                          ?.allowSalesWhenOutOfStock ??
                                                      false;
                                                  if (value > e.item.stockQuantity &&
                                                      !allowSalesWhenOutOfStock &&
                                                      e.item.itemType == ItemType.goods) {
                                                    Alert.showSnackBar(
                                                      '${e.item.name} is ${context.l10n.outOfStock}',
                                                      type: SnackBarType.warning,
                                                    );
                                                    setState(() {});
                                                    return;
                                                  }

                                                  e.quantity = value;
                                                  salesNotifier.updateItemQuantity(
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
                                  salesNotifier.resetForm();
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
                    Text(context.l10n.billDetails, style: AppText.largeM.copyWith(color: AppColors.black)),
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
                                salesState.saleItems.length.toString(),
                                style: AppText.mediumM.copyWith(color: AppColors.stormyBlue),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(context.l10n.subTotal, style: AppText.mediumM.copyWith(color: AppColors.stormyBlue)),
                              Text(
                                salesState.subtotal.toString(),
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
                                  initialValue: salesState.shipping,
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
                                                salesNotifier.updateShipping(value);
                                                shipping.didChange(value);
                                              },
                                              showButtons: false,
                                              value: shipping.value ?? salesState.shipping,
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
                                      initialValue: salesState.discountPercent,
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
                                                    salesNotifier.updateDiscountPercent(
                                                      value,
                                                    );
                                                    _formKey.currentState?.fields['discount-amount']?.didChange(
                                                      (ref
                                                                  .read(
                                                                    salesNotifierProvider,
                                                                  )
                                                                  .subtotal *
                                                              (value / 100))
                                                          .toPrecision(2),
                                                    );
                                                  },
                                                  showButtons: false,
                                                  value: discountPercent.value ?? salesState.discountPercent,
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
                                      initialValue: salesState.discountAmount,
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
                                                    salesNotifier.updateDiscountAmount(
                                                      value,
                                                    );
                                                    _formKey.currentState?.fields['discount-percent']?.didChange(
                                                      ref
                                                                  .read(
                                                                    salesNotifierProvider,
                                                                  )
                                                                  .subtotal >
                                                              0
                                                          ? ((value /
                                                                      ref
                                                                          .read(
                                                                            salesNotifierProvider,
                                                                          )
                                                                          .subtotal) *
                                                                  100)
                                                              .toPrecision(2)
                                                          : 0,
                                                    );
                                                  },
                                                  showButtons: false,
                                                  value: discountAmount.value ?? salesState.discountAmount,
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
                              Text(context.l10n.taxAmount,
                                  style: AppText.mediumM.copyWith(color: AppColors.stormyBlue)),
                              Text(
                                salesState.taxTotal.toStringAsFixed(2),
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
                                context.l10n.grandTotal,
                                style: AppText.mediumM.copyWith(color: AppColors.stormyBlue),
                              ),
                              Text(
                                '$currency ${salesState.grandTotal.toStringAsFixed(2)}',
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
