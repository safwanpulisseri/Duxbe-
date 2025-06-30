import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/features/sale/presentation/sales/service_selection_dialog.dart';
import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

final showSquareProvider = StateProvider<bool>((ref) => true);

class SalesScreenMobile extends ConsumerStatefulWidget {
  const SalesScreenMobile({super.key});

  @override
  ConsumerState<SalesScreenMobile> createState() => _SalesScreenMobileState();
}

class _SalesScreenMobileState extends ConsumerState<SalesScreenMobile> {
  final _debouncer = Debouncer(milliseconds: 500);
  final _formKey = GlobalKey<FormBuilderState>();

  void _clear() {
    if (!mounted) return;
    if (GoRouter.of(AppRouter.rootContext).routerDelegate.currentConfiguration.uri.queryParameters['clear'] == 'true') {
      debugPrint('------->>>>>>>clear is true');

      // Reset the form properly
      _formKey.currentState?.reset();

      // Reset the sales state through the notifier
      ref.read(salesNotifierProvider.notifier).resetForm();

      // Remove the clear parameter from URL to prevent multiple resets
      if (mounted) {
        GoRouter.of(context).replaceNamed(AppRouter.pos);
      }
    }
  }

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
    GoRouter.of(AppRouter.rootContext).routerDelegate.addListener(_clear);
  }

  TextEditingController searchController = TextEditingController();
  @override
  void dispose() {
    searchController.dispose();
    GoRouter.of(AppRouter.rootContext).routerDelegate.removeListener(_clear);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final salesNotifier = ref.watch(salesNotifierProvider.notifier);
    final salesState = ref.watch(salesNotifierProvider);
    final orderMode = GoRouter.of(context).routerDelegate.currentConfiguration.uri.queryParameters['order_mode'];
    final currency = ref.watch(currencyProvider);
    final showSquare = ref.watch(showSquareProvider);
    final business = ref.watch(businessNotifierProvider);
    final allowSalesWhenStockOut = business?.allowSalesWhenOutOfStock ?? false;
    return FormBuilder(
      key: _formKey,
      child: Scaffold(
        appBar: CustomAppBar(
          title: Text(context.l10n.pos),
          actions: [
            FormBuilderField(
              name: 'order_mode',
              initialValue: business?.businessType == BusinessType.foodAndBeverage ? true : orderMode == 'true',
              builder: (FormFieldState<bool> field) {
                return GestureDetector(
                  onTap: () {
                    field.didChange(!field.value!);
                    salesNotifier.updateOrderMode(orderMode: !field.value!);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(context.l10n.orderMode, style: AppText.largeM.copyWith(color: AppColors.primaryColor)),
                      SizedBox(
                        height: 30,
                        width: 42,
                        child: Transform.scale(
                          transformHitTests: false,
                          scale: .6,
                          child: CupertinoSwitch(
                            thumbColor: AppColors.white,
                            activeTrackColor: AppColors.primaryColor,
                            inactiveTrackColor: AppColors.stormyBlue,
                            value: field.value ?? false,
                            onChanged: (value) {
                              field.didChange(value);
                              salesNotifier.updateOrderMode(orderMode: value);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            bottom: MediaQuery.viewPaddingOf(context).bottom == 0 ? 16 : MediaQuery.viewPaddingOf(context).bottom,
          ),
          child: Builder(
            builder: (context) {
              final total = salesState.saleItems.fold<double>(
                0,
                (previousValue, element) =>
                    previousValue +
                    (element.quantity * element.unitPrice) +
                    element.selectedSubServices.fold<double>(
                      0,
                      (sum, e) => sum + e.additionalPrice,
                    ),
              );
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (salesState.saleItems.isNotEmpty)
                    AppButton(
                      onPress: () {
                        if (salesState.saleItems.isEmpty) {
                          Alert.showSnackBar(context.l10n.pleaseSelectAtLeastOneItem);
                          return;
                        }

                        AppRouter.pushNamed(AppRouter.salePayment)?.then(
                          (value) {
                            setState(() {});
                          },
                        );
                      },
                      label: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Assets.icons.cartIcon.svg(width: 26, height: 26),
                              const SizedBox(width: 8),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${salesState.saleItems.length} ',
                                      style: AppText.largeSB.copyWith(color: AppColors.orange),
                                    ),
                                    TextSpan(
                                      text: context.l10n.items,
                                      style: AppText.largeSB,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: context.l10n.total,
                                  style: AppText.largeM,
                                ),
                                TextSpan(
                                  text: ': $currency$total',
                                  style: AppText.largeSB,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (salesState.heldCarts.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    AppButton(
                      style: ButtonStyles.secondary,
                      onPress: () async {
                        await showDialog<void>(
                          context: context,
                          builder: (context) {
                            return MobileHoldBillDialog(
                              onDelete: (cartData) {},
                              onRecall: (cartData) {},
                            );
                          },
                        );
                      },
                      label: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(context.l10n.recallBill),
                          const SizedBox(width: 20),
                          Container(
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: AppColors.brandViolet,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(6),
                            child: Text(
                              '${salesState.heldCarts.length}',
                              style: AppText.mediumB.copyWith(color: AppColors.white),
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
        ),
        body: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextForm<String>(
                controller: searchController,
                name: 'search',
                hintText: context.l10n.enterNameOrSerialNumber,
                onChanged: (v) {
                  _debouncer.run(() {
                    salesNotifier.setFilter(query: v);
                  });
                },
                prefixIcon: GestureDetector(
                  onTap: () async {
                    final res = await scanBarcode(context);
                    if (res != null) {
                      salesNotifier.setFilter(query: res);
                    }
                  },
                  child: const Icon(Icons.qr_code_2_outlined),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xffF2F2F3),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: const Color(0xffE3E3E7)),
                      ),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              salesNotifier.setFilter(type: ItemType.goods);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: salesState.selectedItemType == ItemType.goods
                                    ? AppColors.brandViolet
                                    : const Color(0xffF2F2F3),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Assets.icons.goodsMini.svg(
                                    colorFilter: ColorFilter.mode(
                                      salesState.selectedItemType == ItemType.goods
                                          ? AppColors.white
                                          : const Color(0xff7D7F88),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    context.l10n.goods,
                                    style: AppText.mediumM.copyWith(
                                      color: salesState.selectedItemType == ItemType.goods
                                          ? AppColors.white
                                          : const Color(0xff7D7F88),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              salesNotifier.setFilter(type: ItemType.services);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: salesState.selectedItemType == ItemType.services
                                    ? AppColors.brandViolet
                                    : const Color(0xffF2F2F3),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Assets.icons.serviceMini.svg(
                                    colorFilter: ColorFilter.mode(
                                      salesState.selectedItemType == ItemType.services
                                          ? AppColors.white
                                          : const Color(0xff7D7F88),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    context.l10n.services,
                                    style: AppText.mediumM.copyWith(
                                      color: salesState.selectedItemType == ItemType.services
                                          ? AppColors.white
                                          : const Color(0xff7D7F88),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        ref.read(showSquareProvider.notifier).state = !showSquare;
                      },
                      icon: showSquare ? Assets.icons.viewBySquare.svg() : Assets.icons.viewByList.svg(),
                      label: Text(
                        context.l10n.viewBy,
                        style: AppText.smallN.copyWith(color: AppColors.orange),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: FormBuilderField<List<SaleItem>>(
                  onChanged: (v) {
                    setState(() {});
                  },
                  name: 'items',
                  onReset: salesNotifier.resetForm,
                  validator: FormBuilderValidators.notEqual([], errorText: context.l10n.pleaseSelectAtLeastOneItem),
                  initialValue: const [],
                  builder: (field) => showSquare
                      ? PagedListView<int, Item>.separated(
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          pagingController: salesState.pagingController!,
                          builderDelegate: PagedChildBuilderDelegate(
                            noItemsFoundIndicatorBuilder: (context) {
                              if (searchController.text.isNotEmpty) {
                                return const NoSearchItemWidget();
                              }
                              return const NoDataViewWidget();
                            },
                            itemBuilder: (context, item, index) => GestureDetector(
                              onLongPress: () {
                                _showDetailsBottomSheet(context, item, currency);
                              },
                              child: ItemCardMobile(
                                item: item,
                                type: ItemCardType.sale,
                                onCountChange: (previousCount, newCount) async {
                                  final allowSalesWhenOutOfStock =
                                      allowSalesWhenStockOut && item.itemType == ItemType.goods;
                                  if (newCount > item.stockQuantity &&
                                      !allowSalesWhenOutOfStock &&
                                      item.itemType == ItemType.goods &&
                                      item.inventoryEnabled) {
                                    Alert.showSnackBar(
                                      '${item.name} is ${context.l10n.outOfStock}',
                                      type: SnackBarType.warning,
                                    );
                                    return;
                                  }

                                  if (item.itemType == ItemType.services &&
                                      item.subServices.isNotEmpty &&
                                      newCount > 0) {
                                    final selectedServices = await showDialog<List<SubService>>(
                                      context: context,
                                      useRootNavigator: false,
                                      builder: (BuildContext dialogContext) => ServiceSelectionDialog(item: item),
                                    );
                                    if (newCount > previousCount) {
                                      salesNotifier.addItem(item, selectedServices: selectedServices);
                                    } else {
                                      salesNotifier.updateItemQuantity(item.itemId!, newCount.toDouble());
                                    }
                                  } else {
                                    salesNotifier.updateItemQuantityInMobile(
                                      item.itemId!,
                                      newCount.toDouble(),
                                      item.salePrice,
                                    );
                                  }
                                },
                                count: salesState.saleItems
                                    .where((e) => e.item.itemId == item.itemId)
                                    .fold<int>(0, (previousValue, element) => previousValue + element.quantity.toInt()),
                              ),
                            ),
                          ),
                        )
                      : PagedGridView<int, Item>(
                          pagingController: salesState.pagingController!,
                          builderDelegate: PagedChildBuilderDelegate(
                            noItemsFoundIndicatorBuilder: (context) {
                              if (searchController.text.isNotEmpty) {
                                return const NoSearchItemWidget();
                              }
                              return const NoDataViewWidget();
                            },
                            itemBuilder: (context, item, index) => GestureDetector(
                              onLongPress: () {
                                _showDetailsBottomSheet(context, item, currency);
                              },
                              child: ItemCardMobile(
                                item: item,
                                type: ItemCardType.sale,
                                isGrid: true,
                                onCountChange: (previousCount, newCount) async {
                                  final allowSalesWhenOutOfStock =
                                      allowSalesWhenStockOut && item.itemType == ItemType.goods;
                                  if (newCount > item.stockQuantity &&
                                      !allowSalesWhenOutOfStock &&
                                      item.itemType == ItemType.goods &&
                                      item.inventoryEnabled) {
                                    Alert.showSnackBar(
                                      '${item.name} is ${context.l10n.outOfStock}',
                                      type: SnackBarType.warning,
                                    );
                                    return;
                                  }

                                  if (item.itemType == ItemType.services &&
                                      item.subServices.isNotEmpty &&
                                      newCount > 0) {
                                    final selectedServices = await showDialog<List<SubService>>(
                                      context: context,
                                      useRootNavigator: false,
                                      builder: (BuildContext dialogContext) => ServiceSelectionDialog(item: item),
                                    );
                                    if (newCount > previousCount) {
                                      salesNotifier.addItem(item, selectedServices: selectedServices);
                                    } else {
                                      salesNotifier.updateItemQuantity(item.itemId!, newCount.toDouble());
                                    }
                                  } else {
                                    salesNotifier.updateItemQuantityInMobile(
                                      item.itemId!,
                                      newCount.toDouble(),
                                      item.salePrice,
                                    );
                                  }
                                },
                                count: salesState.saleItems
                                    .where((e) => e.item.itemId == item.itemId)
                                    .fold<int>(0, (previousValue, element) => previousValue + element.quantity.toInt()),
                              ),
                            ),
                          ),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.8,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailsBottomSheet(BuildContext context, Item item, String currency) {
    showModalBottomSheet<void>(
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      context: AppRouter.rootContext,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // PageView for images
            SizedBox(
              height: 280,
              child: item.images.isNotEmpty
                  ? PageView.builder(
                      itemCount: item.images.length,
                      itemBuilder: (context, index) => Image.network(item.images[index].url!),
                    )
                  : NameAbbrWidget(name: item.name),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: const Color(0xfff1f1f1)),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text('$currency${item.purchasePrice}', style: AppText.largeSB.copyWith(color: AppColors.black)),
                      const SizedBox(height: 4),
                      Text(context.l10n.purchasePrice, style: AppText.smallN.copyWith(color: const Color(0xff2A3256))),
                    ],
                  ),
                  Column(
                    children: [
                      Text('$currency${item.salePrice}', style: AppText.largeSB.copyWith(color: AppColors.black)),
                      const SizedBox(height: 4),
                      Text(context.l10n.salePrice, style: AppText.smallN.copyWith(color: const Color(0xff2A3256))),
                    ],
                  ),
                  Column(
                    children: [
                      Text('$currency${item.retailPrice}', style: AppText.largeSB.copyWith(color: AppColors.black)),
                      const SizedBox(height: 4),
                      Text(context.l10n.retailPrice, style: AppText.smallN.copyWith(color: const Color(0xff2A3256))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Color(0x0000001A), blurRadius: 20, offset: Offset(-3, 4))],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(context.l10n.brand, style: AppText.mediumM.copyWith(color: AppColors.grey)),
                      Text(item.brand?.name ?? '', style: AppText.mediumB.copyWith(color: AppColors.stormyBlue)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(context.l10n.unit, style: AppText.mediumM.copyWith(color: AppColors.grey)),
                      Text(item.unit?.name ?? '', style: AppText.mediumB.copyWith(color: AppColors.stormyBlue)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(context.l10n.vatGst, style: AppText.mediumM.copyWith(color: AppColors.grey)),
                      Text(
                        item.tax != null ? '${item.tax?.name} ${item.tax?.rate}%' : '',
                        style: AppText.mediumB.copyWith(color: AppColors.stormyBlue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(context.l10n.itemCode, style: AppText.mediumM.copyWith(color: AppColors.grey)),
                      Text(item.itemCode, style: AppText.mediumB.copyWith(color: AppColors.stormyBlue)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(context.l10n.serialNumber, style: AppText.mediumM.copyWith(color: AppColors.grey)),
                      Text(item.serialNos.join(', '), style: AppText.mediumB.copyWith(color: AppColors.stormyBlue)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
