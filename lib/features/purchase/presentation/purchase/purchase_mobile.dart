import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/features/purchase/purchase.dart';
import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PurchaseScreenMobile extends ConsumerStatefulWidget {
  const PurchaseScreenMobile({super.key});

  @override
  ConsumerState<PurchaseScreenMobile> createState() => _PurchaseScreenMobileState();
}

class _PurchaseScreenMobileState extends ConsumerState<PurchaseScreenMobile> {
  final _debouncer = Debouncer(milliseconds: 500);

  @override
  void initState() {
    super.initState();
  }

  TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    _debouncer.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);
    final purchaseNotifier = ref.watch(purchaseNotifierProvider.notifier);
    final purchaseState = ref.watch(purchaseNotifierProvider);
    final showSquare = ref.watch(showSquareProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(context.l10n.purchase),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.viewPaddingOf(context).bottom == 0 ? 24 : MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: Builder(
          builder: (context) {
            final total = purchaseState.purchaseItems.fold<double>(
              0,
              (previousValue, element) => previousValue + element.quantity * element.unitPrice,
            );
            return AppButton(
              onPress: () {
                if (purchaseState.purchaseItems.isEmpty) {
                  Alert.showSnackBar(context.l10n.pleaseSelectAtLeastOneItem);
                  return;
                }
                //  Navigate to the next screen like payment
                // For example:
                context.pushNamed(AppRouter.purchasePayment);
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
                              text: '${purchaseState.purchaseItems.length} ',
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
                  purchaseNotifier.setFilter(query: v);
                });
              },
              prefixIcon: const Icon(Icons.qr_code_2_outlined),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  ref.read(showSquareProvider.notifier).state = !showSquare;
                },
                icon: showSquare ? Assets.icons.viewBySquare.svg() : Assets.icons.viewByList.svg(),
                label: Text(
                  context.l10n.viewBy,
                  style: AppText.smallN.copyWith(color: AppColors.orange),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: showSquare
                  ? PagedListView<int, Item>.separated(
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      pagingController: purchaseState.pagingController!,
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
                            type: ItemCardType.purchase,
                            onCountChange: (previousCount, newCount) async {
                              purchaseNotifier.updateItemQuantityInMobile(
                                item.itemId!,
                                newCount.toDouble(),
                                item.purchasePrice,
                              );
                            },
                            count: purchaseState.purchaseItems
                                .where((e) => e.item.itemId == item.itemId)
                                .fold<int>(0, (previousValue, element) => previousValue + element.quantity.toInt()),
                          ),
                        ),
                      ),
                    )
                  : PagedGridView<int, Item>(
                      pagingController: purchaseState.pagingController!,
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
                            type: ItemCardType.purchase,
                            isGrid: true,
                            onCountChange: (previousCount, newCount) async {
                              purchaseNotifier.updateItemQuantityInMobile(
                                item.itemId!,
                                newCount.toDouble(),
                                item.purchasePrice,
                              );
                            },
                            count: purchaseState.purchaseItems
                                .where((e) => e.item.itemId == item.itemId)
                                .fold<int>(0, (previousValue, element) => previousValue + element.quantity.toInt()),
                          ),
                        ),
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.2,
                      ),
                    ),
            ),
          ],
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
