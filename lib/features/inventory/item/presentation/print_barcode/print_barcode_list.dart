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

class PrintBarcodeList extends ConsumerWidget {
  const PrintBarcodeList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final printBarcodeNotifier = ref.watch(printBarcodeNotifierProvider.notifier);
    final printBarcodeState = ref.watch(printBarcodeNotifierProvider);
    final currency = ref.watch(currencyProvider);
    return switch (ref.watch(authNotifierProvider).status) {
      AuthStatus.initial => const SizedBox.shrink(),
      AuthStatus.success => Scaffold(
          appBar: CustomAppBar(
            title: Text(context.l10n.printBarcode),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(context.l10n.selectItemToPrintBarcode,
                    style: AppText.mediumM.copyWith(color: AppColors.greyish),),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: AppTextForm<String>(
                  name: 'search',
                  hintText: context.l10n.search,
                  onChanged: (value) {
                    printBarcodeNotifier.setFilter(query: value);
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
                child: PagedListView<int, Item>(
                  pagingController: printBarcodeState.pagingController!,
                  builderDelegate: PagedChildBuilderDelegate<Item>(
                    noItemsFoundIndicatorBuilder: (context) {
                      return const NoSearchItemWidget();
                    },
                    itemBuilder: (context, item, index) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 12),
                        child: InkWell(
                          onTap: () {
                            context.pushNamed(AppRouter.printBarcode, queryParameters: {'id': item.itemId});
                          },
                          borderRadius: AppStyles.boxDecoration.borderRadius!.resolve(TextDirection.ltr),
                          splashColor: Colors.transparent,
                          child: Ink(
                            decoration: AppStyles.boxDecoration,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                                        imageUrl: item.images.firstWhereOrNull((element) => element.isThumbnail)?.url ??
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
                                              child: Text(item.itemCode,
                                                  style: AppText.mediumN.copyWith(color: AppColors.brandViolet),),
                                            ),
                                            Text(
                                              currency + item.salePrice.toStringAsFixed(2),
                                              style: AppText.smallB.copyWith(color: AppColors.greyish2),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(item.name, style: AppText.mediumM.copyWith(color: AppColors.black)),
                                      ],
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
      AuthStatus.loading => const Center(child: CircularProgressIndicator()),
      AuthStatus.error => const Center(child: Text('Error')),
    };
  }
}
