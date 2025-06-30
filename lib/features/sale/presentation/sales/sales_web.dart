import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/features/reservations/controller/table/table_notifier.dart';
import 'package:duxbe/features/reservations/domain/models/table/table_model.dart'
    as ts show Table;
import 'package:duxbe/features/sale/presentation/sales/service_selection_dialog.dart';
import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/features/staffs/staffs.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class SalesScreenWeb extends ConsumerStatefulWidget {
  const SalesScreenWeb({super.key});

  @override
  ConsumerState<SalesScreenWeb> createState() => _SalesScreenWebState();
}

class _SalesScreenWebState extends ConsumerState<SalesScreenWeb> {
  final _formKey = GlobalKey<FormBuilderState>();
  final TextEditingController _customerName = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 500);
  void _clear() {
    if (!mounted) return;
    if (GoRouter.of(AppRouter.rootContext)
            .routerDelegate
            .currentConfiguration
            .uri
            .queryParameters['clear'] ==
        'true') {
      debugPrint('------->>>>>>>clear is true');
      _customerName.clear();
      _formKey.currentState?.fields['customer_name']?.didChange('');
      _formKey.currentState?.reset();
      // Reset the sales state through the notifier
      ref.read(salesNotifierProvider.notifier).resetForm();

      // Remove the clear parameter from URL to prevent multiple resets
      GoRouter.of(context).goNamed(AppRouter.pos);
    }
  }

  @override
  void initState() {
    GoRouter.of(AppRouter.rootContext).routerDelegate.addListener(_clear);
    super.initState();
  }

  // @override
  // void dispose() {
  //   GoRouter.of(AppRouter.rootContext).routerDelegate.removeListener(_clear);
  //   super.dispose();
  // }

  final controller = MultiSelectController<ItemCategory>();

  @override
  Widget build(BuildContext context) {
    final salesNotifier = ref.watch(salesNotifierProvider.notifier);
    final salesState = ref.watch(salesNotifierProvider);
    final orderMode = GoRouter.of(context)
        .routerDelegate
        .currentConfiguration
        .uri
        .queryParameters['order_mode'];
    final business = ref.read(businessNotifierProvider);
    return FormBuilder(
      key: _formKey,
      child: switch (ref.watch(authNotifierProvider).status) {
        AuthStatus.success => Container(
            color: Colors.transparent,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AppToggleForm(
                        activeColor: AppColors.green,
                        mainAxisAlignment: MainAxisAlignment.end,
                        name: 'order_mode',
                        hint: context.l10n.orderMode,
                        initialValue: business?.businessType ==
                                BusinessType.foodAndBeverage
                            ? true
                            : orderMode == 'true',
                        onChanged: (v) {
                          salesNotifier.updateOrderMode(orderMode: v ?? false);
                        },
                      ),
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: AppTextForm<String>(
                                  name: 'search',
                                  hintText:
                                      context.l10n.enterNameOrSerialNumber,
                                  onChanged: (v) {
                                    _debouncer.run(() {
                                      salesNotifier.setFilter(query: v);
                                    });
                                  },
                                  prefixIcon: IconButton(
                                    onPressed: () async {
                                      final res = await SimpleBarcodeScanner
                                          .scanBarcode(
                                        context,
                                        isShowFlashIcon: true,
                                        delayMillis: 2000,
                                      );
                                      if (res != null) {
                                        _formKey.currentState?.fields['search']
                                            ?.didChange(res);
                                      }
                                    },
                                    icon: const Icon(Icons.qr_code_2_outlined),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              AppButton.icon(
                                icon: const Icon(Icons.add),
                                onPress: () {
                                  context.pushNamed(AppRouter.createItem);
                                },
                                label: Text(AppRouter.l10n.addItem),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          decoration: AppStyles.boxDecoration.copyWith(
                            color: const Color(0xffF2F2F3),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xffE3E3E7)),
                          ),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(5),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  salesNotifier.setFilter(type: ItemType.goods);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: salesState.selectedItemType ==
                                            ItemType.goods
                                        ? AppColors.primaryColor
                                        : const Color(0xffF2F2F3),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    context.l10n.goods,
                                    style: AppText.mediumM.copyWith(
                                      color: salesState.selectedItemType ==
                                              ItemType.goods
                                          ? AppColors.white
                                          : const Color(0xff7D7F88),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  salesNotifier.setFilter(
                                    type: ItemType.services,
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: salesState.selectedItemType ==
                                            ItemType.services
                                        ? AppColors.primaryColor
                                        : const Color(0xffF2F2F3),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    context.l10n.services,
                                    style: AppText.mediumM.copyWith(
                                      color: salesState.selectedItemType ==
                                              ItemType.services
                                          ? AppColors.white
                                          : const Color(0xff7D7F88),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      FormBuilderField<List<ItemCategory>>(
                        name: 'category',
                        onChanged: (value) {
                          salesNotifier.setFilter(selectedCategories: value);
                        },
                        builder: (field) {
                          return Container(
                            height: 54,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.outlineGrey.withOpacity(0.2),
                              ),
                            ),
                            child: PagedListView(
                              scrollDirection: Axis.horizontal,
                              pagingController:
                                  salesState.categoryPagingController!,
                              builderDelegate:
                                  PagedChildBuilderDelegate<ItemCategory>(
                                itemBuilder: (context, item, index) {
                                  final isSelected =
                                      field.value?.contains(item) ?? false;
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      left: index == 0 ? 8 : 4,
                                      right: 4,
                                      top: 6,
                                      bottom: 6,
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          if (isSelected) {
                                            field.didChange(
                                              field.value
                                                  ?.where(
                                                    (e) =>
                                                        e.itemCategoryId !=
                                                        item.itemCategoryId,
                                                  )
                                                  .toList(),
                                            );
                                          } else {
                                            field.didChange(
                                              [...?field.value, item],
                                            );
                                          }
                                        },
                                        borderRadius: BorderRadius.circular(20),
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppColors.primaryColor
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: isSelected
                                                  ? AppColors.primaryColor
                                                  : AppColors.outlineGrey
                                                      .withOpacity(0.5),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                item.name,
                                                style:
                                                    AppText.mediumSB.copyWith(
                                                  color: isSelected
                                                      ? AppColors.white
                                                      : AppColors.stormyBlue,
                                                ),
                                              ),
                                              if (isSelected) ...[
                                                const SizedBox(width: 6),
                                                const Icon(
                                                  Icons.check_circle_rounded,
                                                  size: 16,
                                                  color: AppColors.white,
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      // MultiDropdown<ItemCategory>(
                      //   items: salesState.categories.map((e) => DropdownItem(value: e, label: e.name)).toList(),
                      //   controller: controller,
                      //   searchEnabled: true,
                      //   chipDecoration: const ChipDecoration(
                      //     backgroundColor: Colors.yellow,
                      //     runSpacing: 2,
                      //     spacing: 10,
                      //   ),
                      //   fieldDecoration: FieldDecoration(
                      //     hintText: 'All',
                      //     hintStyle: const TextStyle(color: Colors.black87),
                      //     showClearIcon: false,
                      //     border: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(12),
                      //       borderSide: const BorderSide(color: Colors.grey),
                      //     ),
                      //     focusedBorder: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(12),
                      //       borderSide: const BorderSide(
                      //         color: Colors.black87,
                      //       ),
                      //     ),
                      //   ),
                      //   onSearchChange: (value) async {
                      //     await salesNotifier.setCategories(value);
                      //     setState(() {});
                      //   },
                      //   dropdownDecoration: const DropdownDecoration(
                      //     marginTop: 2,
                      //     maxHeight: 500,
                      //   ),
                      //   dropdownItemDecoration: DropdownItemDecoration(
                      //     selectedIcon: const Icon(Icons.check_box, color: Colors.green),
                      //     disabledIcon: Icon(Icons.lock, color: Colors.grey.shade300),
                      //   ),
                      //   validator: (value) {
                      //     if (value == null || value.isEmpty) {
                      //       return 'Please select a country';
                      //     }
                      //     return null;
                      //   },
                      //   onSelectionChange: (selectedItems) {
                      //     salesNotifier.setFilter(selectedCategories: selectedItems.toList());
                      //   },
                      // ),
                      Expanded(
                        child: Container(
                          decoration:
                              AppStyles.boxDecoration.copyWith(boxShadow: []),
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                context.l10n.chooseItem,
                                style: AppText.xLargeM,
                              ),
                              const SizedBox(height: 20),
                              Expanded(
                                child: CustomScrollView(
                                  slivers: <Widget>[
                                    PagedSliverGrid<int, Item>(
                                      builderDelegate:
                                          PagedChildBuilderDelegate<Item>(
                                        noItemsFoundIndicatorBuilder:
                                            (context) =>
                                                const NoDataViewWidget(),
                                        itemBuilder: (context, item, index) =>
                                            ItemCard(
                                          item: item,
                                          type: ItemCardType.sale,
                                          onTap: () async {
                                            List<SubService>? selectedServices;
                                            if (item.itemType ==
                                                ItemType.services) {
                                              if (item.subServices.isNotEmpty) {
                                                selectedServices =
                                                    await showDialog<
                                                        List<SubService>>(
                                                  context: context,
                                                  useRootNavigator: false,
                                                  builder: (
                                                    BuildContext dialogContext,
                                                  ) =>
                                                      ServiceSelectionDialog(
                                                    item: item,
                                                  ),
                                                );
                                              }
                                            }

                                            final quantity = _formKey
                                                    .currentState
                                                    ?.fields[
                                                        'quantity-${item.itemId}']
                                                    ?.value as double? ??
                                                0;
                                            if (quantity >
                                                    item.stockQuantity - 1 &&
                                                !(business
                                                        ?.allowSalesWhenOutOfStock ??
                                                    false) &&
                                                item.itemType ==
                                                    ItemType.goods &&
                                                item.inventoryEnabled) {
                                              Alert.showSnackBar(
                                                '${item.name} is ${AppRouter.l10n.outOfStock}',
                                                type: SnackBarType.warning,
                                              );
                                              return;
                                            }

                                            salesNotifier.addItem(
                                              item,
                                              selectedServices:
                                                  selectedServices,
                                            );
                                          },
                                        ),
                                      ),
                                      pagingController:
                                          salesState.pagingController!,
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4,
                                        crossAxisSpacing: 20,
                                        mainAxisSpacing: 20,
                                        childAspectRatio: 8 / 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateTime.now().toInvoiceFormat,
                            style: AppText.mediumSB,
                          ),
                          SizedBox(
                            width: 200,
                            child: FormBuilderField<EmployeeModel>(
                              name: 'employee',
                              initialValue: ref.read(authNotifierProvider).user,
                              onChanged: salesNotifier.updateEmployee,
                              builder: (field) {
                                return DropdownSearch<EmployeeModel>(
                                  popupProps: PopupProps.menu(
                                    showSearchBox: true,
                                    itemBuilder:
                                        (context, item, isSelected, selected) {
                                      return ListTile(
                                        leading: CircleAvatar(
                                          backgroundImage: item.image != null
                                              ? NetworkImage(item.image!)
                                              : null,
                                          backgroundColor:
                                              AppColors.primaryColor,
                                          child:
                                              Text(item.name.substring(0, 1)),
                                        ),
                                        title: Text(item.name),
                                        trailing: field.value?.employeeId ==
                                                item.employeeId
                                            ? const Icon(
                                                Icons
                                                    .check_circle_outline_outlined,
                                                size: 20,
                                                color: AppColors.green,
                                              )
                                            : null,
                                      );
                                    },
                                  ),
                                  selectedItem: field.value,
                                  compareFn: (item, selectedItem) =>
                                      item.employeeId ==
                                      selectedItem.employeeId,
                                  dropdownBuilder: (context, selectedItem) =>
                                      Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const Icon(
                                        CupertinoIcons.person_circle,
                                        size: 20,
                                        color: AppColors.brandViolet,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        context.l10n.assigned,
                                        style: AppText.largeM.copyWith(
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      CircleAvatar(
                                        backgroundImage: selectedItem?.image !=
                                                null
                                            ? NetworkImage(selectedItem!.image!)
                                            : null,
                                        backgroundColor: AppColors.primaryColor,
                                        child: Text(
                                          selectedItem?.name.substring(0, 1) ??
                                              '',
                                        ),
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
                                      .getEmployees(
                                        pageSize: 100,
                                        pageNumber: 1,
                                        query: text,
                                      )
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
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Stack(
                              alignment: Alignment.centerRight,
                              children: [
                                AppTypeAheadForm<Customer>(
                                  name: 'customer',
                                  validator: FormBuilderValidators.compose([
                                    if (!(business?.allowWalkinCustomer ??
                                        false))
                                      FormBuilderValidators.required(
                                        errorText: context
                                            .l10n.walkinCustomerIsNotAllowed,
                                      ),
                                    if (_formKey.currentState
                                            ?.fields['order_mode']?.value ==
                                        true)
                                      FormBuilderValidators.required(
                                        errorText:
                                            context.l10n.customerRequiredOrder,
                                      ),
                                  ]),
                                  initialValue: salesState.customer,
                                  selectionToTextTransformer: (e) =>
                                      '${e.name}${', ${e.phone ?? 'N/A'}'}',
                                  itemBuilder: (context, suggestion) {
                                    return ListTile(
                                      title: Text(suggestion.name),
                                      subtitle: suggestion.phone == null
                                          ? null
                                          : Text(suggestion.phone!),
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
                                  onSuggestionSelected:
                                      salesNotifier.updateCustomer,
                                  noItemsFoundBuilder: (context) {
                                    return TextFieldTapRegion(
                                      child: ListTile(
                                        onTap: () async {
                                          final customer =
                                              await showDialog<Customer>(
                                            context: context,
                                            builder: (context) {
                                              return AddCustomerDialog(
                                                customerName:
                                                    _customerName.text,
                                              );
                                            },
                                          );
                                          if (customer != null) {
                                            _formKey.currentState
                                                ?.fields['customer']
                                                ?.didChange(customer);
                                            salesNotifier
                                                .updateCustomer(customer);
                                          }
                                        },
                                        leading:
                                            const Icon(Icons.add_box_outlined),
                                        title: Text(context.l10n.addCustomer),
                                      ),
                                    );
                                  },
                                  onClear: () {
                                    salesNotifier.updateCustomer(null);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          AppButton.icon(
                            icon: const Icon(Icons.add),
                            onPress: () async {
                              final customer = await showDialog<Customer>(
                                context: context,
                                builder: (context) {
                                  return AddCustomerDialog(
                                    customerName: _customerName.text,
                                  );
                                },
                              );
                              if (customer != null) {
                                _formKey.currentState?.fields['customer']
                                    ?.didChange(customer);
                                salesNotifier.updateCustomer(customer);
                              }
                            },
                            label: Text(context.l10n.addCustomer),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (ref.watch(businessNotifierProvider)?.businessType ==
                          BusinessType.foodAndBeverage) ...[
                        AppDropDownForm<ts.Table>(
                          label: null,
                          name: 'table',
                          decoration:
                              InputDecoration(labelText: AppRouter.l10n.table),
                          items: ref
                              .watch(tableNotifierProvider)
                              .tables
                              .map((table) {
                            final isReserved = table.status == 'reserved' ||
                                table.status == 'billed';
                            return DropDownItems<ts.Table>(
                              enabled: !isReserved,
                              value: table,
                              child: Row(
                                children: [
                                  Text(table.name),
                                  const SizedBox(width: 10),
                                  if (isReserved)
                                    const Icon(
                                      Icons.lock_outline,
                                      size: 16,
                                      color: AppColors.outlineGrey,
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              ref
                                  .read(salesNotifierProvider.notifier)
                                  .updateSelectedTable(value);
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 10),
                      const Expanded(child: _ItemTiles()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        _ => const SizedBox(),
      },
    );
  }
}

class _ItemTiles extends ConsumerStatefulWidget {
  const _ItemTiles();

  @override
  ConsumerState<_ItemTiles> createState() => _ItemTilesState();
}

class _ItemTilesState extends ConsumerState<_ItemTiles> {
  final Set<String> _itemsWithOpenNotes = {};
  final _addItemFormKey = GlobalKey<FormBuilderState>();

  Row _dataRow({required String label, required Widget child}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppText.xLargeM.copyWith(color: AppColors.outlineGrey),
          ),
          child,
        ],
      );
  final border = const OutlineInputBorder(
    borderRadius: BorderRadius.only(
      topRight: Radius.circular(8),
      bottomRight: Radius.circular(8),
    ),
    borderSide: BorderSide(color: AppColors.stormyBlue),
  );

  @override
  Widget build(BuildContext context) {
    final salesNotifier = ref.watch(salesNotifierProvider.notifier);
    final salesState = ref.watch(salesNotifierProvider);
    final formKey = FormBuilder.of(context);
    final currency = ref.watch(currencyProvider);
    final businessType = ref.watch(businessNotifierProvider)?.businessType;

    return FormBuilderField<List<Item>>(
      name: 'items',
      onReset: salesNotifier.resetForm,
      // validator: FormBuilderValidators.notEqual([], errorText: context.l10n.pleaseSelectAtLeastOneItem),
      // ignore: prefer_const_literals_to_create_immutables
      initialValue: [],
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.itemsSummaryLength(
                    salesState.saleItems.length.toString(),
                  ),
                  style:
                      AppText.heading5.copyWith(color: AppColors.primaryColor),
                ),
                TextButton(
                  onPressed: salesNotifier.resetForm,
                  child: Text(
                    context.l10n.clearCart,
                    style: AppText.mediumM.copyWith(
                      color: AppColors.primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: salesState.saleItems.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Assets.images.emptyCart.image(),
                        const SizedBox(height: 24),
                        Text(
                          AppRouter.l10n.cartIsEmpty,
                          style: AppText.heading5,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.l10n.yourCartIsEmpty,
                          textAlign: TextAlign.center,
                          style: AppText.xLargeN
                              .copyWith(color: AppColors.outlineGrey),
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      child: Table(
                        columnWidths: const <int, TableColumnWidth>{
                          0: FlexColumnWidth(),
                          1: FixedColumnWidth(160),
                          2: IntrinsicColumnWidth(),
                          3: IntrinsicColumnWidth(),
                          4: IntrinsicColumnWidth(),
                          5: IntrinsicColumnWidth(),
                          6: FixedColumnWidth(40),
                        },
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        children: <TableRow>[
                          TableRow(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0xffB1B8D0)),
                              ),
                            ),
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Text(
                                  context.l10n.itemName,
                                  style: AppText.largeM
                                      .copyWith(color: AppColors.primaryColor),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  context.l10n.quantity,
                                  style: AppText.largeM
                                      .copyWith(color: AppColors.primaryColor),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  context.l10n.unit,
                                  style: AppText.largeM
                                      .copyWith(color: AppColors.primaryColor),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  context.l10n.salePrice,
                                  style: AppText.largeM
                                      .copyWith(color: AppColors.primaryColor),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  AppRouter.l10n.tax,
                                  style: AppText.largeM
                                      .copyWith(color: AppColors.primaryColor),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  AppRouter.l10n.total,
                                  style: AppText.largeM
                                      .copyWith(color: AppColors.primaryColor),
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                          ...List<TableRow>.generate(
                              salesState.saleItems.length, (index) {
                            final saleItem = salesState.saleItems[index];
                            final item = saleItem.item;
                            return TableRow(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Color(0xffB1B8D0)),
                                ),
                              ),
                              key: ValueKey(item.itemId! +
                                  '-' +
                                  saleItem.selectedSubServices
                                      .map((e) => e.subServiceId ?? '')
                                      .join(','),),
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        item.name,
                                        style: AppText.largeB.copyWith(
                                          color: AppColors.stormyBlue,
                                        ),
                                      ),
                                      ...saleItem.selectedSubServices.map(
                                        (e) => Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              e.name,
                                              style: AppText.mediumN.copyWith(
                                                color: AppColors.stormyBlue,
                                              ),
                                            ),
                                            Text(
                                              currency +
                                                  e.additionalPrice
                                                      .toStringAsFixed(2),
                                              style: AppText.mediumN.copyWith(
                                                color: AppColors.stormyBlue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      // Conditionally show the note field or the "Add Note" button
                                      if (businessType ==
                                          BusinessType.foodAndBeverage)
                                        if (_itemsWithOpenNotes
                                                .contains(item.itemId) ||
                                            (saleItem.note != null &&
                                                saleItem.note!.isNotEmpty))
                                          // If a note exists or the field is toggled open, show the TextFormField
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  saleItem.note ?? '',
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              InkWell(
                                                onTap: () async {
                                                  final note =
                                                      await showDialog<String?>(
                                                    context: context,
                                                    builder: (context) {
                                                      return AddNoteDialog(
                                                        addItemFormKey:
                                                            _addItemFormKey,
                                                        ref: ref,
                                                        note:
                                                            saleItem.note ?? '',
                                                      );
                                                    },
                                                  );
                                                  salesNotifier.addNote(
                                                    note!,
                                                    index,
                                                  );
                                                  setState(() {
                                                    _itemsWithOpenNotes
                                                        .add(item.itemId!);
                                                  });
                                                },
                                                child: const Icon(
                                                  CupertinoIcons.chevron_down,
                                                ),
                                              ),
                                            ],
                                          )
                                        else
                                          // Otherwise, show the "+ Add Note" button
                                          InkWell(
                                            onTap: () async {
                                              final note =
                                                  await showDialog<String?>(
                                                context: context,
                                                builder: (context) {
                                                  return AddNoteDialog(
                                                    addItemFormKey:
                                                        _addItemFormKey,
                                                    ref: ref,
                                                  );
                                                },
                                              );
                                              salesNotifier.addNote(
                                                note!,
                                                index,
                                              );
                                              setState(() {
                                                _itemsWithOpenNotes
                                                    .add(item.itemId!);
                                              });
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 4.0,
                                              ),
                                              child: Text(
                                                '+ ${context.l10n.addNote}',
                                                style:
                                                    AppText.mediumSB.copyWith(
                                                  // Orange color from your screenshot
                                                  color:
                                                      const Color(0xFFF57C00),
                                                ),
                                              ),
                                            ),
                                          ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: DoubleSpinnerField(
                                    min: 0,
                                    value: saleItem.quantity,
                                    onChanged: (value) {
                                      // final allowSalesWhenOutOfStock = (ref
                                      //             .read(
                                      //               businessNotifierProvider,
                                      //             )
                                      //             ?.allowSalesWhenOutOfStock ??
                                      //         false) &&
                                      //     item.itemType == ItemType.goods;
                                      // if (value > item.stockQuantity - 1 &&
                                      //     !allowSalesWhenOutOfStock) {
                                      //   Alert.showSnackBar(
                                      //     '${item.name} is ${context.l10n.outOfStock}',
                                      //     type: SnackBarType.warning,
                                      //   );
                                      //   return;
                                      // }
                                      // salesNotifier.updateItemQuantity(
                                      //   item.itemId!,
                                      //   value,
                                      // );
                                      if (value < 1) {
                                        salesNotifier.removeItem(item.itemId!);
                                        _itemsWithOpenNotes.remove(item
                                            .itemId,); // if you want to remove notes too
                                        return;
                                      }
                                      final allowSalesWhenOutOfStock = (ref
                                                  .read(
                                                    businessNotifierProvider,
                                                  )
                                                  ?.allowSalesWhenOutOfStock ??
                                              false) &&
                                          item.itemType == ItemType.goods;
                                      if (value > item.stockQuantity - 1 &&
                                          !allowSalesWhenOutOfStock) {
                                        Alert.showSnackBar(
                                          '${item.name} is ${context.l10n.outOfStock}',
                                          type: SnackBarType.warning,
                                        );
                                        return;
                                      }
                                      salesNotifier.updateItemQuantity(
                                        item.itemId!,
                                        value,
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    item.unit?.shortName ??
                                        item.unit?.name ??
                                        '',
                                    style: AppText.largeSB
                                        .copyWith(color: AppColors.stormyBlue),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: DoubleSpinnerField(
                                    min: 0,
                                    showButtons: false,
                                    value: saleItem.unitPrice,
                                    onChanged: (value) {
                                      if (value < 0) {
                                        return;
                                      }
                                      salesNotifier.updateItemUnitPrice(
                                        item.itemId!,
                                        value,
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    currency +
                                        saleItem.itemTaxTotal
                                            .toStringAsFixed(2) +
                                        (item.isTaxInclusive ? ' (Inc)' : ''),
                                    style: AppText.largeSB
                                        .copyWith(color: AppColors.stormyBlue),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    currency +
                                        saleItem.itemTotal.toStringAsFixed(2),
                                    style: AppText.largeSB
                                        .copyWith(color: AppColors.stormyBlue),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    salesNotifier.removeItem(item.itemId!);
                                    _itemsWithOpenNotes.remove(item.itemId!);
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: AppColors.red,
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
            ),
            if (salesState.customFields.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 18),
                  Text(
                    context.l10n.customFields,
                    style: AppText.heading5
                        .copyWith(color: AppColors.primaryColor),
                  ),
                  const SizedBox(height: 12),
                  ...salesState.customFields.map(
                    (e) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 26),
                        child: AppTextForm<String>(
                          label: e.fieldName,
                          name: e.fieldName,
                          validator: FormBuilderValidators.compose([
                            if (e.isRequired) FormBuilderValidators.required(),
                          ]),
                          onChanged: (value) {
                            salesNotifier.updateCustomFieldValue(
                              e.fieldName,
                              value,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            Row(
              children: [
                if (salesState.saleItems.isNotEmpty &&
                    businessType == BusinessType.foodAndBeverage)
                  Expanded(
                    child: salesState.notes == null || salesState.notes == ''
                        ? AppButton(
                            onPress: () async {
                              final note = await showDialog<String?>(
                                context: context,
                                builder: (context) {
                                  return AddNoteDialog(
                                    addItemFormKey: _addItemFormKey,
                                    ref: ref,
                                  );
                                },
                              );
                              salesNotifier.setSaleNote(note ?? '');
                              setState(() {
                                formKey?.fields['notes']?.didChange(note);
                              });
                            },
                            label: Text('+ ${context.l10n.addNote}'),
                            color: AppColors.orange,
                          )
                        : InkWell(
                            onTap: () async {
                              final note = await showDialog<String?>(
                                context: context,
                                builder: (context) {
                                  return AddNoteDialog(
                                    note: salesState.notes,
                                    addItemFormKey: _addItemFormKey,
                                    ref: ref,
                                  );
                                },
                              );
                              salesNotifier.setSaleNote(note ?? '');
                              setState(() {
                                formKey?.fields['notes']?.didChange(note);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.greyNew,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      salesState.notes ?? '',
                                      style: AppText.mediumSB
                                          .copyWith(color: AppColors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                if (salesState.saleItems.isNotEmpty &&
                    salesState.heldCarts.isNotEmpty)
                  const SizedBox(width: 12),
                if (salesState.heldCarts.isNotEmpty) ...[
                  Expanded(
                    child: AppButton(
                      style: ButtonStyles.secondary,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      onPress: () async {
                        await showDialog<void>(
                          context: context,
                          builder: (context) {
                            return HoldBillDialog(
                              onRestoreCart: (cart) {
                                final customerData =
                                    cart['customer'] as Map<String, dynamic>?;
                                if (customerData != null) {
                                  formKey?.fields['customer']?.didChange(
                                    Customer.fromJson(customerData),
                                  );
                                  formKey?.fields['shipping']
                                      ?.didChange(cart['shipping']);
                                  formKey?.fields['discount-percent']
                                      ?.didChange(cart['discount-percent']);
                                  formKey?.fields['discount-amount']
                                      ?.didChange(cart['discount-amount']);
                                  formKey?.fields['orderMode']
                                      ?.didChange(cart['orderMode']);
                                }
                                context.pop();
                              },
                            );
                          },
                        );
                      },
                      label: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(context.l10n.recallBill),
                          Container(
                            decoration: const BoxDecoration(
                              color: AppColors.brandViolet,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(14),
                            child: Text(
                              salesState.heldCarts.length.toString(),
                              style: const TextStyle(color: AppColors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const Divider(color: AppColors.primaryColor),
            const SizedBox(height: 8),
            _dataRow(
              label: context.l10n.totalItems,
              child: Text(
                salesState.saleItems.length.toString(),
                style: AppText.xLargeM.copyWith(color: AppColors.stormyBlue),
              ),
            ),
            const SizedBox(height: 14),
            _dataRow(
              label: context.l10n.subTotal,
              child: Text(
                currency + salesState.subtotal.toStringAsFixed(2),
                style: AppText.heading5.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _dataRow(
              label: context.l10n.serviceShipping,
              child: IntrinsicWidth(
                child: FormBuilderField<double>(
                  name: 'shipping',
                  initialValue: salesState.shipping,
                  builder: (shipping) {
                    return Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.stormyBlue,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                            border: Border.all(color: AppColors.stormyBlue),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            currency,
                            style: AppText.xLargeM
                                .copyWith(color: AppColors.white),
                          ),
                        ),
                        Expanded(
                          child: DoubleSpinnerField(
                            min: 0,
                            style: AppText.xLargeM
                                .copyWith(color: AppColors.primaryColor),
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
                              salesNotifier.updateShipping(value);
                              shipping.didChange(value);
                            },
                            showButtons: false,
                            value: shipping.value ?? 0,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            _dataRow(
              label: context.l10n.discount,
              child: Row(
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
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppColors.stormyBlue,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                ),
                                border: Border.all(color: AppColors.stormyBlue),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '%',
                                style: AppText.xLargeM
                                    .copyWith(color: AppColors.white),
                              ),
                            ),
                            Expanded(
                              child: DoubleSpinnerField(
                                min: 0,
                                style: AppText.xLargeM
                                    .copyWith(color: AppColors.primaryColor),
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
                                  salesNotifier.updateDiscountPercent(value);
                                  discountPercent.didChange(value);
                                  formKey?.fields['discount-amount']?.didChange(
                                    (salesState.subtotal * value / 100)
                                        .toPrecision(2),
                                  );
                                },
                                showButtons: false,
                                value: discountPercent.value ?? 0,
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
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppColors.stormyBlue,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                ),
                                border: Border.all(color: AppColors.stormyBlue),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                currency,
                                style: AppText.xLargeM
                                    .copyWith(color: AppColors.white),
                              ),
                            ),
                            Expanded(
                              child: DoubleSpinnerField(
                                min: 0,
                                style: AppText.xLargeM
                                    .copyWith(color: AppColors.primaryColor),
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
                                  salesNotifier.updateDiscountAmount(value);
                                  discountAmount.didChange(value);
                                  formKey?.fields['discount-percent']
                                      ?.didChange(
                                    salesState.subtotal > 0
                                        ? ((value / salesState.subtotal) * 100)
                                            .toPrecision(2)
                                        : 0,
                                  );
                                },
                                showButtons: false,
                                value: discountAmount.value ?? 0,
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
            const SizedBox(height: 8),
            _dataRow(
              label: context.l10n.vatGst,
              child: Text(
                '$currency ${salesState.taxTotal.toStringAsFixed(2)}',
                style: AppText.heading4.copyWith(color: AppColors.primaryColor),
              ),
            ),
            const SizedBox(height: 8),
            _dataRow(
              label: context.l10n.grandTotal,
              child: Text(
                '$currency ${salesState.grandTotal.toStringAsFixed(2)}',
                style: AppText.heading4.copyWith(color: AppColors.primaryColor),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (true) ...[
                  Expanded(
                    flex: 3,
                    child: AppButton(
                      onPress: () {
                        if (salesState.saleItems.isEmpty) {
                          Alert.showSnackBar(
                            context.l10n.cartIsEmptyCannotHold,
                            type: SnackBarType.warning,
                          );
                          return;
                        }

                        final formData = formKey!.instantValue;
                        final cartToHold = {
                          'held_time': DateTime.now().toIso8601String(),
                          'saleItems': salesState.saleItems
                              .map((si) => si.toJson())
                              .toList(),
                          'customer': salesState.customer?.toJson(),
                          'employee': salesState.employee?.toJson(),
                          'shipping':
                              formData['shipping'] ?? salesState.shipping,
                          'discount-percent': formData['discount-percent'] ??
                              salesState.discountPercent,
                          'discount-amount': formData['discount-amount'] ??
                              salesState.discountAmount,
                          'orderMode': salesState.orderMode,
                          'customFieldValues': salesState.customFieldValues,
                          'grandTotal': salesState.grandTotal,
                        };

                        salesNotifier
                          ..holdCart(cartToHold)
                          ..resetForm();
                        formKey.fields['customer']?.didChange(null);
                        formKey.fields['shipping']?.didChange(null);
                        formKey.fields['discount-percent']?.didChange(null);
                        formKey.fields['discount-amount']?.didChange(null);
                        formKey.fields['orderMode']?.didChange(false);
                      },
                      label: Text(
                        context.l10n.holdBill,
                        style: AppText.heading5,
                      ),
                      style: ButtonStyles.secondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  flex: 7,
                  child: AppButton(
                    onPress: () {
                      if (formKey?.saveAndValidate() ?? false) {
                        salesNotifier
                            .validateSaleData(formKey!.value)
                            .then((value) {
                          AppRouter.pushNamed(AppRouter.salePayment);
                        });
                      } else {
                        formKey?.errors.forEach(
                          (key, value) => Alert.showSnackBar(
                            value,
                            type: SnackBarType.error,
                          ),
                        );
                        return;
                      }
                    },
                    label: Text(context.l10n.payment),
                    color: AppColors.green,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class AddNoteDialog extends StatelessWidget {
  AddNoteDialog({
    required GlobalKey<FormBuilderState> addItemFormKey,
    required this.ref,
    this.note,
    super.key,
  }) : _addItemFormKey = addItemFormKey;

  final GlobalKey<FormBuilderState> _addItemFormKey;
  final WidgetRef ref;
  String? note;

  @override
  Widget build(BuildContext context) {
    return FormAddDialog(
      title: context.l10n.addNote,
      formKey: _addItemFormKey,
      onPositive: () {
        context.pop(
          _addItemFormKey.currentState!.value['add_note_item'],
        );
      },
      isLoading: ref
              .watch(
                customerNotifierProvider,
              )
              .status ==
          CustomerStatus.loading,
      children: [
        AppTextForm<String>(
          label: context.l10n.note,
          minLines: 6,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          name: 'add_note_item',
          initialValue: note,
        ),
      ],
    );
  }
}

class HoldBillDialog extends ConsumerWidget {
  const HoldBillDialog({super.key, this.onRestoreCart});
  final void Function(Map<String, dynamic> cart)? onRestoreCart;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesState = ref.watch(salesNotifierProvider);
    final salesNotifier = ref.watch(salesNotifierProvider.notifier);
    final currency = ref.watch(currencyProvider);
    final heldCarts = salesState.heldCarts;
    final l10n = AppLocalizations.of(context);

    // Localization fallbacks
    final customerLabel = l10n.customer;
    final recallBillTitle = l10n.recallBill;
    final noHeldBillsMsg = l10n.noHeldBillsAvailable;
    final walkInCustomerText = l10n.walkInCustomer;
    final heldOnText = l10n.heldOn;
    final itemsLabel = l10n.items;
    final totalAmountLabel = l10n.totalAmount;

    List<DataRow> createRows() {
      return heldCarts.asMap().entries.map((entry) {
        final index = entry.key;
        final cart = entry.value;

        final heldTime =
            DateTime.tryParse(cart['held_time'] as String? ?? '')?.toLocal() ??
                DateTime.now();

        var customerNameDisplay = walkInCustomerText;
        final customerData = cart['customer'] as Map<String, dynamic>?;
        if (customerData != null) {
          customerNameDisplay =
              customerData['name'] as String? ?? walkInCustomerText;
        }

        final itemsList = cart['saleItems'] as List<dynamic>? ?? [];
        final itemCount = itemsList.length;

        var calculatedTotalForDisplay = 0.0;

        try {
          var dialogSubtotal = 0.0;
          var dialogTaxTotal = 0.0;

          for (final itemMap in itemsList) {
            if (itemMap is Map<String, dynamic>) {
              final saleItem = SaleItem.fromJson(itemMap);

              final itemBasePrice = saleItem.quantity * saleItem.unitPrice;
              final subServicesTotal = saleItem.selectedSubServices
                  .fold<double>(0, (sum, e) => sum + e.additionalPrice);
              final itemPriceWithSubServices = itemBasePrice + subServicesTotal;

              dialogSubtotal += itemPriceWithSubServices;

              final taxPercent = saleItem.item.tax?.rate ?? 0.0;
              if (taxPercent > 0) {
                dialogTaxTotal += itemPriceWithSubServices * (taxPercent / 100);
              }
            }
          }

          calculatedTotalForDisplay = dialogSubtotal + dialogTaxTotal;
        } catch (e, s) {
          print('Error calculating total in dialog: $e\n$s');
          // calculatedTotalForDisplay will remain 0.0 due to initialization
        }

        return DataRow(
          key: ObjectKey(cart),
          cells: [
            DataCell(
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text('${index + 1}'),
              ),
            ),
            DataCell(Text(heldTime.toFullFormat)),
            DataCell(Text(customerNameDisplay)),
            DataCell(Text(itemCount.toString())),
            DataCell(
              Text(
                '$currency ${calculatedTotalForDisplay.toStringAsFixed(2)}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            DataCell(
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (heldCarts.length == 1) {
                        context.pop();
                      }
                      salesNotifier.deleteCart(cart);
                    },
                    icon: const Icon(
                      Icons.delete_outline_outlined,
                      color: AppColors.red,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      salesNotifier.recallCart(cart);
                      onRestoreCart?.call(cart);
                    },
                    icon: const Icon(
                      Icons.restore_rounded,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList();
    }

    if (heldCarts.isEmpty) {
      return AlertDialog(
        title: Text(recallBillTitle),
        content: Text(noHeldBillsMsg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      );
    }

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              recallBillTitle,
              style: AppText.heading4.copyWith(color: AppColors.primaryColor),
            ),
            const SizedBox(height: 24),
            DataTable(
              headingRowColor: WidgetStateColor.resolveWith(
                (states) => AppColors.lightPurple,
              ),
              border: TableBorder.all(color: AppColors.stormyBlue),
              dividerThickness: 0,
              horizontalMargin: 2,
              columns: [
                DataColumn(
                  label: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(l10n.slNo),
                  ),
                ),
                DataColumn(label: Text(heldOnText)),
                DataColumn(label: Text(customerLabel)),
                DataColumn(label: Text(itemsLabel)),
                DataColumn(label: Text(totalAmountLabel)),
                const DataColumn(label: Text('')),
              ],
              rows: createRows(),
            ),
          ],
        ),
      ),
    );
  }
}
