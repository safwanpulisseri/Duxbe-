import 'dart:ui';

import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/purchase/purchase.dart';
import 'package:duxbe/features/reports/reports.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sticky_headers/sticky_headers.dart';

class PurchaseReportScreenMobile extends ConsumerStatefulWidget {
  const PurchaseReportScreenMobile({super.key});

  @override
  ConsumerState<PurchaseReportScreenMobile> createState() => _PurchaseReportScreenMobileState();
}

class _PurchaseReportScreenMobileState extends ConsumerState<PurchaseReportScreenMobile> {
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
    final purchaseReportState = ref.watch(purchaseReportNotifierProvider);
    final purchaseReportNotifier = ref.watch(purchaseReportNotifierProvider.notifier);
    final currency = ref.watch(currencyProvider);
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        title: Text(context.l10n.purchaseReport),
      ),
      body: SafeArea(
        child: DefaultTabController(
          length: 3,
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
                      purchaseReportNotifier.setFilter(query: value ?? '');
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
              ref
                  .watch(
                    purchaseSummaryProvider(
                      purchaseReportState.fromDate,
                      purchaseReportState.toDate,
                    ),
                  )
                  .when(
                    data: (data) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ReportCard(
                            color: AppColors.reportGreenLight,
                            textColor: AppColors.reportGreen,
                            title: context.l10n.totalPurchases,
                            value: data.totalPurchaseCount.toString(),
                          ),
                          const SizedBox(height: 8),
                          ReportCard(
                            color: AppColors.reportBrownLight,
                            textColor: AppColors.reportBrown,
                            title: context.l10n.unpaid,
                            value: currency + data.totalDue.toString(),
                          ),
                          const SizedBox(height: 8),
                          ReportCard(
                            color: AppColors.reportPurpleLight,
                            textColor: AppColors.reportPurple,
                            title: context.l10n.totalAmount,
                            value: currency + data.totalPurchaseAmount.toString(),
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
                    indicator: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelColor: AppColors.white,
                    unselectedLabelColor: AppColors.primaryColor,
                    tabs: [
                      Tab(text: context.l10n.all),
                      Tab(text: context.l10n.paid),
                      Tab(text: context.l10n.due),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    purchaseReportState.pagingController!,
                    purchaseReportState.paidPagingController!,
                    purchaseReportState.duePagingController!,
                  ]
                      .map(
                        (e) => Builder(
                          builder: (context) {
                            final items = e.itemList;
                            return RefreshIndicator(
                              onRefresh: () async {
                                // Trigger a refresh of the data
                                purchaseReportNotifier.setFilter(query: purchaseReportState.query);
                              },
                              child: PagedListView<int, PurchaseView>.separated(
                                separatorBuilder: (context, index) => const SizedBox(height: 12),
                                pagingController: e,
                                builderDelegate: PagedChildBuilderDelegate<PurchaseView>(
                                  noItemsFoundIndicatorBuilder: (context) {
                                    if (searchController.text.isNotEmpty) {
                                      return const NoSearchItemWidget();
                                    }
                                    return const NoDataViewWidget();
                                  },
                                  itemBuilder: (context, item, index) {
                                    final showDateHeader = index == 0 ||
                                        (items != null &&
                                            index > 0 &&
                                            items[index - 1].createdAt.day != item.createdAt.day);
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
                                                          borderRadius:
                                                              BorderRadius.horizontal(right: Radius.circular(10)),
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
                                        padding: const EdgeInsets.only(left: 24, right: 24),
                                        child: InkWell(
                                          borderRadius:
                                              AppStyles.boxDecoration.borderRadius!.resolve(TextDirection.ltr),
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
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                                    child: Column(
                                                      children: [
                                                        _buildRow(
                                                          '${context.l10n.invoiceNo}:',
                                                          Text(
                                                            item.purchaseInvoice,
                                                            style:
                                                                AppText.smallSB.copyWith(color: AppColors.brandViolet),
                                                          ),
                                                        ),
                                                        _buildDivider(),
                                                        _buildRow(
                                                          '${context.l10n.name}:',
                                                          Text(
                                                            item.supplier.name,
                                                            style: AppText.smallSB.copyWith(color: AppColors.black),
                                                          ),
                                                        ),
                                                        _buildDivider(),
                                                        _buildRow(
                                                          '${context.l10n.amount}:',
                                                          Text(
                                                            item.totalAmount.toStringAsFixed(2),
                                                            style: AppText.smallSB.copyWith(color: AppColors.black),
                                                          ),
                                                        ),
                                                        _buildDivider(),
                                                        _buildRow(
                                                          '${context.l10n.due}:',
                                                          Text(
                                                            item.dueAmount.toStringAsFixed(2),
                                                            style: AppText.smallSB.copyWith(color: AppColors.black),
                                                          ),
                                                        ),
                                                        _buildDivider(),
                                                        _buildRow(
                                                          '${context.l10n.status}:',
                                                          Text(
                                                            item.transaction.status.name.displayCase,
                                                            style: AppText.smallSB.copyWith(
                                                              color: switch (item.transaction.status) {
                                                                TransactionStatus.PAID => AppColors.green,
                                                                TransactionStatus.CANCELLED => AppColors.red,
                                                                TransactionStatus.PENDING => AppColors.orange,
                                                                TransactionStatus.PARTIALLY_PAID => AppColors.warning,
                                                                _ => AppColors.black,
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                        _buildDivider(),
                                                        _buildRow(
                                                          '${context.l10n.paymentType}:',
                                                          Text(
                                                            item.payments
                                                                .map((e) => e.paymentMethod.name.displayCase)
                                                                .toSet()
                                                                .join(', '),
                                                            style: AppText.smallSB.copyWith(color: AppColors.black),
                                                          ),
                                                        ),
                                                      ],
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
