import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/features/reports/reports.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class StockReportScreenMobile extends ConsumerStatefulWidget {
  const StockReportScreenMobile({super.key});

  @override
  ConsumerState<StockReportScreenMobile> createState() => _StockReportScreenMobileState();
}

class _StockReportScreenMobileState extends ConsumerState<StockReportScreenMobile> {
  final _debouncer = Debouncer(milliseconds: 500);

  Widget _buildRow(String title, Widget value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppText.smallN.copyWith(color: AppColors.stormyBlue),
          ),
          const SizedBox(width: 12),
          value,
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: AppColors.lightPurple,
      height: 1,
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
    final stockReportState = ref.watch(stockReportNotifierProvider);
    final stockReportNotifier = ref.watch(stockReportNotifierProvider.notifier);
    final currency = ref.watch(currencyProvider);
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        title: Text(context.l10n.stockReport),
      ),
      body: SafeArea(
        child: DefaultTabController(
          length: 4,
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
                    _debouncer.run(() {
                      stockReportNotifier.setFilter(query: value ?? '');
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
              ref.watch(totalStockValueProvider).when(
                    data: (data) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ReportCard(
                            color: AppColors.reportGreenLight,
                            textColor: AppColors.reportGreen,
                            title: context.l10n.totalStockValue,
                            value: currency + data.toStringAsFixed(2),
                          ),
                        ],
                      ),
                    ),
                    error: (error, stack) => Text(error.toString()),
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
              ColoredBox(
                color: AppColors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: TabBar(
                    isScrollable: true,
                    indicator: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelColor: AppColors.white,
                    unselectedLabelColor: AppColors.primaryColor,
                    tabs: const [
                      Tab(text: 'All'),
                      Tab(text: 'In Stock'),
                      Tab(text: 'Low Stock'),
                      Tab(text: 'Out of Stock'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    stockReportState.pagingController!,
                    stockReportState.inStockPagingController!,
                    stockReportState.lowStockPagingController!,
                    stockReportState.outOfStockPagingController!,
                  ]
                      .map(
                        (e) => Builder(
                          builder: (context) {
                            return RefreshIndicator(
                              onRefresh: () async {
                                // Trigger a refresh of the data
                                stockReportNotifier.setFilter(query: stockReportState.query);
                              },
                              child: PagedListView<int, Item>.separated(
                                separatorBuilder: (context, index) => const SizedBox(height: 12),
                                pagingController: e,
                                builderDelegate: PagedChildBuilderDelegate<Item>(
                                  noItemsFoundIndicatorBuilder: (context) {
                                    if (searchController.text.isNotEmpty) {
                                      return const NoSearchItemWidget();
                                    }
                                    return const NoDataViewWidget();
                                  },
                                  itemBuilder: (context, item, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 24, right: 24),
                                      child: InkWell(
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
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                Row(
                                                  children: [
                                                    if (item.images.isNotEmpty)
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          border: Border.all(
                                                            color: AppColors.textfieldOutline.withOpacity(.5),
                                                          ),
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
                                                      child: Text(
                                                        item.name,
                                                        maxLines: 3,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: AppText.mediumB.copyWith(color: AppColors.black),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 12),
                                                _buildRow(
                                                  '${context.l10n.category}:',
                                                  Text(
                                                    item.itemCategory?.name ?? '-',
                                                    style: AppText.smallSB.copyWith(color: AppColors.brandViolet),
                                                  ),
                                                ),
                                                _buildDivider(),
                                                _buildRow(
                                                  '${context.l10n.quantity}:',
                                                  Text(
                                                    item.stockQuantity.toString(),
                                                    style: AppText.smallSB.copyWith(color: AppColors.black),
                                                  ),
                                                ),
                                                _buildDivider(),
                                                _buildRow(
                                                  '${context.l10n.purchasePrice}:',
                                                  Text(
                                                    item.purchasePrice.toStringAsFixed(2),
                                                    style: AppText.smallSB.copyWith(color: AppColors.black),
                                                  ),
                                                ),
                                                _buildDivider(),
                                                _buildRow(
                                                  '${context.l10n.totalStockValue}:',
                                                  Text(
                                                    item.stockValue.toStringAsFixed(2),
                                                    style: AppText.smallSB.copyWith(color: AppColors.black),
                                                  ),
                                                ),
                                                _buildDivider(),
                                                _buildRow(
                                                  '',
                                                  Text(
                                                    item.stockStatus.displayCase,
                                                    style: AppText.smallSB.copyWith(
                                                      color: switch (item.stockStatus) {
                                                        'In Stock' => AppColors.green,
                                                        'Out of Stock' => AppColors.grey,
                                                        'Low Stock' => AppColors.red,
                                                        _ => AppColors.black,
                                                      },
                                                    ),
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
                            );
                          },
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
