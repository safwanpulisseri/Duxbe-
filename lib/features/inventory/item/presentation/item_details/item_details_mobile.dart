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
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

part 'rich_text_screen.dart';

class ItemDetailsScreenMobile extends ConsumerStatefulWidget {
  const ItemDetailsScreenMobile({super.key, this.item});
  final Item? item;
  @override
  ConsumerState<ItemDetailsScreenMobile> createState() =>
      _ItemDetailsScreenMobileState();
}

class _ItemDetailsScreenMobileState
    extends ConsumerState<ItemDetailsScreenMobile>
    with TickerProviderStateMixin {
  bool _selectedItemTypeisGoods = true;
  final List<ItemImage> _images = [];
  final _itemNameController = TextEditingController();
  final _formKey = GlobalKey<FormBuilderState>();
  final _scrollController = ScrollController();
  final FocusNode _serialFocus = FocusNode();

  // Using a single map to store content keys and heights
  final Map<String, GlobalKey> _contentKeys = {};
  final Map<String, double> _contentHeights = {};
  final Map<String, AnimationController?> _animationControllers = {};
  final Map<String, Animation<double>?> _heightAnimations = {};

  // Section names for easier reference
  static const String basicInfo = 'basicInfo';
  static const String quantity = 'quantity';
  static const String salesInfo = 'salesInfo';
  static const String purchaseInfo = 'purchaseInfo';
  static const String inventoryInfo = 'inventoryInfo';
  static const String serialNumber = 'serialNumber';

  final QuillController _quillController = QuillController.basic();

  T? formValue<T>(String key) =>
      _formKey.currentState?.fields[key]?.value as T?;

  Future<String?> scanBarcode(BuildContext context) async {
    final res = await SimpleBarcodeScanner.scanBarcode(
      context,
      isShowFlashIcon: true,
      delayMillis: 2000,
    );

    return res;
  }

  
  @override
  void initState() {
    super.initState();

    _initializeKeys();
    _initializeAnimationControllers();

    if (widget.item != null) {
      _itemNameController.text = widget.item!.name;
      _images.addAll(widget.item!.images);
      if (widget.item!.richText != null) {
        try {
          _quillController.document = Document.fromJson(
              jsonDecode(widget.item!.richText!) as List<dynamic>);
        } catch (e) {
          debugPrint('Error decoding rich text JSON: $e');
          _quillController.document = Document();
        }
      }
      _selectedItemTypeisGoods = widget.item!.itemType == ItemType.goods;

      // --- START: MODIFICATION 1 ---
      // Use a single post-frame callback to initialize the state of all
      // expandable sections based on the incoming item's data.
      // This ensures the notifier's state matches the data from the start.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final notifier = ref.read(itemDetailsNotifierProvider.notifier);

          // If sales info should be visible, toggle its state in the notifier
          if (widget.item!.salesEnabled) {
            notifier.toggleSalesInfo();
          }

          // If purchase info should be visible, toggle its state
          if (widget.item!.purchaseEnabled) {
            notifier.togglePurchaseInfo();
          }

          // If inventory info should be visible, toggle its state
          if (widget.item!.inventoryEnabled) {
            notifier.toggleInventoryInfo();
          }

          // If serial numbers exist, toggle its state
          if (widget.item!.serialNos.isNotEmpty) {
            notifier.toggleSerialNumber();
          }
        }
      });
      // --- END: MODIFICATION 1 ---

      Future.microtask(() {
        if (mounted) {
          _initializeFromItem();
        }
      });
    } else {
      _fetchNextItemCode();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _calculateAllContentHeights();

        // --- START: MODIFICATION 2 ---
        // After calculating heights, check the state of ALL sections and set
        // the animation controller's value to 1.0 (fully expanded) if the
        // state is true. This makes them appear expanded on load without animating.

        // List of all expandable sections
        final allSections = [
          basicInfo,
          salesInfo,
          purchaseInfo,
          inventoryInfo,
          serialNumber
        ];

        for (final section in allSections) {
          if (_isSectionExpanded(section)) {
            // Set the controller to the end of its animation (fully expanded)
            _animationControllers[section]?.value = 1.0;
          }
        }
        // --- END: MODIFICATION 2 ---
      }
    });
  }

  void _initializeKeys() {
    final sections = [
      basicInfo,
      quantity,
      salesInfo,
      purchaseInfo,
      inventoryInfo,
      serialNumber
    ];
    for (final section in sections) {
      _contentKeys[section] = GlobalKey();
      _contentHeights[section] = 0;
    }
  }

  void _initializeAnimationControllers() {
    final sections = [
      basicInfo,
      quantity,
      salesInfo,
      purchaseInfo,
      inventoryInfo,
      serialNumber
    ];
    for (final section in sections) {
      _animationControllers[section] = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  void _initializeFromItem() {
    // Any additional heavy initialization from item can go here
    setState(() {});
  }

  Future<void> _fetchNextItemCode() async {
    final nextItemCode = await ref.read(itemRepoProvider).getNextItemCode();
    if (mounted) {
      _formKey.currentState?.fields['item_code']?.didChange(nextItemCode);
    }
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _scrollController.dispose();
    _serialFocus.dispose();
    _quillController.dispose();

    // Dispose all animation controllers
    for (final controller in _animationControllers.values) {
      controller?.dispose();
    }

    super.dispose();
  }

  final _formDeceorationWithBorder = InputDecoration(
    fillColor: AppColors.textfield,
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: AppColors.textfieldOutline),
      borderRadius: BorderRadius.circular(10),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: AppColors.textfieldOutline),
      borderRadius: BorderRadius.circular(10),
    ),
  );
  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );

    if (result != null) {
      for (final file in result.files) {
        if (file.bytes != null) {
          try {
            await decodeImageFromList(file.bytes!);
            if (isValidFileSize(file.bytes!, 10)) {
              setState(() {
                _images.add(ItemImage(bytes: file.bytes));
              });
            } else {
              Alert.showSnackBar(context.l10n.imageSizeExceeds10mb);
            }
          } catch (e) {
            debugPrint('Error processing picked image: $e');
          }
        }
      }
    }
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

  void _calculateAllContentHeights() {
    var needsUpdate = false;

    for (final section in _contentKeys.keys) {
      final renderBox = _contentKeys[section]
          ?.currentContext
          ?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final newHeight = renderBox.size.height;

        if (_contentHeights[section] != newHeight) {
          _contentHeights[section] = newHeight;
          _heightAnimations[section] = Tween<double>(
            begin: 0,
            end: newHeight,
          ).animate(
            CurvedAnimation(
              parent: _animationControllers[section]!,
              curve: Curves.easeInOut,
            ),
          );
          needsUpdate = true;
        }
      }
    }

    if (needsUpdate && mounted) {
      setState(() {});
    }
  }

  void _toggleSection(String section) {
    final notifier = ref.read(itemDetailsNotifierProvider.notifier);

    // Call the appropriate toggle method based on section
    switch (section) {
      case basicInfo:
        notifier.toggleBasicInfo();
      case quantity:
        notifier.toggleQuantity();
      case salesInfo:
        notifier.toggleSalesInfo();
      case purchaseInfo:
        notifier.togglePurchaseInfo();
      case inventoryInfo:
        notifier.toggleInventoryInfo();
      case serialNumber:
        notifier.toggleSerialNumber();
    }

    // Get the current state for the section
    final isExpanded = _isSectionExpanded(section);

    // Animate accordingly
    if (isExpanded) {
      _animationControllers[section]?.forward();
    } else {
      _animationControllers[section]?.reverse();
    }
  }

  bool _isSectionExpanded(String section) {
    final state = ref.read(itemDetailsNotifierProvider);
    switch (section) {
      case basicInfo:
        return state.isBasicInfoExpanded;
      case quantity:
        return state.isQuantityExpanded;
      case salesInfo:
        return state.isSalesInfoExpanded;
      case purchaseInfo:
        return state.isPurchaseInfoExpanded;
      case inventoryInfo:
        return state.isInventoryInfoExpanded;
      case serialNumber:
        return state.isSerialNumberExpanded;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemDetailsState = ref.watch(itemDetailsNotifierProvider);

    if (widget.item == null) {
      ref.listen(
        businessNotifierProvider,
        (previous, next) {
          _fetchNextItemCode();
        },
      );
    }

    // Use const widgets where possible and extract repeated widgets
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(widget.item == null
            ? context.l10n.itemDetails
            : context.l10n.addItem),
      ),
      bottomNavigationBar: _buildBottomBar(context),
      body: _buildFormBody(context, itemDetailsState),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.viewPaddingOf(context).bottom == 0
            ? 24
            : MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: AppButton(
        isLoading: ref.watch(itemNotifierProvider).status == ItemStatus.loading,
        label: Text(context.l10n.save),
        color: AppColors.primaryColor,
        onPress: () {
          final itemNotifier = ref.read(itemNotifierProvider.notifier);

          if (_formKey.currentState!.saveAndValidate()) {
            itemNotifier.upsertItem(
              {
                ..._formKey.currentState!.value,
                'item_id': widget.item?.itemId,
                if (widget.item != null)
                  'item_type': widget.item!.itemType.name,
              },
              _images,
              initialImages: widget.item?.images ?? [],
            ).then((value) {
              if (!mounted) return;
              AppRouter.pop();
            });
          }
        },
      ),
    );
  }

  Widget _buildFormBody(
      BuildContext context, ItemDetailsState itemDetailsState) {
    return FormBuilder(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        children: [
          if (widget.item == null) _buildItemTypeSelector(context),
          const SizedBox(height: 16),
          _buildImageUploader(context),
          const SizedBox(height: 12),
          _buildBasicInfoSection(context, itemDetailsState),
          if (_selectedItemTypeisGoods) ...[
            const SizedBox(height: 16),
            _buildPurchaseInfoSection(context, itemDetailsState),
          ],
          const SizedBox(height: 16),
          _buildSalesInfoSection(context, itemDetailsState),
          if (_selectedItemTypeisGoods) ...[
            const SizedBox(height: 16),
            _buildInventoryInfoSection(context, itemDetailsState),
            const SizedBox(height: 16),
            _buildSerialNumberSection(context, itemDetailsState),
          ],
          if (!_selectedItemTypeisGoods) ...[
            const SizedBox(height: 16),
            _buildSubServicesSection(context),
          ],
        ],
      ),
    );
  }

  Widget _buildItemTypeSelector(BuildContext context) {
    // Implementation of _buildItemTypeSelector
    return Offstage(
      offstage: widget.item != null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.lightPurple,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 2,
        ),
        child: Row(
          children: [
            Text(
              context.l10n.selectItemType,
              style: AppText.mediumM.copyWith(
                color: AppColors.primaryColor,
              ),
            ),
            Expanded(
              child: FormBuilderField<String>(
                initialValue: widget.item?.itemType.name ?? ItemType.goods.name,
                onChanged: (val) {
                  _selectedItemTypeisGoods = val == ItemType.goods.name;
                  setState(() {});
                },
                builder: (field) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ...ItemType.values.map(
                        (e) => Expanded(
                          child: Row(
                            children: [
                              Radio(
                                activeColor: AppColors.brandViolet,
                                value: e.name,
                                groupValue: field.value,
                                onChanged: field.didChange,
                              ),
                              Expanded(
                                child: Text(
                                  e.name.displayCase,
                                  style: AppText.mediumM.copyWith(
                                    color: AppColors.primaryColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
                name: 'item_type',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploader(BuildContext context) {
    // Implementation of _buildImageUploader
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFf8f9fb),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: (_images.isEmpty)
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Text(
                    context.l10n.uploadItemImage,
                    style: AppText.largeM.copyWith(
                      color: AppColors.greyText,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: _pickImages,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DottedBorder(
                          padding: const EdgeInsets.all(8),
                          borderType: BorderType.RRect,
                          color: AppColors.greyText,
                          radius: const Radius.circular(8),
                          child: Assets.icons.addImage.svg(
                            width: 26,
                            height: 26,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : SizedBox(
              height: 162, // Adjust height as needed
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length + 1, // +1 for the add button
                itemBuilder: (context, index) {
                  if (index == _images.length) {
                    // Add button at the end
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: _pickImages,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: const Color(0xFFEFF1F7),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  size: 30,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  // Image items
                  final image = _images[index];
                  return Container(
                    width: 145, // Adjust width as needed
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 145,
                          height: 102,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: AppColors.white,
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: image.bytes != null
                                      ? Image.memory(
                                          image.bytes!,
                                          fit: BoxFit.cover,
                                        )
                                      : image.url != null
                                          ? Image.network(
                                              image.url!,
                                              fit: BoxFit.cover,
                                            )
                                          : const SizedBox(),
                                ),
                              ),
                              Positioned(
                                top: -10,
                                right: -10,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _images.removeAt(index);
                                    });
                                  },
                                  child: const CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Color(0xFF3C4152),
                                    child: Icon(
                                      Icons.close,
                                      color: Color(0xffE1E1E1),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppCheckBoxForm(
                          name: 'image_$index',
                          hint: context.l10n.thumbnail,
                          initialValue: image.isThumbnail,
                          onChanged: (val) {
                            setState(() {
                              image.isThumbnail = val ?? false;
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildBasicInfoSection(
      BuildContext context, ItemDetailsState itemDetailsState) {
    // Implementation of _buildBasicInfoSection
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.1),
              blurRadius: 4,
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with toggle
            // InkWell(
            //   borderRadius: BorderRadius.circular(4),
            //   splashColor: Colors.transparent,
            //   onTap: () => _toggleSection(basicInfo),
            //   child: Container(
            //     padding: const EdgeInsets.symmetric(
            //       horizontal: 8,
            //       vertical: 10,
            //     ),
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(4),
            //       color: AppColors.purple.withOpacity(0.06),
            //     ),
            //     child: Row(
            //       children: [
            //         Text(
            //           context.l10n.basicInformation,
            //           style: AppText.largeM.copyWith(color: AppColors.black),
            //         ),
            //         const Spacer(),
            //         Icon(
            //           itemDetailsState.isBasicInfoExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            //           color: AppColors.black,
            //         ),
            //       ],
            //     ),
            //   ),
            // ),

            // Expandable content
            Container(
              key: _contentKeys[basicInfo],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  AppTextForm<String>(
                    validator: FormBuilderValidators.required(
                        errorText: context.l10n.itemNameShouldNotBeEmpty),
                    secondaryLabel: '${context.l10n.itemName} *',
                    hintText: '${context.l10n.itemName} *',
                    name: 'name',
                    initialValue: widget.item?.name,
                    decoration: _formDeceorationWithBorder,
                  ),
                  // const SizedBox(height: 8),
                  AppCheckBoxForm(
                    name: 'is_returnable',
                    hint: 'Returnable Item',
                    initialValue: widget.item?.isReturnable,
                  ),
                  const SizedBox(height: 3),
                  AppTextForm<String>(
                    name: 'item_code',
                    style: AppText.largeM.copyWith(
                      color: AppColors.orange,
                    ),
                    hintText: context.l10n.itemCode,
                    decoration: _formDeceorationWithBorder,
                    secondaryLabel: context.l10n.itemCode,
                    initialValue: widget.item?.itemCode,
                    validator: FormBuilderValidators.required(),
                    isReadOnly: true,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: AppTypeAheadForm<ItemCategory>(
                          secondaryLabel: context.l10n.category,
                          name: 'item_category',
                          initialValue: widget.item?.itemCategory,
                          decoration: _formDeceorationWithBorder,
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
                          itemBuilder: (context, suggestion) => ListTile(
                            title: Text(suggestion.name),
                          ),
                          selectionToTextTransformer: (suggestion) =>
                              suggestion.name,
                        ),
                      ),
                      const SizedBox(width: 4),
                      FormAddButton(
                        icon: const Icon(Icons.add),
                        onTap: () async {
                          final category = await showDialog<ItemCategory>(
                            context: context,
                            builder: (context) => const AddCategoryDialog(),
                          );
                          if (category != null) {
                            _formKey.currentState?.fields['item_category']
                                ?.didChange(category);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AppTextForm<double>(
                    secondaryLabel: _selectedItemTypeisGoods
                        ? context.l10n.salePrice
                        : context.l10n.servicePrice,
                    decoration: _formDeceorationWithBorder,
                    name: 'sale_price',
                    initialValue: widget.item?.salePrice,
                    validator: FormBuilderValidators.compose([
                      if (formValue<bool>('sales_enabled') ?? true)
                        FormBuilderValidators.required(
                          errorText: context.l10n.pleaseEnterTheSalePrice,
                        ),
                    ]),
                    suffixIcon: AppToolTip(
                      child: Text(
                        context.l10n.salePriceToolTip,
                        style: AppText.mediumN.copyWith(color: AppColors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AppTypeAheadForm<Tax>(
                    secondaryLabel: AppRouter.l10n.tax,
                    decoration: _formDeceorationWithBorder,
                    name: 'tax',
                    initialValue: widget.item?.tax,
                    selectionToTextTransformer: (e) => '${e.name} (${e.rate}%)',
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text('${suggestion.name} (${suggestion.rate}%)'),
                      );
                    },
                    suggestionsCallback: (String search) => ref
                        .read(taxRepoProvider)
                        .getTaxes(
                          query: search,
                          pageSize: 20,
                          pageNumber: 1,
                        )
                        .then((value) => value.data),
                  ),
                  const SizedBox(height: 8),
                  AppCheckBoxForm(
                    name: 'is_tax_inclusive',
                    initialValue: widget.item?.isTaxInclusive ?? false,
                    hint: 'Is Tax Inclusive',
                  ),

                  // Offstage(
                  //   offstage: !_selectedItemTypeisGoods,
                  //   child: Column(
                  //     children: [
                  //       const SizedBox(height: 8),
                  //       Row(
                  //         children: [
                  //           Expanded(
                  //             child: AppTypeAheadForm<Brand>(
                  //               secondaryLabel: context.l10n.brand,
                  //               initialValue: widget.item?.brand,
                  //               name: 'brand',
                  //               suggestionsCallback: (search) => ref
                  //                   .read(brandRepoProvider)
                  //                   .getBrands(pageSize: 20, query: search, pageNumber: 1)
                  //                   .then((value) => value.data),
                  //               itemBuilder: (context, suggestion) => ListTile(
                  //                 title: Text(suggestion.name),
                  //               ),
                  //               selectionToTextTransformer: (suggestion) => suggestion.name,
                  //             ),
                  //           ),
                  //           const SizedBox(width: 4),
                  //           FormAddButton(
                  //             icon: const Icon(Icons.add),
                  //             onTap: () async {
                  //               final brand = await showDialog<Brand>(
                  //                 context: context,
                  //                 builder: (context) => const AddBrandDialog(),
                  //               );
                  //               if (brand != null) {
                  //                 _formKey.currentState?.fields['brand']?.didChange(brand);
                  //               }
                  //             },
                  //           ),
                  //         ],
                  //       ),

                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRichTextEditor(BuildContext context) {
    // Implementation of _buildRichTextEditor
    return FormBuilderField<String>(
      name: 'rich_text',
      initialValue: widget.item?.richText,
      builder: (field) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              final result = await context.pushNamed(AppRouter.richText,
                  extra: field.value);
              if (result != null) {
                field.didChange(result as String);
              }
            },
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFF7F7F7),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Row(
                children: [
                  Text(
                    '${field.value?.isNotEmpty ?? false ? 'Edit' : 'Add'} Description',
                    style: AppText.largeM.copyWith(color: AppColors.black),
                  ),
                  const Spacer(),
                  AppButton(
                    color: (field.value?.isNotEmpty ?? false)
                        ? AppColors.green
                        : AppColors.primaryColor,
                    onPress: () async {
                      final result = await context.pushNamed(AppRouter.richText,
                          extra: field.value);
                      if (result != null) {
                        field.didChange(result as String);
                      }
                    },
                    label: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        field.value?.isNotEmpty ?? false ? 'Edit' : 'Add',
                        style: AppText.largeM,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSalesInfoSection(
      BuildContext context, ItemDetailsState itemDetailsState) {
    // Implementation of _buildSalesInfoSection
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.1),
              blurRadius: 4,
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(4),
              splashColor: Colors.transparent,
              onTap: () => _toggleSection(salesInfo),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: AppColors.purple.withOpacity(0.06),
                ),
                child: AppToggleForm(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  activeColor: AppColors.primaryColor,
                  name: 'sales_enabled',
                  hint: context.l10n.itemSpecification,
                  initialValue: widget.item?.salesEnabled ?? false,
                  onChanged: (val) {
                    _toggleSection(salesInfo);
                  },
                ),
              ),
            ),

            // Expandable content
            AnimatedBuilder(
              animation: _animationControllers[salesInfo]!,
              builder: (context, child) {
                return ClipRect(
                  child: SizedOverflowBox(
                    size: Size(double.infinity,
                        _heightAnimations[salesInfo]?.value ?? 0),
                    alignment: Alignment.topCenter,
                    child: child,
                  ),
                );
              },
              child: Container(
                key: _contentKeys[salesInfo],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    AppTextForm<double>(
                      secondaryLabel: context.l10n.retailPrice,
                      name: 'retail_price',
                      initialValue: widget.item?.retailPrice,
                      suffixIcon: AppToolTip(
                        child: Text(
                          context.l10n
                              .standardPriceAtWhichAProductIsOfferedToCustomersInARetailSetting,
                          style:
                              AppText.mediumN.copyWith(color: AppColors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppTextForm<double>(
                      secondaryLabel: context.l10n.itemQuantityPerUnit,
                      name: 'quantity',
                      initialValue: widget.item?.quantity,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: AppTypeAheadForm<Unit>(
                            secondaryLabel: context.l10n.unit,
                            initialValue: widget.item?.unit,
                            name: 'unit',
                            selectionToTextTransformer: (e) =>
                                '${e.name} ${e.shortName == null ? '' : '(${e.shortName})'} ',
                            itemBuilder: (context, suggestion) {
                              return ListTile(title: Text(suggestion.name));
                            },
                            suggestionsCallback: (String search) => ref
                                .read(unitRepoProvider)
                                .getUnits(
                                    pageSize: 20, pageNumber: 1, query: search)
                                .then((value) => value.data),
                          ),
                        ),
                        const SizedBox(width: 10),
                        FormAddButton(
                          onTap: () async {
                            final unit = await showDialog<Unit>(
                              context: context,
                              builder: (context) => const AddUnitDialog(),
                            );
                            if (unit != null) {
                              _formKey.currentState?.fields['unit']
                                  ?.didChange(unit);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: AppTypeAheadForm<Brand>(
                            decoration: _formDeceorationWithBorder,
                            secondaryLabel: context.l10n.brand,
                            initialValue: widget.item?.brand,
                            name: 'brand',
                            suggestionsCallback: (search) => ref
                                .read(
                                  brandRepoProvider,
                                )
                                .getBrands(
                                  pageSize: 20,
                                  query: search,
                                  pageNumber: 1,
                                )
                                .then(
                                  (value) => value.data,
                                ),
                            itemBuilder: (context, suggestion) => ListTile(
                              title: Text(suggestion.name),
                            ),
                            selectionToTextTransformer: (suggestion) =>
                                suggestion.name,
                          ),
                        ),
                        const SizedBox(width: 10),
                        FormAddButton(
                          icon: const Icon(Icons.add),
                          onTap: () async {
                            final brand = await showDialog<Brand>(
                              context: context,
                              builder: (context) => const AddBrandDialog(),
                            );
                            if (brand != null) {
                              _formKey.currentState?.fields['brand']
                                  ?.didChange(brand);
                            }
                          },
                        ),
                      ],
                    ),
                    _buildRichTextEditor(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseInfoSection(
      BuildContext context, ItemDetailsState itemDetailsState) {
    // Implementation of _buildPurchaseInfoSection
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.1),
              blurRadius: 4,
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(4),
              splashColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: AppColors.purple.withOpacity(0.06),
                ),
                child: AppToggleForm(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  activeColor: AppColors.primaryColor,
                  name: 'purchase_enabled',
                  hint: context.l10n.purchaseInformation,
                  initialValue: widget.item?.purchaseEnabled ?? false,
                  onChanged: (val) {
                    _toggleSection(purchaseInfo);
                  },
                ),
              ),
            ),

            // Expandable content
            AnimatedBuilder(
              animation: _animationControllers[purchaseInfo]!,
              builder: (context, child) {
                return ClipRect(
                  child: SizedOverflowBox(
                    size: Size(double.infinity,
                        _heightAnimations[purchaseInfo]?.value ?? 0),
                    alignment: Alignment.topCenter,
                    child: child,
                  ),
                );
              },
              child: Container(
                key: _contentKeys[purchaseInfo],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    AppTextForm<double>(
                      label: context.l10n.purchasePrice,
                      name: 'purchase_price',
                      initialValue: widget.item?.purchasePrice,
                      decoration: _formDeceorationWithBorder,
                      validator: FormBuilderValidators.compose([
                        if ((formValue<bool>('purchase_enabled') ?? true) &&
                            _selectedItemTypeisGoods)
                          FormBuilderValidators.required(
                            errorText: context.l10n.pleaseEnterThePuchasePrice,
                          ),
                      ]),
                      suffixIcon: AppToolTip(
                        child: Text(
                          context.l10n.theRateAtWhichThisItemIsPurchased,
                          style:
                              AppText.mediumN.copyWith(color: AppColors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // AppTypeAheadForm<Supplier>(
                    //   secondaryLabel: context.l10n.preferredVendor,
                    //   name: 'preferred_vendor',
                    //   selectionToTextTransformer: (e) =>
                    //       '${e.name}, ${e.phone}',
                    //   itemBuilder: (context, suggestion) => ListTile(
                    //     title: Text(suggestion.name),
                    //     subtitle: Text(suggestion.phone),
                    //   ),
                    //   suggestionsCallback: (String search) => ref
                    //       .read(supplierRepoProvider)
                    //       .getSuppliers(
                    //         pageSize: 20,
                    //         pageNumber: 1,
                    //         query: search,
                    //       )
                    //       .then((value) => value.data),
                    // ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: AppTypeAheadForm<Supplier>(
                            decoration: _formDeceorationWithBorder,
                            label: context.l10n.preferredVendor,
                            name: 'preferred_vendor',
                            enabled: formValue<bool>(
                                  'purchase_enabled',
                                ) ??
                                true,
                            selectionToTextTransformer: (e) =>
                                '${e.name}, ${e.phone}',
                            initialValue: widget.item?.preferredSupplier,
                            itemBuilder: (context, suggestion) => ListTile(
                              title: Text(suggestion.name),
                              subtitle: Text(suggestion.phone),
                            ),
                            suggestionsCallback: (String search) => ref
                                .read(
                                  supplierRepoProvider,
                                )
                                .getSuppliers(
                                  pageSize: 20,
                                  pageNumber: 1,
                                  query: search,
                                )
                                .then(
                                  (value) => value.data,
                                ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        FormAddButton(
                          onTap: () async {
                            final supplier = await showDialog<Supplier>(
                              context: context,
                              builder: (context) {
                                return AddSupplierDialog(
                                    supplierName:
                                        widget.item?.preferredSupplier?.name);
                              },
                            );
                            if (supplier != null) {
                              _formKey.currentState!.fields['preferred_vendor']
                                  ?.didChange(supplier);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryInfoSection(
      BuildContext context, ItemDetailsState itemDetailsState) {
    // Implementation of _buildInventoryInfoSection
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.yellow),
          color: const Color.fromRGBO(255, 253, 243, 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with toggle
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 10,
              ),
              child: Text(
                context.l10n.trackInventoryForThisItem,
                style: AppText.largeM.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),

              // InkWell(
              //   borderRadius: BorderRadius.circular(4),
              //   splashColor: Colors.transparent,
              //   onTap: () => _toggleSection(inventoryInfo),
              //   child: Container(
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: 8,
              //       vertical: 10,
              //     ),
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(4),
              //       color: AppColors.purple.withOpacity(0.06),
              //     ),
              //     child: Row(
              //       children: [
              // FormBuilderField<bool>(
              //   name: 'track_inventory',
              //   initialValue: widget.item?.inventoryEnabled ?? false,
              //   builder: (field) {
              //             return SizedBox(
              //               height: 24,
              //               width: 24,
              //               child: Checkbox(
              //                 value: field.value,
              //                 onChanged: (val) {
              //                   field.didChange(val);
              //                 },
              //                 visualDensity: VisualDensity.compact,
              //                 materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              //                 splashRadius: 0,
              //               ),
              //             );
              //           },
              //         ),
              //         const SizedBox(width: 8),
              //         Text(
              //           context.l10n.inventoryInformation,
              //           style: AppText.largeM.copyWith(color: AppColors.black),
              //         ),
              //         const Spacer(),
              //         Icon(
              //           itemDetailsState.isInventoryInfoExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              //           color: AppColors.black,
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ),
            Ink(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.white,
              ),
              child: Text(
                context.l10n
                    .enableStockTrackingAndReceiveAlertsWhenInventoryRunsLow,
                style: AppText.largeN.copyWith(
                  color: AppColors.greyText,
                ),
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
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: AppToggleForm(
                mainAxisAlignment: MainAxisAlignment.end,
                initialValue: widget.item?.inventoryEnabled ?? false,
                name: 'track_inventory',
                crossAxisAlignment: CrossAxisAlignment.center,
                onChanged: (val) {
                  _toggleSection(inventoryInfo);
                },
                hint: (((_formKey.currentState?.fields['track_inventory']
                                ?.value ??
                            false) as bool) ==
                        true)
                    ? context.l10n.enabled
                    : context.l10n.disabled,
                hintStyle: AppText.mediumM.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            ),

            // Expandable content
            AnimatedBuilder(
              animation: _animationControllers[inventoryInfo]!,
              builder: (context, child) {
                return ClipRect(
                  child: SizedOverflowBox(
                    size: Size(double.infinity,
                        _heightAnimations[inventoryInfo]?.value ?? 0),
                    alignment: Alignment.topCenter,
                    child: child,
                  ),
                );
              },
              child: Container(
                key: _contentKeys[inventoryInfo],
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    if (widget.item == null) ...[
                      AppTextForm<double>(
                        name: 'opening_qty',
                        secondaryLabel: context.l10n.openingStockQty,
                        initialValue: 0,
                        suffixIcon: AppToolTip(
                          child: Text(
                            context.l10n
                                .stockAvailableForSaleAtTheBeginningOfTheAccountingPeriod,
                            style: AppText.mediumN
                                .copyWith(color: AppColors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      AppTextForm<double>(
                        secondaryLabel: context.l10n.openingStockValuePrice,
                        name: 'opening_value',
                        initialValue: 0,
                        suffixIcon: AppToolTip(
                          child: Text(
                            context.l10n.stockValueOpening,
                            style: AppText.mediumN
                                .copyWith(color: AppColors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    AppTextForm<double>(
                      secondaryLabel: context.l10n.alertQty,
                      initialValue: widget.item?.alertQuantity,
                      name: 'alert_qty',
                      validator: FormBuilderValidators.compose([
                        if ((formValue<bool>('track_inventory') ?? true) &&
                            _selectedItemTypeisGoods)
                          FormBuilderValidators.required(),
                      ]),
                      suffixIcon: AppToolTip(
                        child: Text(
                          context.l10n.predefinedStockLevel,
                          style:
                              AppText.mediumN.copyWith(color: AppColors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSerialNumberSection(
      BuildContext context, ItemDetailsState itemDetailsState) {
    // Implementation of _buildSerialNumberSection
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.1),
              blurRadius: 4,
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with toggle
            InkWell(
              borderRadius: BorderRadius.circular(4),
              splashColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: AppColors.purple.withOpacity(0.06),
                ),
                child: AppToggleForm(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  activeColor: AppColors.green,
                  name: 'show_serial_no',
                  hint: context.l10n.enterProductSerialNumber,
                  initialValue: widget.item?.serialNos.isNotEmpty,
                  onChanged: (val) {
                    _toggleSection(serialNumber);
                  },
                ),
              ),
            ),

            // Expandable content
            AnimatedBuilder(
              animation: _animationControllers[serialNumber]!,
              builder: (context, child) {
                return ClipRect(
                  child: SizedOverflowBox(
                    size: Size(double.infinity,
                        _heightAnimations[serialNumber]?.value ?? 0),
                    alignment: Alignment.topCenter,
                    child: child,
                  ),
                );
              },
              child: Container(
                key: _contentKeys[serialNumber],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    FormBuilderField<List<String>>(
                      name: 'serial_number',
                      initialValue: [...?widget.item?.serialNos],
                      builder: (FormFieldState<List<String>> field) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: AppTextForm<String>(
                                    label: context.l10n.productSerialNumber,
                                    name: 'sl.no',
                                    inputFormatters: [
                                      FilteringTextInputFormatter.deny(
                                          RegExp('[^a-zA-Z0-9]')),
                                    ],
                                    onSubmitted: (_) {
                                      _addSlNo();
                                    },
                                    focusNode: _serialFocus,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                FormAddButton(
                                  icon: Assets.icons.barcode.svg(),
                                  onTap: () async {
                                    final barcode = await scanBarcode(context);
                                    if (barcode != null) {
                                      field.didChange(
                                          [...field.value ?? [], barcode]);
                                    }
                                  },
                                ),
                                const SizedBox(width: 4),
                                AppButton(
                                  height: 48,
                                  style: ButtonStyles.secondary,
                                  color: AppColors.primaryColor,
                                  onPress: _addSlNo,
                                  label: Text(context.l10n.add),
                                ),
                              ],
                            ),
                            Container(
                              height: 200,
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.all(12),
                              color: AppColors.textfield,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: field.value
                                          ?.map(
                                            (e) => Row(
                                              children: [
                                                Expanded(child: Text(e)),
                                                const SizedBox(width: 6),
                                                InkWell(
                                                  onTap: () {
                                                    formValue<List<String>>(
                                                            'serial_number')
                                                        ?.remove(e);
                                                    setState(() {});
                                                  },
                                                  child: const Icon(
                                                    CupertinoIcons
                                                        .clear_circled,
                                                    color: AppColors.red,
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
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubServicesSection(BuildContext context) {
    // Implementation of _buildSubServicesSection
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.1),
              blurRadius: 4,
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with toggle
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: AppColors.purple.withOpacity(0.06),
              ),
              child: Row(
                children: [
                  Text(
                    context.l10n.subServices,
                    style: AppText.largeM.copyWith(color: AppColors.black),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            Column(
              children: [
                FormBuilderField<List<SubService>>(
                  name: 'sub_service',
                  initialValue: [...?widget.item?.subServices],
                  valueTransformer: (value) =>
                      value?.map((e) => e.toJson()).toList(),
                  builder: (FormFieldState<List<SubService>> field) {
                    return Column(
                      children: [
                        for (int i = 0;
                            i < (field.value?.length ?? 0);
                            i++) ...[
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: AppTextForm<String>(
                                    name: 'service-type-$i',
                                    secondaryLabel: context.l10n.serviceName,
                                    validator: FormBuilderValidators.required(),
                                    initialValue: field.value?[i].name,
                                    onChanged: (value) {
                                      if (value != null) {
                                        final changedField = field.value!
                                            .removeAt(i)
                                            .copyWith(name: value);
                                        final fullField = field.value
                                          ?..insert(i, changedField);
                                        field.didChange(fullField);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: AppTextForm<double>(
                                          validator:
                                              FormBuilderValidators.required(),
                                          initialValue:
                                              field.value?[i].additionalPrice,
                                          name: 'service-price-$i',
                                          secondaryLabel:
                                              context.l10n.servicePrice,
                                          onChanged: (value) {
                                            if (value != null) {
                                              final changedField = field.value!
                                                  .removeAt(i)
                                                  .copyWith(
                                                      additionalPrice: value);
                                              final fullField = field.value
                                                ?..insert(i, changedField);
                                              field.didChange(fullField);
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      FormAddButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: AppColors.red,
                                        ),
                                        onTap: () async {
                                          final changedField = field.value!
                                            ..removeAt(i);
                                          field.didChange(changedField);
                                        },
                                      ),
                                    ],
                                  ),
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
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                final field = _formKey.currentState!.fields['sub_service']
                    as FormBuilderFieldState<FormBuilderField<List<SubService>>,
                        List<SubService>>?;

                field?.didChange([
                  if (field.value != null)
                    ...field.value!
                      ..add(const SubService(name: '', additionalPrice: 0))
                  else
                    const SubService(name: '', additionalPrice: 0),
                ]);
                setState(() {});
              },
              child: Text(
                '+ ${context.l10n.addItem}',
                style: AppText.mediumSB.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
