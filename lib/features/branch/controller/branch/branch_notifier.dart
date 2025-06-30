import 'dart:async';

import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/branch/branch.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'branch_notifier.freezed.dart';
part 'branch_notifier.g.dart';
part 'branch_state.dart';

@Riverpod(keepAlive: false)
Future<Business?> business(
  BusinessRef ref,
  String? businessId,
) async =>
    businessId == null ? null : ref.watch(businessRepoProvider).getBusinessWithId(businessId: businessId);

@Riverpod(keepAlive: false)
class BranchNotifier extends _$BranchNotifier {
  late IBusinessRepository _businessRepository;

  @override
  BranchState build() {
    _businessRepository = ref.watch(businessRepoProvider); // Watch for business changes
    ref.listen(businessNotifierProvider, (previous, next) {
      // Refresh the paging controller when business changes
      setFilter(pageNumber: 1);
    });

    state = BranchState.initial();

    // This is to set infinte scrolling in mobile devices
    return state.copyWith(
      pagingController: PagingController<int, Business>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener(
          (pageKey) async {
            final businesses = await getBusinesses(pageNumber: pageKey);
            final isLastPage = businesses.data.length < state.pageSize;
            if (isLastPage) {
              state.pagingController!.appendLastPage(businesses.data);
            } else {
              final nextPageKey = pageKey + 1;
              state.pagingController!.appendPage(businesses.data, nextPageKey);
            }
          },
        ),
    );
  }

  void setStateManager({required PlutoGridStateManager stateManager}) {
    state = state.copyWith(stateManager: stateManager);
    setTable();
  }

  void setFilter({
    String? query,
    int? pageSize,
    int? pageNumber,
  }) {
    state = state.copyWith(
      query: query ?? state.query,
      pageSize: pageSize ?? state.pageSize,
      pageNumber: pageNumber ?? state.pageNumber,
    );
    state.pagingController?.refresh();
    setTable();
  }

