import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class StockAdjustmentsScreenMobile extends ConsumerStatefulWidget {
  const StockAdjustmentsScreenMobile({super.key});

  @override
  ConsumerState<StockAdjustmentsScreenMobile> createState() => _StockAdjustmentsScreenMobileState();
}

class _StockAdjustmentsScreenMobileState extends ConsumerState<StockAdjustmentsScreenMobile> {
  void _showOptionsBottomModal(StockAdjustments adjustment) {
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
                    AppRouter.pushNamed(AppRouter.stockAdjusmentView, pathParameters: {'id': adjustment.adjustmentId!});
                  },
                  label: Text(context.l10n.view, style: AppText.smallSB.copyWith(color: AppColors.black)),
                ),
                const SizedBox(height: 12),
                AppButton.icon(
                  icon: Assets.icons.print.svg(height: 16, width: 16),
                  color: AppColors.black.withOpacity(0.05),
                  onPress: () {
                    PdfService.printStockAdjustment(adjustment);
                  },
                  label: Text(context.l10n.print, style: AppText.smallSB.copyWith(color: AppColors.black)),
                ),
                const SizedBox(height: 12),
                AppButton.icon(
                  icon: const Icon(Icons.delete_outlined, size: 16, color: AppColors.black),
                  color: AppColors.black.withOpacity(0.05),
                  onPress: () {
                    showDialog<void>(
                      context: AppRouter.rootContext,
                      builder: (context) => ConfirmationDialog(
                        title: AppRouter.l10n.deleteStockAdjustment,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppRouter.l10n.areYouSureYouWantToDeleteThisStockAdjustment,
                            style: AppText.mediumN.copyWith(color: AppColors.primaryColor),
                          ),
                        ],
                        onPositive: (ref) {
                          ref
                              .read(stockAdjustmentsNotifierProvider.notifier)
                              .deleteStockAdjustment(adjustment.adjustmentId!);
                        },
                      ),
                    );
                  },
                  label: Text(context.l10n.delete, style: AppText.smallSB.copyWith(color: AppColors.black)),
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
    final stockAdjustmentsNotifier = ref.watch(stockAdjustmentsNotifierProvider.notifier);
    final stockAdjustmentsState = ref.watch(stockAdjustmentsNotifierProvider);
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.viewPaddingOf(context).bottom == 0 ? 24 : MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: AppButton(
          onPress: () {
            AppRouter.pushNamed(AppRouter.multiStockAdjust);
          },
          label: Text(context.l10n.addAdjustment, style: AppText.largeB),
        ),
      ),
      appBar: CustomAppBar(
        title: Text(context.l10n.stockAdjustment),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AppTextForm<String>(
                controller: searchController,
                name: 'search',
                hintText: context.l10n.search,
                onChanged: (value) {
                  stockAdjustmentsNotifier.setFilter(query: value ?? '');
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: PagedListView<int, StockAdjustments>.separated(
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                pagingController: stockAdjustmentsState.pagingController!,
                builderDelegate: PagedChildBuilderDelegate<StockAdjustments>(
                  noItemsFoundIndicatorBuilder: (context) {
                    if (searchController.text.isNotEmpty) {
                      return const NoSearchItemWidget();
                    }
                    return const NoDataViewWidget();
                  },
                  itemBuilder: (context, item, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: InkWell(
                        borderRadius: AppStyles.boxDecoration.borderRadius!.resolve(TextDirection.ltr),
                        splashColor: Colors.transparent,
                        onTap: () {},
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
                                        item.reference,
                                        style: AppText.mediumSB.copyWith(color: AppColors.darkBlue),
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
                                        context.l10n.noOfItemsAdjusted,
                                        style: AppText.mediumM.copyWith(color: AppColors.black),
                                      ),
                                      Text(
                                        item.adjustedItems.length.toString(),
                                        style: AppText.smallSB.copyWith(color: AppColors.greyish2),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    item.performedAt.toTime12WithDayFormat,
                                    style: AppText.smallSB.copyWith(color: AppColors.greyish2),
                                  ),
                                ),
                              ],
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
    );
  }
}
