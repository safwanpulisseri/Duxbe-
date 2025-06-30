import 'dart:async';

import 'package:duxbe/features/organization/organization.dart';
import 'package:duxbe/features/subscription/subscription.dart'; // For Subscription and repo provider
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hancod_theme/hancod_theme.dart';
// import 'package:go_router/go_router.dart'; // If actions need navigation
// import 'package:hancod_theme/hancod_theme.dart'; // If ConfirmationDialog is needed
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'subscription_notifier.freezed.dart';
part 'subscription_notifier.g.dart';
part 'subscription_state.dart';

@Riverpod(keepAlive: false)
class SubscriptionNotifier extends _$SubscriptionNotifier {
  late ISubscriptionRepository _subscriptionRepository;
  // _rawSubscriptionsData and _fetchAllSubscriptionsFromRepo removed

  @override
  SubscriptionState build() {
    _subscriptionRepository = ref.watch(subscriptionRepoProvider);
    ref.listen(organizationNotifierProvider, (previous, next) {
      // _rawSubscriptionsData = null; // Removed
      state.pagingController?.refresh();
      setTable(pageNumber: 1);
    });

    state = SubscriptionState.initial();

    return state.copyWith(
      pagingController: PagingController<int, Subscription>(
        firstPageKey: 1,
      )..addPageRequestListener(
          (pageKey) async {
            try {
              final response = await getSubscriptions(
                pageNumberOverride: pageKey,
                pageSizeOverride: state.pageSize, // Use current page size
              );
              final isLastPage = response.data.length < state.pageSize;
              if (isLastPage) {
                state.pagingController!.appendLastPage(response.data);
              } else {
                final nextPageKey = pageKey + 1;
                state.pagingController!.appendPage(response.data, nextPageKey);
              }
            } catch (e) {
              state.pagingController!.error = e.toString();
              // Alert already shown in getSubscriptions if it sets state to error
            }
          },
        ),
    );
  }

  // _fetchAllSubscriptionsFromRepo removed

  Future<PaginatedResponse<Subscription>> getSubscriptions({
    String? queryOverride,
    int? pageSizeOverride,
    int? pageNumberOverride,
  }) async {
    state = state.copyWith(status: SubscriptionStatus.loading);
    final currentQuery = queryOverride ?? state.query;
    final currentPageSize = pageSizeOverride ?? state.pageSize;
    final currentPageNumber = pageNumberOverride ?? state.pageNumber;

    try {
      final response = await _subscriptionRepository.getAllActiveSubscriptions(
        query: currentQuery, // Assuming getAllActiveSubscriptions accepts query
        pageSize: currentPageSize,
        pageNumber: currentPageNumber,
      );
      state = state.copyWith(
        status: SubscriptionStatus.success,
        subscriptions: response.data,
        count: response.count,
        pageNumber: currentPageNumber,
        pageSize: currentPageSize,
        query: currentQuery,
        error: '',
      );
      return response;
    } catch (e) {
      state = state.copyWith(
        status: SubscriptionStatus.error,
        error: e.toString(),
        subscriptions: [],
        count: 0,
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      return const PaginatedResponse<Subscription>(data: [], count: 0);
    }
  }

  void setStateManager({required PlutoGridStateManager stateManager}) {
    state = state.copyWith(stateManager: stateManager);
    setTable();
  }

  void setFilter({String? query}) {
    state = state.copyWith(query: query ?? state.query, pageNumber: 1);
    state.pagingController?.refresh();
    setTable();
  }

  void refreshData() {
    // _rawSubscriptionsData = null; // Removed
    state = state.copyWith(pageNumber: 1);
    state.pagingController?.refresh();
    setTable();
  }

  Future<void> setTable({
    String? query,
    int? pageSize,
    int? pageNumber,
  }) async {
    state.stateManager?.setShowLoading(true);
    // state = state.copyWith(status: SubscriptionStatus.loading); // Status set by getSubscriptions

    await getSubscriptions(
      queryOverride: query,
      pageSizeOverride: pageSize,
      pageNumberOverride: pageNumber,
    );

    if (state.status == SubscriptionStatus.error) {
      state.stateManager?.setShowLoading(false);
      state.stateManager?.removeAllRows();
      return;
    }

    // state is already updated by getSubscriptions

    final rows = await PlutoGridStateManager.initializeRowsAsync(
      subscriptionColumns,
      [
        for (int i = 0; i < state.subscriptions.length; i++)
          PlutoRow(
            cells: {
              'current_plan': PlutoCell(
                value: state.subscriptions[i].plan != null
                    ? state.subscriptions[i].plan!.name
                    : state.subscriptions[i].addon != null
                        ? state.subscriptions[i].addon!.name
                        : 'N/A',
              ),
              'amount': PlutoCell(
                value: state.subscriptions[i].planAmount?.toStringAsFixed(2) ?? 'N/A',
              ), // Added toStringAsFixed(2)
              'status': PlutoCell(value: state.subscriptions[i].status.displayCase),
              'next_billing_date':
                  PlutoCell(value: state.subscriptions[i].currentEnd?.toLocal().toString().substring(0, 10) ?? 'N/A'),
              // 'actions': PlutoCell(value: state.subscriptions[i]), // Example if actions are needed
            },
          ),
      ],
    );
    state.stateManager?.refRows.clear();
    state.stateManager?.refRows.addAll(rows);
    state.stateManager?.setShowLoading(false);
  }

  final List<PlutoColumn> subscriptionColumns = <PlutoColumn>[
    PlutoColumn(
      title: AppRouter.l10n.currentPlan,
      field: 'current_plan',
      titleSpan: TextSpan(
        text: AppRouter.l10n.currentPlan,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.amount,
      field: 'amount',
      width: 100,
      titleSpan: TextSpan(
        text: AppRouter.l10n.amount,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.status,
      field: 'status',
      width: 120,
      titleSpan: TextSpan(
        text: AppRouter.l10n.status,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.nextBillingDate,
      field: 'next_billing_date',
      width: 120,
      titleSpan: TextSpan(
        text: AppRouter.l10n.nextBillingDate,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    // Example Action Column (if needed in the future, uncomment and customize)
    // PlutoColumn(
    //   titleTextAlign: PlutoColumnTextAlign.center,
    //   title: 'Action',
    //   field: 'actions',
    //   width: 80,
    //   renderer: (rendererContext) {
    //     final subscription = rendererContext.cell.value as Subscription;
    //     return IconButton(
    //       icon: const Icon(Icons.edit, color: AppColors.primaryColor),
    //       onPressed: () {
    //         // Handle action, e.g., navigate to detail page
    //         // AppRouter.goNamed(AppRouter.subscriptionDetails, pathParameters: { 'id': subscription.id });
    //       },
    //     );
    //   },
    //   type: PlutoColumnType.text(),
    //   backgroundColor: AppColors.tableHeaderColor,
    //   textAlign: PlutoColumnTextAlign.center,
    // ),
  ];
}
