import 'dart:ui';

import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sticky_headers/sticky_headers.dart';

class SaleListScreenMobile extends ConsumerStatefulWidget {
  const SaleListScreenMobile({super.key});

  @override
  ConsumerState<SaleListScreenMobile> createState() => _SaleListScreenMobileState();
}

class _SaleListScreenMobileState extends ConsumerState<SaleListScreenMobile> {
  final DateTime today = DateTime.now();
  final DateTime tomorrow = DateTime.now().add(const Duration(days: 1));

  DateTime? startDate;
  DateTime? endDate;

  void _showOptionsBottomModal(SaleView sale) {
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
                      AppRouter.saleDetails,
                      pathParameters: {'id': sale.saleId},
                    );
                  },
                  label: Text(context.l10n.view, style: AppText.smallSB.copyWith(color: AppColors.black)),
                ),
                const SizedBox(height: 12),
                AppButton.icon(
                  icon: const Icon(Icons.print_outlined, size: 16, color: AppColors.black),
                  color: AppColors.black.withOpacity(0.05),
                  onPress: () {
                    PdfService.printSaleInvoice(sale);
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

  TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);
    final saleListNotifier = ref.watch(saleListNotifierProvider.notifier);
    final saleListState = ref.watch(saleListNotifierProvider);
    final fiscalYear = ref.watch(currentFiscalPeriodProvider).valueOrNull;

    final start = startDate ?? fiscalYear?.$1 ?? today;
    final end = endDate ?? fiscalYear?.$2 ?? tomorrow;

    return switch (ref.watch(authNotifierProvider).status) {
      AuthStatus.initial => const SizedBox.shrink(),
      AuthStatus.success => Scaffold(
          appBar: CustomAppBar(
            title: Text(context.l10n.saleList),
            actions: [
              IconButton(
                onPressed: () async {
                  final result = await showModalBottomSheet<(DateTime, DateTime)?>(
                    backgroundColor: Colors.white,
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) => DateRangeBottomSheet(
                      initialStartDate: start,
                      initialEndDate: end,
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      startDate = result.$1;
                      endDate = result.$2;
                    });
                    saleListNotifier.setFilter(startDate: startDate, endDate: endDate);
                  } else {
                    setState(() {
                      startDate = null;
                      endDate = null;
                    });
                    saleListNotifier.setFilter(startDate: fiscalYear?.$1, endDate: fiscalYear?.$2);
                  }
                },
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
                    saleListNotifier.setFilter(query: value);
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
                child: PagedListView<int, SaleView>(
                  pagingController: saleListState.pagingController!,
                  builderDelegate: PagedChildBuilderDelegate<SaleView>(
                    noItemsFoundIndicatorBuilder: (context) {
                      if (searchController.text.isNotEmpty) {
                        return const NoSearchItemWidget();
                      }
                      return const NoDataViewWidget();
                    },
                    itemBuilder: (context, item, index) {
                      final items = saleListState.pagingController!.itemList;
                      final showDateHeader = index == 0 ||
                          (items != null &&
                              index > 0 &&
                              items[index - 1].createdAt.copyWith(isUtc: true).toLocal().day !=
                                  item.createdAt.copyWith(isUtc: true).toLocal().day);
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
                                          item.createdAt.copyWith(isUtc: true).toLocal().toDateOnlyWithYear,
                                          style: AppText.largeSB.copyWith(color: AppColors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                        content: Padding(
                          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 12),
                          child: InkWell(
                            borderRadius: AppStyles.boxDecoration.borderRadius!.resolve(TextDirection.ltr),
                            splashColor: Colors.transparent,
                            onTap: () {
                              AppRouter.pushNamed(
                                AppRouter.saleDetails,
                                pathParameters: {'id': item.saleId},
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
                                          child: Text(item.saleInvoice,
                                              style: AppText.mediumSB.copyWith(color: AppColors.darkBlue),),
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
                                            child: Text(context.l10n.due,
                                                style: AppText.xSmallSB.copyWith(color: AppColors.red),),
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
                                            item.customer?.name ?? context.l10n.walkInCustomer,
                                            style: AppText.mediumM.copyWith(color: AppColors.black),
                                          ),
                                          Text(
                                            '$currency${item.totalAmount}',
                                            style: AppText.largeB.copyWith(color: AppColors.greyish),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        item.createdAt.toLocal().toTime12WithDayFormat,
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
