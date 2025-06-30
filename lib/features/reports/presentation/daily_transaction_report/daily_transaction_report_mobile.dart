import 'package:duxbe/features/reports/reports.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grouped_list/sliver_grouped_list.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class DailyTransactionReportScreenMobile extends ConsumerStatefulWidget {
  const DailyTransactionReportScreenMobile({super.key});

  @override
  ConsumerState<DailyTransactionReportScreenMobile> createState() => _DailyTransactionReportScreenMobileState();
}

class _DailyTransactionReportScreenMobileState extends ConsumerState<DailyTransactionReportScreenMobile> {
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

  Widget _buildTransactionItem(DailyTransaction item) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 12),
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
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      _buildRow(
                        '${context.l10n.name}:',
                        Text(
                          item.name,
                          style: AppText.smallSB.copyWith(color: AppColors.black),
                        ),
                      ),
                      _buildDivider(),
                      _buildRow(
                        '${context.l10n.type}:',
                        Text(
                          item.type,
                          style: AppText.smallSB.copyWith(color: AppColors.black),
                        ),
                      ),
                      _buildDivider(),
                      _buildRow(
                        '${context.l10n.totalAmount}:',
                        Text(
                          item.transactionTotal.toStringAsFixed(2),
                          style: AppText.smallSB.copyWith(color: AppColors.black),
                        ),
                      ),
                      _buildDivider(),
                      _buildRow(
                        '${context.l10n.balance}:',
                        Text(
                          item.balance.toStringAsFixed(2),
                          style: AppText.smallSB.copyWith(color: AppColors.black),
                        ),
                      ),
                      if (item.paymentIn != null) ...[
                        _buildDivider(),
                        _buildRow(
                          'Pay In' ':',
                          Text.rich(
                            TextSpan(
                              children: [
                                const WidgetSpan(
                                  child: Icon(
                                    CupertinoIcons.arrow_down_right,
                                    color: AppColors.green,
                                    size: 16,
                                  ),
                                ),
                                TextSpan(
                                  text: ' ${item.paymentIn?.toStringAsFixed(2) ?? ''}',
                                  style: AppText.smallSB.copyWith(color: AppColors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (item.paymentOut != null) ...[
                        _buildDivider(),
                        _buildRow(
                          'Pay Out' ':',
                          Text.rich(
                            TextSpan(
                              children: [
                                const WidgetSpan(
                                  child: Icon(
                                    CupertinoIcons.arrow_up_right,
                                    color: AppColors.red,
                                    size: 16,
                                  ),
                                ),
                                TextSpan(
                                  text: ' ${item.paymentOut?.toStringAsFixed(2) ?? ''}',
                                  style: AppText.smallSB.copyWith(color: AppColors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateHeader(DateTime date) {
    return Container(
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
            date.toDateOnlyWithYear,
            style: AppText.largeSB.copyWith(color: AppColors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildTabView(PagingController<int, DailyTransaction> controller) {
    return PagedGroupedListView<int, DailyTransaction, DateTime>(
      pagingController: controller,
      groupBy: (item) => DateTime(item.date.year, item.date.month, item.date.day),
      groupComparator: (date1, date2) => date2.compareTo(date1),
      builderDelegate: PagedChildBuilderDelegate<DailyTransaction>(
        noItemsFoundIndicatorBuilder: (context) {
          if (searchController.text.isNotEmpty) {
            return const NoSearchItemWidget();
          }
          return const NoDataViewWidget();
        },
        itemBuilder: (context, item, index) => _buildTransactionItem(item),
      ),
      groupSeparatorBuilder: _buildDateHeader,
      order: GroupedListOrder.DESC,
      // floatingHeader: true,
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
    final dailyTransactionState = ref.watch(dailyTransactionNotifierProvider);
    final dailyTransactionNotifier = ref.watch(dailyTransactionNotifierProvider.notifier);
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        title: Text(context.l10n.dailyTransaction),
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
                      dailyTransactionNotifier.setFilter(query: value ?? '');
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
                      Tab(text: context.l10n.payIn),
                      Tab(text: context.l10n.payOut),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildTabView(dailyTransactionState.pagingController!),
                    _buildTabView(dailyTransactionState.payInPagingController!),
                    _buildTabView(dailyTransactionState.payOutPagingController!),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