  Future<PaginatedResponse<Business>> getBusinesses({
    String? query,
    int? pageSize,
    int? pageNumber,
  }) async {
    try {
      final businesses = await _businessRepository.getBusinesses(
        query: query ?? state.query,
        pageSize: pageSize ?? state.pageSize,
        pageNumber: pageNumber ?? state.pageNumber,
      );
      return businesses;
    } catch (e) {
      state = state.copyWith(
        status: BranchStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<Business> upsertBusiness(Map<String, dynamic> data, {dynamic image}) async {
    try {
      state = state.copyWith(status: BranchStatus.loading);
      final businessJson = {
        if (data['business_id'] != null) 'business_id': data['business_id'],
        'org_id': ref.read(authNotifierProvider).user?.orgId,
        'name': data['name'],
        'allow_sales_when_outofstock': data['allow_out_of_stock'],
        'print_on_purchase': data['on_purchase'],
        'print_on_sale': data['on_sale'],
        'allow_walkin_customer': data['allow_walk_in'],
        'print_barcode_on_purchase': data['on_barcode'],
        'currency': data['currency'],
        'country': data['country'],
        'state': data['state'],
        'time_zone': data['time_zone'],
        'fiscal_id': data['fiscal_year'],
        'gst_in': data['gst_in'],
        'legal_business_name': data['legal_name'],
        'trade_name': data['trade_name'],
        'is_gst_registered': data['gst_on'],
        'format': data['format'],
        'contact_email': data['contact_email'],
        'contact_phone': data['contact_phone'],
        // ignore: avoid_dynamic_calls
        'gst_registered_date': data['register_on_date'] is DateTime
            ? data['register_on_date']?.toIso8601String()
            : data['register_on_date'],
        'business_type': data['business_type'],
      };
      final business = await _businessRepository.upsertBusiness(businessJson, image: image);
      state = state.copyWith(status: BranchStatus.success);
      setFilter(pageNumber: 1);
      unawaited(ref.read(authNotifierProvider.notifier).getUserDetails());
      unawaited(
        ref.read(businessNotifierProvider.notifier).setBusiness(ref.read(businessNotifierProvider)?.businessId),
      );
      return business;
    } catch (e) {
      state = state.copyWith(
        status: BranchStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<Business> updateTaxSettings({required Map<String, dynamic> data}) async {
    try {
      state = state.copyWith(status: BranchStatus.loading);
      final business = await _businessRepository.updateTaxSettings(data: data);
      state = state.copyWith(status: BranchStatus.success);

      return business;
    } catch (e) {
      state = state.copyWith(
        status: BranchStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<Business> updatePrintSettings({required Map<String, dynamic> data}) async {
    try {
      state = state.copyWith(status: BranchStatus.loading);
      final business = await _businessRepository.updatePrintSettings(data: data);
      state = state.copyWith(status: BranchStatus.success);

      return business;
    } catch (e) {
      state = state.copyWith(
        status: BranchStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<Business> updateGeneralSettings({required Map<String, dynamic> data}) async {
    try {
      state = state.copyWith(status: BranchStatus.loading);
      final business = await _businessRepository.updateGeneralSettings(data: data);
      state = state.copyWith(status: BranchStatus.success);
      ref
        ..invalidate(businessProvider(business.businessId))
        ..invalidate(branchProvider)
        ..invalidate(businessNotifierProvider);
      Alert.showSnackBar(AppRouter.l10n.settingsUpdatedSuccessfully, type: SnackBarType.success);
      return business;
    } catch (e) {
      state = state.copyWith(
        status: BranchStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<void> deleteBusiness(Business business) async {
    try {
      state = state.copyWith(status: BranchStatus.loading);
      await _businessRepository.deleteBusiness(business.businessId);
      state = state.copyWith(status: BranchStatus.success);
      setFilter(pageNumber: 1);
    } catch (e) {
      state = state.copyWith(
        status: BranchStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
    }
  }

  Future<void> editWhatsappSettings(WhatsappIntegration whatsappIntegration) async {
    try {
      await _businessRepository.editWhatsappIntegration(whatsappIntegration);
      setFilter(pageNumber: 1);
      unawaited(ref.read(authNotifierProvider.notifier).getUserDetails());
      unawaited(
        ref.read(businessNotifierProvider.notifier).setBusiness(ref.read(businessNotifierProvider)?.businessId),
      );
    } catch (e) {
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
    }
  }

  Future<void> setTable() async {
    state.stateManager?.setShowLoading(true);
    state = state.copyWith(status: BranchStatus.loading);
    final businesses = await getBusinesses();
    state = state.copyWith(
      status: BranchStatus.success,
      businesses: businesses.data,
      count: businesses.count,
    );

    final baseIndex = (state.pageNumber - 1) * state.pageSize + 1;
    final rows = await PlutoGridStateManager.initializeRowsAsync(
      businessColumns,
      [
        for (int i = 0; i < state.businesses.length; i++)
          PlutoRow(
            cells: {
              'sl_no': PlutoCell(value: baseIndex + i),
              'name': PlutoCell(value: state.businesses[i].name),
              'type': PlutoCell(value: state.businesses[i].businessType.name.displayCase),
              'location': PlutoCell(
                value: (state.businesses[i].state == null ? '' : '${state.businesses[i].state!}, ') +
                    (state.businesses[i].country == null ? '' : ' ${state.businesses[i].country!}'),
              ),
              'actions': PlutoCell(value: state.businesses[i]),
            },
          ),
      ],
    );
    state.stateManager?.refRows.clear();
    state.stateManager?.refRows.addAll(rows);
    state.stateManager?.setShowLoading(false);
  }

  final List<PlutoColumn> businessColumns = <PlutoColumn>[
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
      title: AppRouter.l10n.type,
      field: 'type',
      titleSpan: TextSpan(
        text: AppRouter.l10n.type,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: AppRouter.l10n.location,
      field: 'location',
      titleSpan: TextSpan(
        text: AppRouter.l10n.location,
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
        final branch = rendererContext.cell.value as Business;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              icon: Assets.icons.edit.svg(),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primaryColor.withOpacity(.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () {
                AppRouter.pushNamed(AppRouter.branchDetails, pathParameters: {'id': branch.businessId});
              },
              label: Text(AppRouter.l10n.edit),
            ),
            const SizedBox(width: 20),
            TextButton.icon(
              icon: Assets.icons.delete.svg(),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.red.withOpacity(.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () {
                showDialog<void>(
                  context: AppRouter.rootContext,
                  builder: (context) => ConfirmationDialog(
                    title: AppRouter.l10n.deleteBusiness,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppRouter.l10n.areYouSureYouWantToDeleteBusiness(branch.name),
                        style: AppText.mediumN.copyWith(color: AppColors.primaryColor),
                      ),
                    ],
                    onPositive: (ref) {
                      ref.read(branchNotifierProvider.notifier).deleteBusiness(branch).then(AppRouter.pop);
                    },
                  ),
                );
              },
              label: Text(
                AppRouter.l10n.delete,
                style: AppText.mediumN.copyWith(color: AppColors.red),
              ),
            ),
          ],
        );
      },
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
  ];
}
