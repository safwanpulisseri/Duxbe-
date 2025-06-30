import 'dart:async';

import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'brand_notifier.freezed.dart';
part 'brand_notifier.g.dart';
part 'brand_state.dart';

@Riverpod(keepAlive: false)
Future<Brand?> brand(
  BrandRef ref,
  String? brandId,
) async =>
    brandId == null ? null : ref.watch(brandRepoProvider).getBrandWithId(brandId: brandId);

@Riverpod(keepAlive: false)
class BrandNotifier extends _$BrandNotifier {
  late IBrandRepository _brandRepository;

  @override
  BrandState build() {
    _brandRepository = ref.watch(brandRepoProvider); // Watch for business changes
    ref.listen(businessNotifierProvider, (previous, next) {
      // Refresh the paging controller when business changes
      setFilter(pageNumber: 1);
    });

    state = BrandState.initial();

    // This is to set infinte scrolling in mobile devices
    return state.copyWith(
      pagingController: PagingController<int, Brand>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener(
          (pageKey) async {
            final brands = await getBrands(pageNumber: pageKey);
            final isLastPage = brands.data.length < state.pageSize;
            if (isLastPage) {
              state.pagingController!.appendLastPage(brands.data);
            } else {
              final nextPageKey = pageKey + 1;
              state.pagingController!.appendPage(brands.data, nextPageKey);
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

  Future<PaginatedResponse<Brand>> getBrands({
    String? query,
    int? pageSize,
    int? pageNumber,
  }) async {
    try {
      final brands = await _brandRepository.getBrands(
        query: query ?? state.query,
        pageSize: pageSize ?? state.pageSize,
        pageNumber: pageNumber ?? state.pageNumber,
      );

      return brands;
    } catch (e) {
      state = state.copyWith(
        status: BrandStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<Brand> upsertBrand(Brand brand) async {
    try {
      state = state.copyWith(status: BrandStatus.loading);
      final updatedUnit = await _brandRepository.upsertBrand(brand);
      state = state.copyWith(status: BrandStatus.success);
      setFilter(pageNumber: 1);
      Alert.showSnackBar(
        brand.brandId == null ? 'Brand Added' : 'Brand Updated',
        type: SnackBarType.success,
      );

      return updatedUnit;
    } catch (e) {
      state = state.copyWith(
        status: BrandStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<void> deleteBrand(Brand brand) async {
    try {
      state = state.copyWith(status: BrandStatus.loading);
      await _brandRepository.deleteBrand(brand.brandId!);
      state = state.copyWith(status: BrandStatus.success);
      setFilter(pageNumber: 1);
    } catch (e) {
      state = state.copyWith(
        status: BrandStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
    }
  }

  Future<void> setTable() async {
    if (state.stateManager == null) return;

    state.stateManager?.setShowLoading(true);
    state = state.copyWith(status: BrandStatus.loading);
    final brands = await getBrands();
    state = state.copyWith(
      status: BrandStatus.success,
      brands: brands.data,
      count: brands.count,
    );
    final baseIndex = (state.pageNumber - 1) * state.pageSize + 1;
    final rows = await PlutoGridStateManager.initializeRowsAsync(
      brandColumns,
      [
        for (int i = 0; i < state.brands.length; i++)
          PlutoRow(
            cells: {
              'sl_no': PlutoCell(value: baseIndex + i),
              'brand_name': PlutoCell(value: state.brands[i].name),
              'description': PlutoCell(value: state.brands[i].description ?? ''),
              'actions': PlutoCell(value: state.brands[i]),
            },
          ),
      ],
    );
    state.stateManager?.refRows.clear();
    state.stateManager?.refRows.addAll(rows);
    state.stateManager?.setShowLoading(false);
  }

  final List<PlutoColumn> brandColumns = <PlutoColumn>[
    PlutoColumn(
      title: 'SL.No',
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
      title: 'Brand Name',
      field: 'brand_name',
      titleSpan: TextSpan(
        text: AppRouter.l10n.brandName,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      title: 'Description',
      field: 'description',
      titleSpan: TextSpan(
        text: AppRouter.l10n.description,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      type: PlutoColumnType.text(),
      backgroundColor: AppColors.tableHeaderColor,
    ),
    PlutoColumn(
      titleTextAlign: PlutoColumnTextAlign.center,
      title: 'Action',
      field: 'actions',
      titleSpan: TextSpan(
        text: AppRouter.l10n.actions,
        style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
      ),
      renderer: (rendererContext) {
        final brand = rendererContext.cell.value as Brand;
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
                showDialog<void>(
                  context: AppRouter.rootContext,
                  builder: (context) => AddBrandDialog(brand: brand),
                );
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
                    title: AppRouter.l10n.deleteBrand,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppRouter.l10n.deleteThisBrand,
                        style: AppText.mediumN.copyWith(color: AppColors.primaryColor),
                      ),
                    ],
                    onPositive: (ref) {
                      ref.read(brandNotifierProvider.notifier).deleteBrand(brand).then(AppRouter.pop);
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
