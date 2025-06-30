import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/features/purchase/purchase.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PurchaseScreenWeb extends ConsumerStatefulWidget {
  const PurchaseScreenWeb({super.key});

  @override
  ConsumerState<PurchaseScreenWeb> createState() => _PurchaseScreenWebState();
}

class _PurchaseScreenWebState extends ConsumerState<PurchaseScreenWeb> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _debouncer = Debouncer(milliseconds: 500);

  void _clear() {
    if (!mounted) return;
    if (GoRouter.of(AppRouter.rootContext).routerDelegate.currentConfiguration.uri.queryParameters['clear'] == 'true') {
      debugPrint('------->>>>>>>clear is true');
      _formKey.currentState?.reset();
      // Reset the sales state through the notifier
      ref.read(purchaseNotifierProvider.notifier).resetForm();

      // Remove the clear parameter from URL to prevent multiple resets
      GoRouter.of(context).goNamed(AppRouter.purchase);
    }
  }

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    GoRouter.of(AppRouter.rootContext).routerDelegate.addListener(_clear);
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    GoRouter.of(AppRouter.rootContext).routerDelegate.removeListener(_clear);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final purchaseNotifier = ref.watch(purchaseNotifierProvider.notifier);
    final purchaseState = ref.watch(purchaseNotifierProvider);

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
                  flex: 6,
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
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${context.l10n.purchaseInvoiceNumber} *',
                            style: AppText.largeSB,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AppTextForm<String>(
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
                          ),
                          const SizedBox(width: 8),
                          IntrinsicWidth(
                            child: InputDecorator(
                              decoration: const InputDecoration(prefixIcon: Icon(Icons.attach_file)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(purchaseState.file?.name ?? context.l10n.documents),
                                  const SizedBox(width: 8),
                                  if (purchaseState.file == null)
                                    AppButton(
                                      onPress: () async {
                                        final result = await FilePicker.platform.pickFiles(withData: true);
                                        if (result != null) {
                                          purchaseNotifier.updateFile(result.files.first);
                                        }
                                      },
                                      label: Text(context.l10n.upload),
                                    )
                                  else
                                    IconButton(
                                      onPressed: () {
                                        purchaseNotifier.updateFile(null);
                                      },
                                      icon: const Icon(Icons.close),
                                    ),
                                ],
                              ),
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
                                AppTypeAheadForm<Supplier>(
                                  name: 'supplier',
                                  validator: FormBuilderValidators.required(),
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
                                  initialValue: purchaseState.supplier,
                                  onSuggestionSelected: purchaseNotifier.updateSupplier,
                                  onClear: () {
                                    purchaseNotifier.updateSupplier(null);
                                  },
                                  noItemsFoundBuilder: (context) {
                                    return TextFieldTapRegion(
                                      child: ListTile(
                                        onTap: () {
                                          showDialog<void>(
                                            context: context,
                                            builder: (context) {
                                              return AddSupplierDialog(
                                                supplierName: purchaseState.supplier?.name ?? '',
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
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          AppButton.icon(
                            icon: const Icon(Icons.add),
                            onPress: () async {
                              
                              final supplier = await showDialog<Supplier>(
                                context: context,
                                builder: (context) {
                                  return AddSupplierDialog(
                                    supplierName: purchaseState.supplier?.name,
                                  );
                                },
                              );
                              if (supplier != null) {
                                purchaseNotifier.updateSupplier(supplier);
                              }
                            },
                            label: Text(context.l10n.addSupplier),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: _ItemTiles(
                          onSubmit: () {
                            if (_formKey.currentState?.saveAndValidate() ?? false) {
                              AppRouter.pushNamed(AppRouter.purchasePayment);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: AppTextForm<String>(
                                  name: 'search',
                                  controller: searchController,
                                  hintText: context.l10n.enterNameOrSerialNumber,
                                  onChanged: (v) {
                                    _debouncer.run(() {
                                      purchaseNotifier.setFilter(query: v);
                                    });
                                  },
                                  prefixIcon: const Icon(Icons.qr_code_2_outlined),
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
                      Expanded(
                        child: Container(
                          decoration: AppStyles.boxDecoration.copyWith(boxShadow: []),
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(context.l10n.chooseItem, style: AppText.xLargeM),
                              const SizedBox(height: 20),
                              Expanded(
                                child: CustomScrollView(
                                  slivers: <Widget>[
                                    PagedSliverGrid<int, Item>(
                                      builderDelegate: PagedChildBuilderDelegate<Item>(
                                        noItemsFoundIndicatorBuilder: (context) {
                                          if (searchController.text.isNotEmpty) {
                                            return const NoSearchItemWidget();
                                          }
                                          return const NoDataViewWidget();
                                        },
                                        itemBuilder: (context, item, index) => ItemCard(
                                          item: item,
                                          type: ItemCardType.purchase,
                                          onTap: () {
                                            purchaseNotifier.addItem(item);
                                          },
                                        ),
                                      ),
                                      pagingController: purchaseState.pagingController!,
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 20,
                                        mainAxisSpacing: 20,
                                        childAspectRatio: 9 / 11.2,
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
              ],
            ),
          ),
        _ => const SizedBox(),
      },
    );
  }
}

class _ItemTiles extends ConsumerStatefulWidget {
  const _ItemTiles({
    required this.onSubmit,
  });
  final void Function() onSubmit;
  @override
  ConsumerState<_ItemTiles> createState() => _ItemTilesState();
}

class _ItemTilesState extends ConsumerState<_ItemTiles> {
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
    final currency = ref.watch(currencyProvider);
    final purchaseState = ref.watch(purchaseNotifierProvider);
    final purchaseNotifier = ref.watch(purchaseNotifierProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.itemsSummaryLength(purchaseState.purchaseItems.length.toString()),
              style: AppText.heading5.copyWith(color: AppColors.primaryColor),
            ),
            TextButton(
              onPressed: () {
                ref.read(purchaseNotifierProvider.notifier).resetForm();
              },
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
          child: purchaseState.purchaseItems.isEmpty
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
                      style: AppText.xLargeN.copyWith(color: AppColors.outlineGrey),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  child: Table(
                    columnWidths: const <int, TableColumnWidth>{
                      0: FlexColumnWidth(),
                      1: FixedColumnWidth(180),
                      2: IntrinsicColumnWidth(),
                      3: IntrinsicColumnWidth(),
                      4: IntrinsicColumnWidth(),
                      5: FixedColumnWidth(40),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
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
                              style: AppText.largeM.copyWith(color: AppColors.primaryColor),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              context.l10n.quantity,
                              style: AppText.largeM.copyWith(color: AppColors.primaryColor),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              context.l10n.unit,
                              style: AppText.largeM.copyWith(color: AppColors.primaryColor),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              context.l10n.purchasePrice,
                              style: AppText.largeM.copyWith(color: AppColors.primaryColor),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              AppRouter.l10n.total,
                              style: AppText.largeM.copyWith(color: AppColors.primaryColor),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                      ...List<TableRow>.generate(purchaseState.purchaseItems.length, (index) {
                        final item = purchaseState.purchaseItems[index];
                        return TableRow(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Color(0xffB1B8D0)),
                            ),
                          ),
                          // key: ObjectKey(item),
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                item.item.name,
                                style: AppText.largeB.copyWith(color: AppColors.stormyBlue),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: DoubleSpinnerField(
                                min: 1,
                                value: item.quantity,
                                onChanged: (value) {
                                  purchaseNotifier.updateItemQuantity(item.item.itemId!, value);
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                item.item.unit?.shortName ?? item.item.unit?.name ?? '',
                                style: AppText.largeSB.copyWith(color: AppColors.stormyBlue),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: DoubleSpinnerField(
                                min: 0,
                                showButtons: false,
                                value: item.unitPrice,
                                onChanged: (value) {
                                  purchaseNotifier.updateItemUnitPrice(item.item.itemId!, value);
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Builder(
                                builder: (context) {
                                  return Text(
                                    currency + (item.quantity * item.unitPrice).toStringAsFixed(2),
                                    style: AppText.largeSB.copyWith(color: AppColors.stormyBlue),
                                  );
                                },
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                purchaseNotifier.removeItem(item.item.itemId!);
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
        const Divider(color: AppColors.primaryColor),
        const SizedBox(height: 8),
        _dataRow(
          label: context.l10n.totalItems,
          child: Text(
            purchaseState.purchaseItems.length.toString(),
            style: AppText.xLargeM.copyWith(color: AppColors.stormyBlue),
          ),
        ),
        const SizedBox(height: 14),
        _dataRow(
          label: context.l10n.subTotal,
          child: Text(
            currency + purchaseState.subtotal.toStringAsFixed(2),
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
              initialValue: purchaseState.shipping,
              builder: (shipping) {
                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.stormyBlue,
                        borderRadius:
                            const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                        border: Border.all(color: AppColors.stormyBlue),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        currency,
                        style: AppText.xLargeM.copyWith(color: AppColors.white),
                      ),
                    ),
                    Expanded(
                      child: DoubleSpinnerField(
                        style: AppText.xLargeM.copyWith(color: AppColors.primaryColor),
                        min: 0,
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
                          purchaseNotifier.updateShipping(value);
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
                  initialValue: purchaseState.discountPercent,
                  builder: (discountPercent) {
                    return Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.stormyBlue,
                            borderRadius:
                                const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                            border: Border.all(color: AppColors.stormyBlue),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '%',
                            style: AppText.xLargeM.copyWith(color: AppColors.white),
                          ),
                        ),
                        Expanded(
                          child: DoubleSpinnerField(
                            min: 0,
                            style: AppText.xLargeM.copyWith(color: AppColors.primaryColor),
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
                              purchaseNotifier.updateDiscountPercent(value);
                              FormBuilder.of(context)?.fields['discount-amount']?.didChange(
                                    (purchaseState.subtotal * (value / 100)).toPrecision(2),
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
                  initialValue: purchaseState.discountAmount,
                  builder: (discountAmount) {
                    return Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.stormyBlue,
                            borderRadius:
                                const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                            border: Border.all(color: AppColors.stormyBlue),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            currency,
                            style: AppText.xLargeM.copyWith(color: AppColors.white),
                          ),
                        ),
                        Expanded(
                          child: DoubleSpinnerField(
                            min: 0,
                            style: AppText.xLargeM.copyWith(color: AppColors.primaryColor),
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
                              purchaseNotifier.updateDiscountAmount(value);
                              FormBuilder.of(context)?.fields['discount-percent']?.didChange(
                                    discountAmount.value != null
                                        ? ((discountAmount.value! / purchaseState.subtotal) * 100).toPrecision(2)
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
          label: context.l10n.grandTotal,
          child: Text(
            '$currency ${purchaseState.grandTotal.toStringAsFixed(2)}',
            style: AppText.heading4.copyWith(color: AppColors.primaryColor),
          ),
        ),
        const SizedBox(height: 8),
        AppButton(
          onPress: widget.onSubmit,
          label: Text(context.l10n.payment),
          color: AppColors.green,
        ),
      ],
    );
  }
}
