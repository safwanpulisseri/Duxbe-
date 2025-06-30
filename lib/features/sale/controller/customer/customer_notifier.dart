import 'dart:async';

import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/sale/presentation/customer_list/customer_settlement.dart';
import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'customer_notifier.freezed.dart';
part 'customer_notifier.g.dart';
part 'customer_state.dart';

@Riverpod(keepAlive: false)
Future<Customer?> customer(
  CustomerRef ref,
  String? customerId,
) async =>
    customerId == null ? null : ref.watch(customerRepoProvider).getCustomerWithId(customerId: customerId);

@Riverpod(keepAlive: false)
class CustomerNotifier extends _$CustomerNotifier {
  late ICustomerRepository _customerRepository;

  @override
  CustomerState build() {
    _customerRepository = ref.watch(customerRepoProvider); // Watch for business changes
    ref.listen(businessNotifierProvider, (previous, next) {
      // Refresh the paging controller when business changes
      state.pagingController?.refresh();
      getCustomers(pageNumber: 1);
    });

    state = CustomerState.initial();

    // This is to set infinte scrolling in mobile devices
    return state.copyWith(
      pagingController: PagingController<int, Customer>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener(
          (pageKey) async {
            final customers = await getCustomers(pageNumber: pageKey);
            final isLastPage = customers.data.length < state.pageSize;
            if (isLastPage) {
              state.pagingController!.appendLastPage(customers.data);
            } else {
              final nextPageKey = pageKey + 1;
              state.pagingController!.appendPage(customers.data, nextPageKey);
            }
          },
        ),
    );
  }

  void setStateManager({required PlutoGridStateManager stateManager}) {
    state = state.copyWith(stateManager: stateManager);
    setTable();
  }

  void setFilter({String? query}) {
    state = state.copyWith(query: query ?? state.query);
    state.pagingController?.refresh();
    setTable();
  }

  Future<PaginatedResponse<Customer>> getCustomers({
    String? query,
    int? pageSize,
    int? pageNumber,
  }) async {
    try {
      final customers = await _customerRepository.getCustomers(
        query: query ?? state.query,
        pageSize: pageSize ?? state.pageSize,
        pageNumber: pageNumber ?? state.pageNumber,
      );
      return customers;
    } catch (e) {
      state = state.copyWith(
        status: CustomerStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<Customer> upsertCustomer(Customer customer, {dynamic image}) async {
    try {
      state = state.copyWith(status: CustomerStatus.loading);
      final updatedCustomer = await _customerRepository.upsertCustomer(customer, image: image);
      state = state.copyWith(status: CustomerStatus.success);
      setFilter();
      return updatedCustomer;
    } catch (e) {
      state = state.copyWith(
        status: CustomerStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<void> deleteCustomer(Customer customer) async {
    try {
      state = state.copyWith(status: CustomerStatus.loading);
      await _customerRepository.deleteCustomer(customer.customerId!);
      state = state.copyWith(status: CustomerStatus.success);
      setFilter();
    } catch (e) {
      state = state.copyWith(
        status: CustomerStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
    }
  }

  Future<void> setTable({
    String? query,
    int? pageSize,
    int? pageNumber,
  }) async {
    state.stateManager?.setShowLoading(true);
    state = state.copyWith(status: CustomerStatus.loading);
    final customers = await getCustomers(
      query: query,
      pageSize: pageSize,
      pageNumber: pageNumber,
    );
    state = state.copyWith(
      status: CustomerStatus.success,
      customers: customers.data,
      count: customers.count,
      pageNumber: pageNumber ?? state.pageNumber,
    );

    final baseIndex = (state.pageNumber - 1) * state.pageSize + 1;
    final rows = await PlutoGridStateManager.initializeRowsAsync(
      customerColumns,
      [
        for (int i = 0; i < state.customers.length; i++)
          PlutoRow(
            cells: {
              'sl_no': PlutoCell(value: baseIndex + i),
              'name': PlutoCell(value: state.customers[i].name),
              'phone': PlutoCell(value: state.customers[i].phone ?? 'N/A'),
              'email': PlutoCell(value: state.customers[i].email ?? 'N/A'),
              'due': PlutoCell(value: state.customers[i].customerBalance),
              'actions': PlutoCell(value: state.customers[i]),
            },
          ),
      ],
    );
    state.stateManager?.refRows.clear();
    state.stateManager?.refRows.addAll(rows);
    state.stateManager?.setShowLoading(false);
  }

  final List<PlutoColumn> customerColumns = <PlutoColumn>[
    PlutoColumn(
      title: AppRouter.l10n.slNo,
      field: 'sl_no',
      width: 24,
      titleSpan: TextSpan(
        text: AppRouter.l10n.slNo,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.name,
      field: 'name',
      titleSpan: TextSpan(
        text: AppRouter.l10n.name,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.phoneNo,
      field: 'phone',
      titleSpan: TextSpan(
        text: AppRouter.l10n.phoneNo,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.email,
      field: 'email',
      titleSpan: TextSpan(
        text: AppRouter.l10n.email,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.customerBalance,
      field: 'due',
      titleSpan: TextSpan(
        text: AppRouter.l10n.customerBalance,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      titleTextAlign: PlutoColumnTextAlign.center,
      title: AppRouter.l10n.actions,
      field: 'actions',
      titleSpan: TextSpan(
        text: AppRouter.l10n.actions,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      renderer: (rendererContext) {
        final customer = rendererContext.cell.value as Customer;

        return MenuAnchor(
          builder: (context, controller, child) {
            return IconButton(
              onPressed: controller.isOpen ? controller.close : controller.open,
              icon: const Icon(Icons.more_horiz),
            );
          },
          menuChildren: [
            MenuItemButton(
              leadingIcon: Assets.icons.edit.svg(width: 20),
              style: MenuItemButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
              ),
              onPressed: () {
                AppRouter.goNamed(AppRouter.customerDetails, pathParameters: {'id': customer.customerId!});
              },
              child: Text(AppRouter.l10n.edit),
            ),
            MenuItemButton(
              leadingIcon: Assets.icons.delete.svg(width: 20),
              onPressed: () {
                showDialog<void>(
                  context: AppRouter.rootContext,
                  builder: (context) => ConfirmationDialog(
                    title: AppRouter.l10n.deleteCustomer,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppRouter.l10n.areYouSureYouWantToDeleteCustomerName(customer.name),
                        style: AppText.mediumN.copyWith(color: AppColors.primaryColor),
                      ),
                    ],
                    onPositive: (ref) {
                      ref.read(customerNotifierProvider.notifier).deleteCustomer(customer).then(context.pop);
                    },
                  ),
                );
              },
              style: MenuItemButton.styleFrom(foregroundColor: AppColors.red),
              child: Text(AppRouter.l10n.delete),
            ),
            MenuItemButton(
              leadingIcon: const Icon(Icons.description, color: AppColors.primaryColor),
              onPressed: () {
                showDialog<void>(
                  context: AppRouter.rootContext,
                  builder: (context) {
                    return CustomerSettlementDialog(
                      customerId: customer.customerId!,
                    );
                  },
                );
              },
              style: MenuItemButton.styleFrom(foregroundColor: AppColors.primaryColor),
              child: Text(AppRouter.l10n.settlements),
            ),
          ],
        );
      },
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
  ];
}
