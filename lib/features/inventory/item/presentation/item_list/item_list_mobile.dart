import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class ItemListScreenMobile extends ConsumerStatefulWidget {
  const ItemListScreenMobile({super.key});

  @override
  ConsumerState<ItemListScreenMobile> createState() => _ItemListScreenMobileState();
}

class _ItemListScreenMobileState extends ConsumerState<ItemListScreenMobile> {
  final _debouncer = Debouncer(milliseconds: 500);
  void _showOptionsBottomModal(Item item) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppButton.icon(
                  icon: const Icon(Icons.visibility_outlined, size: 16, color: AppColors.black),
                  color: AppColors.black.withOpacity(0.05),
                  onPress: () {
                    context.pop();
                    AppRouter.pushNamed(
                      AppRouter.itemView,
                      pathParameters: {'id': item.itemId!},
                    );
                  },
                  label: Text(context.l10n.view, style: AppText.smallSB.copyWith(color: AppColors.black)),
                ),
                const SizedBox(height: 12),
                AppButton.icon(
                  icon: Assets.icons.edit.svg(),
                  color: AppColors.black.withOpacity(0.05),
                  onPress: () {
                    context.pop();
                    AppRouter.pushNamed(
                      AppRouter.itemDetails,
                      pathParameters: {'id': item.itemId!},
                    );
                  },
                  label: Text(context.l10n.edit, style: AppText.smallSB.copyWith(color: AppColors.black)),
                ),
                const SizedBox(height: 12),
                AppButton.icon(
                  icon: Assets.icons.delete.svg(),
                  color: AppColors.red.withOpacity(0.05),
                  onPress: () {
                    context.pop();
                    showDialog<void>(
                      context: AppRouter.rootContext,
                      builder: (context) {
                        return ConfirmationDialog(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          title: AppRouter.l10n.deleteItem,
                          children: [
                            Text(
                              AppRouter.l10n.deleteThisItem,
                              style: AppText.mediumN.copyWith(color: AppColors.primaryColor),
                            ),
                          ],
                          onPositive: (ref) {
                            ref.read(itemNotifierProvider.notifier).deleteItem(item).then(AppRouter.pop);
                          },
                        );
                      },
                    );
                  },
                  label: Text(context.l10n.delete, style: AppText.smallSB.copyWith(color: AppColors.red)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);
    final itemListNotifier = ref.watch(itemNotifierProvider.notifier);
    final itemListState = ref.watch(itemNotifierProvider);
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(context.l10n.itemList),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.viewPaddingOf(context).bottom == 0 ? 24 : MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(
              label: Text(context.l10n.addItem),
              onPress: () {
                context.pushNamed(AppRouter.createItem);
              },
            ),
            const SizedBox(height: 12),
            AppButton(
              label: Text(context.l10n.itemImport),
              style: ButtonStyles.cancel,
              onPress: () {
                context.pushNamed(AppRouter.importItem);
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: AppTextForm<String>(
                  controller: searchController,
                  name: 'search',
                  hintText: context.l10n.enterNameInvoiceNumber,
                  onChanged: (value) {
                    _debouncer.run(() {
                      itemListNotifier.setFilter(query: value);
                    });
                  },
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(6),
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(9.25),
                    ),
                    child: const Icon(CupertinoIcons.search, color: AppColors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ColoredBox(
                color: AppColors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: TabBar(
                    indicator: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelColor: AppColors.white,
                    unselectedLabelColor: AppColors.primaryColor,
                    tabs: [
                      Tab(text: context.l10n.all),
                      Tab(text: context.l10n.goods),
                      Tab(text: context.l10n.services),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    itemListState.pagingController!,
                    itemListState.goodsPagingController!,
                    itemListState.servicesPagingController!,
                  ]
                      .map(
                        (e) => RefreshIndicator(
                          onRefresh: () async {
                            // Trigger a refresh of the data
                            itemListNotifier.setFilter(query: itemListState.query);
                          },
                          child: PagedListView<int, Item>.separated(
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            pagingController: e,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                            builderDelegate: PagedChildBuilderDelegate<Item>(
                              noItemsFoundIndicatorBuilder: (context) {
                                if (searchController.text.isNotEmpty) {
                                  return const NoSearchItemWidget();
                                }
                                return const NoDataViewWidget();
                              },
                              itemBuilder: (context, item, index) {
                                return InkWell(
                                  onTap: () {
                                    AppRouter.pushNamed(
                                      AppRouter.itemView,
                                      pathParameters: {'id': item.itemId!},
                                    );
                                  },
                                  onLongPress: () {
                                    _showOptionsBottomModal(item);
                                  },
                                  borderRadius: AppStyles.boxDecoration.borderRadius!.resolve(TextDirection.ltr),
                                  splashColor: Colors.transparent,
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: AppColors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.black.withOpacity(0.1),
                                          blurRadius: 28,
                                          offset: const Offset(5, 12),
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                      child: Row(
                                        children: [
                                          if (item.images.isNotEmpty)
                                            Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(color: AppColors.textfieldOutline.withOpacity(.5)),
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                              padding: const EdgeInsets.all(2),
                                              clipBehavior: Clip.hardEdge,
                                              child: CachedNetworkImage(
                                                height: 48,
                                                width: 48,
                                                imageUrl: item.images
                                                        .firstWhereOrNull((element) => element.isThumbnail)
                                                        ?.url ??
                                                    item.images.first.url!,
                                                fit: BoxFit.contain,
                                              ),
                                            )
                                          else
                                            NameAbbrWidget(name: item.name, size: 52, textSize: 16),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: AppColors.lightPurple,
                                                        borderRadius: BorderRadius.circular(5),
                                                      ),
                                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                                      child: Text(
                                                        item.itemCode,
                                                        style: AppText.mediumSB.copyWith(color: AppColors.darkBlue),
                                                      ),
                                                    ),
                                                    if ((item.itemType.name == ItemType.goods.name)&&item.inventoryEnabled)
                                                      Text(
                                                        '${context.l10n.stock}: ${item.stockQuantity}',
                                                        style: AppText.smallN.copyWith(color: AppColors.greyish2),
                                                      ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        item.name,
                                                        style: AppText.mediumM.copyWith(color: AppColors.black),
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      currency + item.salePrice.toStringAsFixed(2),
                                                      style: AppText.mediumSB.copyWith(color: AppColors.black),
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
                                );
                              },
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
