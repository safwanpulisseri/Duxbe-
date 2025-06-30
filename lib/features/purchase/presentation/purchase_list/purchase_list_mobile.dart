import 'dart:ui';

import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/purchase/purchase.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sticky_headers/sticky_headers.dart';

class PurchaseListScreenMobile extends ConsumerStatefulWidget {
  const PurchaseListScreenMobile({super.key});

  @override
  ConsumerState<PurchaseListScreenMobile> createState() => _PurchaseListScreenMobileState();
}

class _PurchaseListScreenMobileState extends ConsumerState<PurchaseListScreenMobile> {
  TextEditingController searchController = TextEditingController();

  void _showOptionsBottomModal(PurchaseView purchase) {
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
                    AppRouter.pushNamed(
                      AppRouter.purchaseDetails,
                      pathParameters: {'id': purchase.purchaseId},
                    );
                  },
                  label: Text(context.l10n.view, style: AppText.smallSB.copyWith(color: AppColors.black)),
                ),
                const SizedBox(height: 12),
                AppButton.icon(
                  icon: const Icon(Icons.print_outlined, size: 16, color: AppColors.black),
                  color: AppColors.black.withOpacity(0.05),
                  onPress: () {
                    PdfService.printPurchaseInvoice(purchase);
                  },
                  label: Text(context.l10n.printInvoice, style: AppText.smallSB.copyWith(color: AppColors.black)),
                ),
                const SizedBox(height: 12),
                AppButton.icon(
                  icon: const Icon(Icons.settings_backup_restore, size: 16, color: AppColors.black),
                  color: AppColors.black.withOpacity(0.05),
                  onPress: () {},
                  label: Text(context.l10n.saleReturn, style: AppText.smallSB.copyWith(color: AppColors.black)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);
    final purchaseListNotifier = ref.watch(purchaseListNotifierProvider.notifier);
    final purchaseListState = ref.watch(purchaseListNotifierProvider);
    return switch (ref.watch(authNotifierProvider).status) {
      AuthStatus.initial => const SizedBox.shrink(),
      AuthStatus.success => Scaffold(
          appBar: CustomAppBar(
            title: Text(context.l10n.purchaseList),
            actions: [
              IconButton(
                onPressed: () {},
                icon: Assets.icons.dateFilter.svg(),
              ),
            ],
          ),
          body: Column(
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: AppTextForm<String>(
                  controller: searchController,
                  name: 'search',
                  hintText: context.l10n.enterNameInvoiceNumber,
                  onChanged: (value) {
                    purchaseListNotifier.setFilter(query: value);
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
              Expanded(
                child: PagedListView<int, PurchaseView>(
                  pagingController: ref.watch(purchaseListNotifierProvider).pagingController!,
                  builderDelegate: PagedChildBuilderDelegate<PurchaseView>(
                    noItemsFoundIndicatorBuilder: (context) {
                      if (searchController.text.isNotEmpty) {
                        return const NoSearchItemWidget();
                      }
                      return const NoDataViewWidget();
                    },
                    itemBuilder: (context, item, index) {
                      final items = purchaseListState.pagingController!.itemList;
                      final showDateHeader = index == 0 ||
                          (items != null && index > 0 && items[index - 1].createdAt.day != item.createdAt.day);
                      return StickyHeader(
                        header: showDateHeader
                            ? ClipRRect(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.1),
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.white.withOpacity(0.2),
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 10,
                                          width: 14,
                                          decoration: const BoxDecoration(
                                            color: AppColors.brandViolet,
                                            borderRadius: BorderRadius.horizontal(right: Radius.circular(10)),
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        Text(
                                          item.createdAt.toDateOnlyWithYear,
                                          style: AppText.largeSB.copyWith(color: AppColors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                        content: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          child: InkWell(
                            borderRadius: AppStyles.boxDecoration.borderRadius!.resolve(TextDirection.ltr),
                            splashColor: Colors.transparent,
                            onTap: () {
                              AppRouter.pushNamed(
                                AppRouter.purchaseDetails,
                                pathParameters: {'id': item.purchaseId},
                              );
                            },
                            onLongPress: () {
                              _showOptionsBottomModal(item);
                            },
                            child: Ink(
                              decoration: AppStyles.boxDecoration,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                                          decoration: const BoxDecoration(
                                            color: AppColors.lightPurple,
                                            borderRadius: BorderRadius.horizontal(
                                              right: Radius.circular(12),
                                            ),
                                          ),
                                          child: Text(
                                            item.invoiceNo,
                                            style: AppText.mediumSB.copyWith(color: AppColors.darkBlue),
                                          ),
                                        ),
                                        if (item.dueAmount > 0)
                                          Container(
                                            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                                            decoration: BoxDecoration(
                                              color: AppColors.red.withOpacity(.1),
                                              borderRadius: const BorderRadius.horizontal(
                                                left: Radius.circular(2),
                                              ),
                                            ),
                                            child: Text(
                                              context.l10n.due,
                                              style: AppText.xSmallSB.copyWith(color: AppColors.red),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            item.supplier.name,
                                            style: AppText.mediumM.copyWith(color: AppColors.black),
                                          ),
                                          Text(
                                            '$currency${item.totalAmount}',
                                            style: AppText.largeB.copyWith(color: AppColors.primaryColor),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        item.createdAt.toTime12WithDayFormat,
                                        style: AppText.smallSB.copyWith(color: AppColors.greyish2),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      AuthStatus.loading => const Center(child: CircularProgressIndicator()),
      AuthStatus.error => const Center(child: Text('Error')),
    };
  }
}
