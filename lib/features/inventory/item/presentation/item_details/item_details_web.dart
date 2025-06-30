import 'dart:convert';

import 'package:dotted_border/dotted_border.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/features/purchase/purchase.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

class ItemDetailsScreenWeb extends ConsumerStatefulWidget {
  const ItemDetailsScreenWeb({super.key, this.item});
  final Item? item;
  @override
  ConsumerState<ItemDetailsScreenWeb> createState() =>
      _ItemDetailsScreenWebState();
}

class _ItemDetailsScreenWebState extends ConsumerState<ItemDetailsScreenWeb> {
  final _formKey = GlobalKey<FormBuilderState>();
  final FocusNode _serialFocus = FocusNode();
  final List<ItemImage> _images = [];
  final QuillController _quillController = QuillController.basic();
  bool _selectedItemTypeisGoods = true;
  T? formValue<T>(String key) =>
      _formKey.currentState?.fields[key]?.value as T?;

  @override
  void initState() {
    if (widget.item != null) {
      _images.addAll(widget.item!.images);
      if (widget.item!.richText != null) {
        _quillController.document = Document.fromJson(
          jsonDecode(widget.item!.richText!) as List<dynamic>,
        );
      }
      _selectedItemTypeisGoods = widget.item!.itemType == ItemType.goods;
    } else {
      Future(
        () async {
          _formKey.currentState?.fields['item_code']
              ?.didChange(await ref.read(itemRepoProvider).getNextItemCode());
          setState(() {});
        },
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {});
    });
    super.initState();
  }

  final _formDeceoration = InputDecoration(
    fillColor: AppColors.textfield,
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(8),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(8),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final itemNotifier = ref.watch(itemNotifierProvider.notifier);
    final itemState = ref.watch(itemNotifierProvider);
    if (widget.item == null) {
      ref.listen(
        businessNotifierProvider,
        (previous, next) async {
          _formKey.currentState?.fields['item_code']
              ?.didChange(await ref.read(itemRepoProvider).getNextItemCode());
        },
      );
    }
    return FormBuilder(
      key: _formKey,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 7,
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
                            children: [
                              Offstage(
                                offstage: widget.item != null,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: AppColors.chooseItemType,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 19,
                                    vertical: 19,
                                  ),
                                  margin: const EdgeInsets.only(bottom: 32),
                                  child: Row(
                                    children: [
                                      Text(
                                        context.l10n.selectItemType,
                                        style: AppText.largeM.copyWith(
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                      const Spacer(),
                                      FormBuilderField<String>(
                                        initialValue:
                                            widget.item?.itemType.name ??
                                                ItemType.goods.name,
                                        onChanged: (val) {
                                          setState(() {
                                            _selectedItemTypeisGoods =
                                                val == ItemType.goods.name;
                                          });
                                        },
                                        builder: (field) {
                                          return Row(
                                            children: [
                                              ...ItemType.values.map(
                                                (e) => Row(
                                                  children: [
                                                    Transform.scale(
                                                      scale:
                                                          1.4, // Increase this value to make the radio button larger
                                                      child: Radio(
                                                        value: e.name,
                                                        groupValue: field.value,
                                                        onChanged:
                                                            field.didChange,
                                                        activeColor: AppColors
                                                            .primaryColor,
                                                        fillColor:
                                                            WidgetStateProperty
                                                                .all(
                                                          AppColors
                                                              .primaryColor,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      e.name.displayCase,
                                                      style: AppText.largeM
                                                          .copyWith(
                                                        color: AppColors
                                                            .primaryColor,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                        name: 'item_type',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              AppTextForm<String>(
                                prefixIcon: const Icon(
                                  CupertinoIcons.search,
                                  color: AppColors.primaryColor,
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(CupertinoIcons.clear),
                                  color: AppColors.primaryColor,
                                  onPressed: () {
                                    setState(() {
                                      _formKey.currentState?.fields['name']
                                          ?.reset();
                                    });
                                  },
                                ),
                                validator: FormBuilderValidators.required(
                                  errorText:
                                      context.l10n.itemNameShouldNotBeEmpty,
                                ),
                                label: '${context.l10n.itemName} *',
                                decoration: _formDeceoration,
                                name: 'name',
                                initialValue: widget.item?.name,
                              ),
                              const SizedBox(height: 28),
                              Row(
                                children: [
                                  Expanded(
                                    child: AppTextForm<String>(
                                      name: 'item_code',
                                      style: AppText.largeM.copyWith(
                                        color: AppColors.darkBlue,
                                      ),
                                      label: context.l10n.itemCode,
                                      initialValue: widget.item?.itemCode,
                                      validator:
                                          FormBuilderValidators.required(),
                                      isReadOnly: true,
                                      decoration: InputDecoration(
                                        fillColor: AppColors.lightPurple,
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          child: AppTypeAheadForm<ItemCategory>(
                                            decoration: _formDeceoration,
                                            label: context.l10n.category,
                                            name: 'item_category',
                                            secondaryLabel: context.l10n.select,
                                            initialValue:
                                                widget.item?.itemCategory,
                                            suggestionsCallback: (search) => ref
                                                .read(
                                                  itemCategoryRepoProvider,
                                                )
                                                .getItemCategories(
                                                  pageSize: 20,
                                                  pageNumber: 1,
                                                  query: search,
                                                )
                                                .then(
                                                  (value) => value.data,
                                                ),
                                            itemBuilder:
                                                (context, suggestion) =>
                                                    ListTile(
                                              title: Text(suggestion.name),
                                            ),
                                            selectionToTextTransformer:
                                                (suggestion) => suggestion.name,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        FormAddButton(
                                          icon: const Icon(Icons.add),
                                          onTap: () async {
                                            final category =
                                                await showDialog<ItemCategory>(
                                              context: context,
                                              builder: (context) =>
                                                  const AddCategoryDialog(),
                                            );
                                            if (category != null) {
                                              _formKey.currentState
                                                  ?.fields['item_category']
                                                  ?.didChange(category);
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),
                              Row(
                                children: [
                                  Expanded(
                                    child: AppTextForm<double>(
                                      decoration: _formDeceoration,
                                      label: _selectedItemTypeisGoods
                                          ? context.l10n.salePrice
                                          : context.l10n.servicePrice,
                                      name: 'sale_price',
                                      initialValue: widget.item?.salePrice,
                                      validator: FormBuilderValidators.compose([
                                        if (formValue<bool>(
                                              'sales_enabled',
                                            ) ??
                                            true)
                                          FormBuilderValidators.required(
                                            errorText: context
                                                .l10n.pleaseEnterTheSalePrice,
                                          ),
                                      ]),
                                      suffixIcon: AppToolTip(
                                        child: Text(
                                          context.l10n.salePriceToolTip,
                                          style: AppText.mediumN.copyWith(
                                            color: AppColors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: AppTypeAheadForm<Tax>(
                                      decoration: _formDeceoration,
                                      label: AppRouter.l10n.tax,
                                      name: 'tax',
                                      initialValue: widget.item?.tax,
                                      selectionToTextTransformer: (e) =>
                                          '${e.name} (${e.rate}%)',
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
                                              .then(
                                                (value) => value.data,
                                              ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: _selectedItemTypeisGoods
                                        ? AppCheckBoxForm(
                                            name: 'is_returnable',
                                            initialValue:
                                                widget.item?.isReturnable ??
                                                    true,
                                            validator: FormBuilderValidators
                                                .required(),
                                            hint: context.l10n.returnableItem,
                                            hintStyle: AppText.largeSB.copyWith(
                                              color: AppColors.primaryColor,
                                            ),
                                          )
                                        : const SizedBox(),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: AppCheckBoxForm(
                                      name: 'is_tax_inclusive',
                                      initialValue:
                                          widget.item?.isTaxInclusive ?? false,
                                      validator:
                                          FormBuilderValidators.required(),
                                      hint: context.l10n.isTaxInclusive,
                                      hintStyle: AppText.largeSB.copyWith(
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // Offstage(
                              //   offstage: !_selectedItemTypeisGoods,
                              //   child: Column(
                              //     children: [
                              //       const SizedBox(height: 26),
                              //       Row(
                              //         crossAxisAlignment:
                              //             CrossAxisAlignment.end,
                              //         children: [

                              //           const SizedBox(width: 20),
                              //           Expanded(
                              //             child: AppCheckBoxForm(
                              //               name: 'is_returnable',
                              //               initialValue:
                              //                   widget.item?.isReturnable ??
                              //                       true,
                              //               validator: FormBuilderValidators
                              //                   .required(),
                              //               hint: context.l10n.returnableItem,
                              //               hintStyle: AppText.largeSB.copyWith(
                              //                 color: AppColors.primaryColor,
                              //               ),
                              //             ),
                              //           ),
                              //         ],
                              //       ),
                              //       const SizedBox(height: 16),
                              //     ],
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 26),
                        Offstage(
                          offstage: !_selectedItemTypeisGoods,
                          child: Container(
                            decoration: AppStyles.boxDecoration,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 18,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 20,
                                      child: Text(
                                        context.l10n.purchaseInformation,
                                        style: AppText.heading5.copyWith(
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Expanded(
                                      flex: 1,
                                      child: AppToggleForm(
                                        initialValue:
                                            widget.item?.purchaseEnabled ??
                                                false,
                                        name: 'purchase_enabled',
                                        onChanged: (val) {
                                          setState(() {});
                                        },
                                        hint: '',
                                        hintStyle: AppText.heading5.copyWith(
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Offstage(
                                  offstage: !(formValue<bool>(
                                        'purchase_enabled',
                                      ) ??
                                      true),
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: AppTextForm<double>(
                                              decoration: _formDeceoration,
                                              label: context.l10n.purchasePrice,
                                              name: 'purchase_price',
                                              initialValue:
                                                  widget.item?.purchasePrice,
                                              enabled: formValue<bool>(
                                                    'purchase_enabled',
                                                  ) ??
                                                  true,
                                              validator: FormBuilderValidators
                                                  .compose([
                                                if ((formValue<bool>(
                                                          'purchase_enabled',
                                                        ) ??
                                                        true) &&
                                                    _selectedItemTypeisGoods)
                                                  FormBuilderValidators
                                                      .required(
                                                    errorText: context.l10n
                                                        .pleaseEnterThePuchasePrice,
                                                  ),
                                              ]),
                                              suffixIcon: AppToolTip(
                                                child: Text(
                                                  context.l10n
                                                      .theRateAtWhichThisItemIsPurchased,
                                                  style:
                                                      AppText.mediumN.copyWith(
                                                    color: AppColors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 26,
                                            width: 26,
                                          ),
                                          Expanded(
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Expanded(
                                                  child: AppTypeAheadForm<
                                                      Supplier>(
                                                    decoration:
                                                        _formDeceoration,
                                                    label: context
                                                        .l10n.preferredVendor,
                                                    name: 'preferred_vendor',
                                                    enabled: formValue<bool>(
                                                          'purchase_enabled',
                                                        ) ??
                                                        true,
                                                    selectionToTextTransformer:
                                                        (e) =>
                                                            '${e.name}, ${e.phone}',
                                                    initialValue: widget.item
                                                        ?.preferredSupplier,
                                                    itemBuilder:
                                                        (context, suggestion) =>
                                                            ListTile(
                                                      title:
                                                          Text(suggestion.name),
                                                      subtitle: Text(
                                                          suggestion.phone),
                                                    ),
                                                    suggestionsCallback:
                                                        (String search) => ref
                                                            .read(
                                                              supplierRepoProvider,
                                                            )
                                                            .getSuppliers(
                                                              pageSize: 20,
                                                              pageNumber: 1,
                                                              query: search,
                                                            )
                                                            .then(
                                                              (value) =>
                                                                  value.data,
                                                            ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                FormAddButton(
                                                  onTap: () async {
                                                    final supplier =
                                                        await showDialog<
                                                            Supplier>(
                                                      context: context,
                                                      builder: (context) {
                                                        return AddSupplierDialog(
                                                          supplierName:
                                                              widget.item
                                                        ?.preferredSupplier?.name
                                                        );
                                                      },
                                                    );
                                                    if (supplier != null) {
                                                      _formKey
                                                          .currentState!
                                                          .fields[
                                                              'preferred_vendor']
                                                          ?.didChange(supplier);
                                                    }
                                                  },
                                                ),
                                              ],
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

                        const SizedBox(height: 26),
                        Container(
                          decoration: AppStyles.boxDecoration,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 18,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 20,
                                    child: Text(
                                      context.l10n.itemSpecification,
                                      style: AppText.heading5.copyWith(
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Expanded(
                                    child: AppToggleForm(
                                      initialValue:
                                          widget.item?.purchaseEnabled ?? false,
                                      name: 'item_specification_enabled',
                                      onChanged: (val) {
                                        setState(() {});
                                      },
                                      hint: '',
                                      hintStyle: AppText.heading5.copyWith(
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Offstage(
                                offstage: !(formValue<bool>(
                                      'item_specification_enabled',
                                    ) ??
                                    true),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: AppTextForm<double>(
                                            decoration: _formDeceoration,
                                            label: context.l10n.retailPrice,
                                            name: 'retail_price',
                                            initialValue:
                                                widget.item?.retailPrice,
                                            suffixIcon: AppToolTip(
                                              child: Text(
                                                context.l10n
                                                    .standardPriceAtWhichAProductIsOfferedToCustomersInARetailSetting,
                                                style: AppText.mediumN.copyWith(
                                                  color: AppColors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 26,
                                          width: 26,
                                        ),
                                        Expanded(
                                          child: AppTextForm<double>(
                                            decoration: _formDeceoration,
                                            label: context
                                                .l10n.itemQuantityPerUnit,
                                            name: 'quantity',
                                            initialValue: widget.item?.quantity,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Expanded(
                                                child: AppTypeAheadForm<Unit>(
                                                  decoration: _formDeceoration,
                                                  label: context.l10n.unit,
                                                  initialValue:
                                                      widget.item?.unit,
                                                  name: 'unit',
                                                  selectionToTextTransformer: (e) =>
                                                      '${e.name} ${e.shortName == null ? '' : '(${e.shortName}'} ',
                                                  itemBuilder:
                                                      (context, suggestion) {
                                                    return ListTile(
                                                      title:
                                                          Text(suggestion.name),
                                                    );
                                                  },
                                                  suggestionsCallback:
                                                      (String search) => ref
                                                          .read(
                                                            unitRepoProvider,
                                                          )
                                                          .getUnits(
                                                            pageSize: 20,
                                                            pageNumber: 1,
                                                            query: search,
                                                          )
                                                          .then(
                                                            (value) =>
                                                                value.data,
                                                          ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              FormAddButton(
                                                onTap: () async {
                                                  final unit =
                                                      await showDialog<Unit>(
                                                    context: context,
                                                    builder: (context) =>
                                                        const AddUnitDialog(),
                                                  );
                                                  if (unit != null) {
                                                    _formKey.currentState
                                                        ?.fields['unit']
                                                        ?.didChange(unit);
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 26,
                                          width: 26,
                                        ),
                                        Expanded(
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Expanded(
                                                child: AppTypeAheadForm<Brand>(
                                                  decoration: _formDeceoration,
                                                  label: context.l10n.brand,
                                                  initialValue:
                                                      widget.item?.brand,
                                                  name: 'brand',
                                                  suggestionsCallback:
                                                      (search) => ref
                                                          .read(
                                                            brandRepoProvider,
                                                          )
                                                          .getBrands(
                                                            pageSize: 20,
                                                            query: search,
                                                            pageNumber: 1,
                                                          )
                                                          .then(
                                                            (value) =>
                                                                value.data,
                                                          ),
                                                  itemBuilder:
                                                      (context, suggestion) =>
                                                          ListTile(
                                                    title:
                                                        Text(suggestion.name),
                                                  ),
                                                  selectionToTextTransformer:
                                                      (suggestion) =>
                                                          suggestion.name,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              FormAddButton(
                                                icon: const Icon(Icons.add),
                                                onTap: () async {
                                                  final brand =
                                                      await showDialog<Brand>(
                                                    context: context,
                                                    builder: (context) =>
                                                        const AddBrandDialog(),
                                                  );
                                                  if (brand != null) {
                                                    _formKey.currentState
                                                        ?.fields['brand']
                                                        ?.didChange(brand);
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      height: 300,
                                      child: QuillScreen(
                                        controller: _quillController,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 26),

                        ///MARK: UNIT

                        ///MARK: Sales Information

                        ///MARK: Purcahse Information
                        Offstage(
                          offstage: !_selectedItemTypeisGoods,
                          child: Column(
                            children: [
                              Container(
                                decoration: AppStyles.boxDecoration.copyWith(
                                  color: const Color.fromRGBO(255, 253, 243, 1),
                                  borderRadius: BorderRadius.circular(0),
                                  border: Border.all(color: Colors.yellow),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 18,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            context
                                                .l10n.trackInventoryForThisItem,
                                            style: AppText.heading5.copyWith(
                                              color: AppColors.primaryColor,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            context.l10n
                                                .enableStockTrackingAndReceiveAlertsWhenInventoryRunsLow,
                                            style: AppText.largeN.copyWith(
                                              color: AppColors.greyText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Row(
                                      children: [
                                        Expanded(
                                          child: Divider(
                                            height: 2,
                                            thickness: 1,
                                            color: Colors.yellow,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 18,
                                      ),
                                      child: Row(
                                        children: [
                                          const Spacer(
                                            flex: 10,
                                          ),
                                          Expanded(
                                            child: AppToggleForm(
                                              initialValue: widget
                                                      .item?.inventoryEnabled ??
                                                  false,
                                              name: 'track_inventory',
                                              onChanged: (val) {
                                                setState(() {});
                                              },
                                              hint: (((_formKey
                                                              .currentState
                                                              ?.fields[
                                                                  'track_inventory']
                                                              ?.value ??
                                                          false) as bool) ==
                                                      true)
                                                  ? context.l10n.enabled
                                                  : context.l10n.disabled,
                                              hintStyle:
                                                  AppText.mediumM.copyWith(
                                                color: AppColors.primaryColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Offstage(
                                      offstage: !(formValue<bool>(
                                            'track_inventory',
                                          ) ??
                                          true),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 18,
                                        ),
                                        decoration:
                                            AppStyles.boxDecoration.copyWith(
                                          borderRadius:
                                              BorderRadius.circular(0),
                                        ),
                                        child: Column(
                                          children: [
                                            const SizedBox(height: 12),
                                            if (widget.item == null) ...[
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: AppTextForm<double>(
                                                      decoration:
                                                          _formDeceoration,
                                                      name: 'opening_qty',
                                                      label: context
                                                          .l10n.openingStockQty,
                                                      initialValue: 0,
                                                      onChanged: (val) {
                                                        setState(() {});
                                                      },
                                                      suffixIcon: AppToolTip(
                                                        child: Text(
                                                          context.l10n
                                                              .stockAvailableForSaleAtTheBeginningOfTheAccountingPeriod,
                                                          style: AppText.mediumN
                                                              .copyWith(
                                                            color:
                                                                AppColors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 26,
                                                    width: 26,
                                                  ),
                                                  Expanded(
                                                    child: AppTextForm<double>(
                                                      decoration:
                                                          _formDeceoration,
                                                      label: context.l10n
                                                          .openingStockValuePrice,
                                                      name: 'opening_value',
                                                      initialValue: 0,
                                                      suffixIcon: AppToolTip(
                                                        child: Text(
                                                          context.l10n
                                                              .stockValueOpening,
                                                          style: AppText.mediumN
                                                              .copyWith(
                                                            color:
                                                                AppColors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 28),
                                            ],
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: AppTextForm<double>(
                                                    decoration:
                                                        _formDeceoration,
                                                    label:
                                                        context.l10n.alertQty,
                                                    initialValue: widget
                                                        .item?.alertQuantity,
                                                    name: 'alert_qty',
                                                    validator:
                                                        FormBuilderValidators
                                                            .compose([
                                                      if ((formValue<bool>(
                                                                'track_inventory',
                                                              ) ??
                                                              true) &&
                                                          _selectedItemTypeisGoods)
                                                        FormBuilderValidators
                                                            .required(),
                                                    ]),
                                                    suffixIcon: AppToolTip(
                                                      child: Text(
                                                        context.l10n
                                                            .predefinedStockLevel,
                                                        style: AppText.mediumN
                                                            .copyWith(
                                                          color:
                                                              AppColors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 26),
                                                const Spacer(),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 26, width: 26),
                              Container(
                                decoration: AppStyles.boxDecoration,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 18,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 20,
                                          child: Text(
                                            context
                                                .l10n.enterProductSerialNumber,
                                            style: AppText.heading5.copyWith(
                                              color: AppColors.primaryColor,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        Expanded(
                                          child: AppToggleForm(
                                            initialValue: widget
                                                .item?.serialNos.isNotEmpty,
                                            name: 'show_serial_no',
                                            onChanged: (val) {
                                              setState(() {});
                                            },
                                            hint: '',
                                            hintStyle:
                                                AppText.heading5.copyWith(
                                              color: AppColors.primaryColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Row(
                                    //   children: [
                                    //     Assets.icons.barcodeAlt.svg(height: 16),
                                    //     const SizedBox(width: 10),
                                    //     Expanded(
                                    //       child: AppToggleForm(
                                    //         activeColor: AppColors.green,
                                    //         name: 'show_serial_no',
                                    //         hint: context
                                    //             .l10n.enterProductSerialNumber,
                                    //         initialValue: widget
                                    //             .item?.serialNos.isNotEmpty,
                                    //         onChanged: (val) {
                                    //           setState(() {});
                                    //         },
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),

                                    if (formValue<bool>('show_serial_no') ??
                                        false) ...[
                                      const SizedBox(height: 26, width: 26),
                                      FormBuilderField<List<String>>(
                                        name: 'serial_number',
                                        initialValue: [
                                          ...?widget.item?.serialNos,
                                        ],
                                        builder: (
                                          FormFieldState<List<String>> field,
                                        ) {
                                          return Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Expanded(
                                                      child:
                                                          AppTextForm<String>(
                                                        decoration:
                                                            _formDeceoration,
                                                        label: context.l10n
                                                            .productSerialNumber,
                                                        name: 'sl.no',
                                                        inputFormatters: [
                                                          FilteringTextInputFormatter
                                                              .deny(
                                                            RegExp(
                                                              '[^a-zA-Z0-9]',
                                                            ),
                                                          ),
                                                        ],
                                                        onSubmitted: (_) {
                                                          _addSlNo();
                                                        },
                                                        focusNode: _serialFocus,
                                                        suffixIcon: IconButton(
                                                          onPressed: () async {
                                                            final res =
                                                                await SimpleBarcodeScanner
                                                                    .scanBarcode(
                                                              context,
                                                              isShowFlashIcon:
                                                                  true,
                                                              delayMillis: 2000,
                                                            );
                                                            if (res != null) {
                                                              _formKey
                                                                  .currentState
                                                                  ?.fields[
                                                                      'sl.no']
                                                                  ?.didChange(
                                                                res,
                                                              );
                                                            }
                                                          },
                                                          icon: const Icon(
                                                            Icons.qr_code,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    AppButton(
                                                      style: ButtonStyles
                                                          .secondary,
                                                      onPress: _addSlNo,
                                                      color: AppColors
                                                          .primaryColor,
                                                      label: Text(
                                                        context.l10n.add,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 26,
                                                width: 26,
                                              ),
                                              Expanded(
                                                child: Container(
                                                  height: 200,
                                                  margin: const EdgeInsets.only(
                                                    top: 24,
                                                  ),
                                                  padding:
                                                      const EdgeInsets.all(12),
                                                  color: AppColors.textfield,
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                      children: field.value
                                                              ?.map(
                                                                (e) => Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          Text(
                                                                        e,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 6,
                                                                    ),
                                                                    InkWell(
                                                                      onTap:
                                                                          () {
                                                                        formValue<List<String>>('serial_number')
                                                                            ?.remove(e);
                                                                        setState(
                                                                          () {},
                                                                        );
                                                                      },
                                                                      child:
                                                                          const Icon(
                                                                        CupertinoIcons
                                                                            .clear_circled,
                                                                        color: AppColors
                                                                            .red,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                              .toList() ??
                                                          [],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 26, width: 26),
                            ],
                          ),
                        ),

                        Offstage(
                          offstage: _selectedItemTypeisGoods,
                          child: Column(
                            children: [
                              Container(
                                decoration: AppStyles.boxDecoration,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 18,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FormBuilderField<List<SubService>>(
                                      name: 'sub_service',
                                      initialValue: [
                                        ...?widget.item?.subServices,
                                      ],
                                      valueTransformer: (value) => value
                                          ?.map((e) => e.toJson())
                                          .toList(),
                                      builder: (
                                        FormFieldState<List<SubService>> field,
                                      ) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  context.l10n.subServices,
                                                  style:
                                                      AppText.heading6.copyWith(
                                                    color:
                                                        AppColors.primaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            for (int i = 0;
                                                i < (field.value?.length ?? 0);
                                                i++) ...[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 16,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child:
                                                          AppTextForm<String>(
                                                        decoration:
                                                            _formDeceoration,
                                                        name: 'service-type-$i',
                                                        label: context
                                                            .l10n.serviceName,
                                                        validator:
                                                            FormBuilderValidators
                                                                .required(),
                                                        initialValue: field
                                                            .value?[i].name,
                                                        onChanged: (value) {
                                                          if (value != null) {
                                                            final changedField =
                                                                field.value!
                                                                    .removeAt(i)
                                                                    .copyWith(
                                                                      name:
                                                                          value,
                                                                    );
                                                            final fullField =
                                                                field.value
                                                                  ?..insert(
                                                                    i,
                                                                    changedField,
                                                                  );
                                                            field.didChange(
                                                              fullField,
                                                            );
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                    const SizedBox(width: 26),
                                                    Expanded(
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Expanded(
                                                            child: AppTextForm<
                                                                double>(
                                                              decoration:
                                                                  _formDeceoration,
                                                              validator:
                                                                  FormBuilderValidators
                                                                      .required(),
                                                              initialValue: field
                                                                  .value?[i]
                                                                  .additionalPrice,
                                                              name:
                                                                  'service-price-$i',
                                                              label: context
                                                                  .l10n
                                                                  .servicePrice,
                                                              onChanged:
                                                                  (value) {
                                                                if (value !=
                                                                    null) {
                                                                  final changedField = field
                                                                      .value!
                                                                      .removeAt(
                                                                        i,
                                                                      )
                                                                      .copyWith(
                                                                        additionalPrice:
                                                                            value,
                                                                      );
                                                                  final fullField =
                                                                      field
                                                                          .value
                                                                        ?..insert(
                                                                          i,
                                                                          changedField,
                                                                        );
                                                                  field
                                                                      .didChange(
                                                                    fullField,
                                                                  );
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          FormAddButton(
                                                            icon: const Icon(
                                                              Icons.delete,
                                                            ),
                                                            onTap: () async {
                                                              final changedField =
                                                                  field.value!
                                                                    ..removeAt(
                                                                      i,
                                                                    );
                                                              field.didChange(
                                                                changedField,
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            const SizedBox(height: 16),
                                            GestureDetector(
                                              onTap: () {
                                                final field = _formKey
                                                        .currentState!
                                                        .fields['sub_service']
                                                    as FormBuilderFieldState<
                                                        FormBuilderField<
                                                            List<SubService>>,
                                                        List<SubService>>?;

                                                field?.didChange([
                                                  if (field.value != null)
                                                    ...field.value!
                                                      ..add(
                                                        const SubService(
                                                          name: '',
                                                          additionalPrice: 0,
                                                        ),
                                                      )
                                                  else
                                                    const SubService(
                                                      name: '',
                                                      additionalPrice: 0,
                                                    ),
                                                ]);
                                                setState(() {});
                                              },
                                              child: Text(
                                                '+ ${context.l10n.addItem}',
                                                style:
                                                    AppText.heading6.copyWith(
                                                  color: AppColors.primaryColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 26, width: 26),
                            ],
                          ),
                        ),
                        if (itemState.customFields.isNotEmpty)
                          Container(
                            decoration: AppStyles.boxDecoration,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 18),
                                Text(
                                  context.l10n.customFields,
                                  style: AppText.heading5
                                      .copyWith(color: AppColors.primaryColor),
                                ),
                                const SizedBox(height: 12),
                                ...itemState.customFields.map(
                                  (e) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 26),
                                      child: AppTextForm<String>(
                                        decoration: _formDeceoration,
                                        label: e.fieldName,
                                        name: e.fieldName,
                                        initialValue: widget.item
                                            ?.customFields?[e.fieldName]?.value,
                                        validator:
                                            FormBuilderValidators.compose([
                                          if (e.isRequired)
                                            FormBuilderValidators.required(),
                                        ]),
                                      ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 100,
                      child: AppButton(
                        style: ButtonStyles.secondary,
                        color: AppColors.primaryColor,
                        onPress: AppRouter.pop,
                        label: Text(context.l10n.cancel),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 150,
                      child: AppButton(
                        onPress: () {
                          if (_formKey.currentState!.saveAndValidate()) {
                            itemNotifier.upsertItem(
                              {
                                ..._formKey.currentState!.value,
                                'item_id': widget.item?.itemId,
                                'rich_text': jsonEncode(
                                  _quillController.document.toDelta().toJson(),
                                ),
                              },
                              _images,
                              initialImages: widget.item?.images ?? [],
                            ).then((value) {
                              _formKey.currentState?.reset();
                            });
                          }
                        },
                        color: AppColors.primaryColor,
                        label: Text(context.l10n.saveNew),
                        isLoading: itemState.status == ItemStatus.loading,
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 150,
                      child: AppButton(
                        onPress: () {
                          if (_formKey.currentState!.saveAndValidate()) {
                            itemNotifier.upsertItem(
                              {
                                ..._formKey.currentState!.value,
                                'item_id': widget.item?.itemId,
                                'rich_text': jsonEncode(
                                  _quillController.document.toDelta().toJson(),
                                ),
                              },
                              _images,
                              initialImages: widget.item?.images ?? [],
                            ).then((value) => AppRouter.pop());
                          }
                        },
                        color: AppColors.primaryColor,
                        label: Text(context.l10n.save),
                        isLoading: itemState.status == ItemStatus.loading,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: DropRegion(
                    // Formats this region can accept.
                    formats: const [Formats.png, Formats.jpeg],
                    hitTestBehavior: HitTestBehavior.opaque,
                    onDropOver: (event) {
                      // This drop region only supports copy operation.
                      if (event.session.allowedOperations
                          .contains(DropOperation.copy)) {
                        return DropOperation.copy;
                      } else {
                        return DropOperation.none;
                      }
                    },
                    onDropEnter: (event) {
                      // This is called when region first accepts a drag. You can use this
                      // to display a visual indicator that the drop is allowed.
                    },
                    onDropLeave: (event) {
                      // Called when drag leaves the region. Will also be called after
                      // drag completion.
                      // This is a good place to remove any visual indicators.
                    },
                    onPerformDrop: (event) async {
                      // Called when user dropped the item. You can now request the data.
                      // Note that data must be requested before the performDrop callback
                      // is over.
                      final items = event.session.items;
                      for (final item in items) {
                        for (final element in [Formats.png, Formats.jpeg]) {
                          // Check if the item is an image format we accept
                          if (item.canProvide(element)) {
                            try {
                              // Get the data as bytes
                              item.dataReader?.getFile(
                                element,
                                (value) async {
                                  final bytes = await value.readAll();
                                  final _ = await decodeImageFromList(bytes);
                                  if (isValidFileSize(bytes, 10)) {
                                    setState(() {
                                      _images.add(ItemImage(bytes: bytes));
                                    });
                                  } else {
                                    Alert.showSnackBar(
                                      AppRouter.l10n.imageSizeExceeds10mb,
                                    );
                                  }
                                },
                              );
                            } catch (e) {
                              debugPrint('Error processing dropped image: $e');
                            }
                          }
                        }
                      }
                    },
                    child: InkWell(
                      onTap: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.image,
                          allowMultiple: true,
                          withData: true,
                        );

                        if (result != null) {
                          for (final file in result.files) {
                            if (file.bytes != null) {
                              try {
                                // Verify it's a valid image
                                await decodeImageFromList(file.bytes!);
                                setState(() {
                                  _images.add(ItemImage(bytes: file.bytes));
                                });
                              } on Exception catch (e) {
                                debugPrint('Error processing picked image: $e');
                                Alert.showSnackBar(
                                  e.toString(),
                                  type: SnackBarType.error,
                                );
                              }
                            }
                          }
                        }
                      },
                      child: DottedBorder(
                        stackFit: StackFit.passthrough,
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(12),
                        color: AppColors.borderColor,
                        strokeWidth: 2,
                        dashPattern: const [10],
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Assets.icons.cloud.image(),
                            const SizedBox(height: 14),
                            Text(
                              context.l10n.selectAFileOrDragAndDropHere,
                              style: AppText.mediumN
                                  .copyWith(color: AppColors.title),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              context.l10n.jpgOrPngFileSizeNoMoreThan10mb,
                              style: AppText.mediumN
                                  .copyWith(color: AppColors.greyText),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                GridView.builder(
                  itemCount: _images.length,
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemBuilder: (BuildContext context, int index) {
                    final image = _images[index];
                    final isBytes = image.bytes is Uint8List;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          children: [
                            AspectRatio(
                              aspectRatio: 1.2,
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: isBytes
                                    ? Image.memory(
                                        image.bytes!,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        image.url!,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Text('$error'),
                                      ),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _images.removeAt(index);
                                  });
                                },
                                child: const Icon(
                                  CupertinoIcons.clear_circled_solid,
                                  color: Color(0xffE1E1E1),
                                ),
                              ),
                            ),
                          ],
                        ),
                        AppCheckBoxForm(
                          name: 'image_$index',
                          hint: context.l10n.thumbnail,
                          initialValue: image.isThumbnail,
                          onChanged: (val) {
                            image.isThumbnail = val ?? false;
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addSlNo() {
    final no = _formKey.currentState?.fields['sl.no'];
    final serials = formValue<List<String>>('serial_number');
    if (no?.value != null) {
      _formKey.currentState?.fields['serial_number']
          ?.setValue([...serials ?? <String>[], no!.value as String]);
    }
    no?.reset();
    setState(() {});
    _serialFocus.requestFocus();
  }
}
