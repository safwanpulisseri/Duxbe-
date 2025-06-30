import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/reports/reports.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class EmployeeSalesScreenMobile extends ConsumerStatefulWidget {
  const EmployeeSalesScreenMobile({super.key});

  @override
  ConsumerState<EmployeeSalesScreenMobile> createState() => _EmployeeSalesScreenMobileState();
}

class _EmployeeSalesScreenMobileState extends ConsumerState<EmployeeSalesScreenMobile> {
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
    final employeeSalesState = ref.watch(employeeSalesNotifierProvider);
    final employeeSalesNotifier = ref.watch(employeeSalesNotifierProvider.notifier);
    final currency = ref.watch(currencyProvider); // Unchanged, outside conflict
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        title: Text(context.l10n.employeeSales),
      ),
      body: SafeArea(
        // Kept from feature/bugs-20-5-25
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Padding(
              // Search bar section, using feature/bugs-20-5-25 structure
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AppTextForm<String>(
                controller: searchController,
                name: 'search',
                hintText: context.l10n.search,
                onChanged: (value) {
                  _debouncer.run(() {
                    employeeSalesNotifier.setFilter(query: value ?? '');
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
            // Summary cards section from feature/bugs-20-5-25
            ref
                .watch(
                  employeeSalesSummaryProvider(
                    employeeSalesState.query,
                    employeeSalesState.pageSize,
                    employeeSalesState.pageNumber,
                    employeeSalesState.fromDate,
                    employeeSalesState.toDate,
                  ),
                )
                .when(
                  data: (data) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 12, left: 24, right: 24),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ReportCard(
                                  textColor: const Color.fromRGBO(31, 107, 93, 1),
                                  color: const Color.fromRGBO(180, 228, 212, 1),
                                  title: context.l10n.totalItemsSold,
                                  value: data.totalItemsSold.toString(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ReportCard(
                                  textColor: const Color.fromRGBO(156, 68, 68, 1),
                                  color: const Color.fromRGBO(255, 229, 217, 1),
                                  title: context.l10n.totalRevenueGenerated,
                                  value: data.totalRevenueGenerated.toString(),
                                ),
                              ),
                            ],
                          ),
                          // const SizedBox(width: 8),
                          // const Spacer(),
                        ],
                      ),
                    );
                  },
                  error: (error, stack) => Text(error.toString()),
                  loading: () => const CircularProgressIndicator(),
                ),
            const SizedBox(height: 12), // Kept from feature/bugs-20-5-25
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  // Trigger a refresh of the data
                  employeeSalesNotifier.setFilter(
                    query: employeeSalesState.query,
                  );
                },
                child: PagedListView<int, EmployeeSales>.separated(
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  pagingController: employeeSalesState.pagingController!,
                  builderDelegate: PagedChildBuilderDelegate<EmployeeSales>(
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
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Column(
                                      children: [
                                        _buildRow(
                                          '${context.l10n.name}:',
                                          Text(
                                            item.employeeName,
                                            style: AppText.smallSB.copyWith(
                                              color: AppColors.brandViolet,
                                            ),
                                          ),
                                        ),
                                        _buildDivider(),
                                        _buildRow(
                                          '${context.l10n.userRole}:',
                                          Text(
                                            item.employeeRole.displayCase,
                                            style: AppText.smallSB.copyWith(
                                              color: AppColors.black,
                                            ),
                                          ),
                                        ),
                                        _buildDivider(),
                                        _buildRow(
                                          '${context.l10n.staffId}:',
                                          Text(
                                            item.employeeCode ?? '',
                                            style: AppText.smallSB.copyWith(
                                              color: AppColors.black,
                                            ),
                                          ),
                                        ),
                                        _buildDivider(),
                                        _buildRow(
                                          '${context.l10n.totalItemsSold}:',
                                          Text(
                                            item.totalItemsSold.toString(),
                                            style: AppText.smallSB.copyWith(
                                              color: AppColors.black,
                                            ),
                                          ),
                                        ),
                                        _buildDivider(),
                                        _buildRow(
                                          '${context.l10n.totalRevenueGenerated}:',
                                          Text(
                                            item.totalRevenueGenerated.toString(),
                                            style: AppText.smallSB.copyWith(
                                              // Conflict resolved here, both sides were identical
                                              color: AppColors.black,
                                            ),
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
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
