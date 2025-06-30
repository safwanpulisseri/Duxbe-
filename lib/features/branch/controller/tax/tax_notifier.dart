import 'dart:async';

import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tax_notifier.freezed.dart';
part 'tax_notifier.g.dart';
part 'tax_state.dart';

@Riverpod(keepAlive: false)
class TaxNotifier extends _$TaxNotifier {
  late ITaxRepository _settingsRepository;

  @override
  TaxState build(String businessId) {
    _settingsRepository = ref.watch(taxRepoProvider);
    Future(getTaxes);
    return TaxState.initial();
  }

  Future<void> getTaxes() async {
    state = state.copyWith(status: TaxStatus.loading);

    try {
      final taxes = await _settingsRepository.getTaxes(pageNumber: 1, pageSize: 100, businessId: businessId);
      state = state.copyWith(
        status: TaxStatus.success,
        taxes: taxes.data,
      );
    } catch (e) {
      state = state.copyWith(status: TaxStatus.error, error: e.toString());
      rethrow;
    }
  }

  Future<Tax> upsertTax(Tax tax) async {
    state = state.copyWith(status: TaxStatus.loading);
    try {
      final brands = await _settingsRepository.upsertTax(tax.copyWith(businessId: businessId));
      unawaited(getTaxes());
      return brands;
    } catch (e) {
      state = state.copyWith(status: TaxStatus.error, error: e.toString());
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<void> deleteTax(String taxId) async {
    state = state.copyWith(status: TaxStatus.loading);
    try {
      await _settingsRepository.deleteTax(taxId);
      unawaited(getTaxes());
    } catch (e) {
      state = state.copyWith(status: TaxStatus.error, error: e.toString());
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }
}
