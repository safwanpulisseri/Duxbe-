import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'order_details_notifier.freezed.dart';
part 'order_details_notifier.g.dart';
part 'order_details_state.dart';

@Riverpod(keepAlive: false)
class OrderDetailsNotifier extends _$OrderDetailsNotifier {
  late ISaleRepository _saleRepository;

  @override
  OrderDetailsState build() {
    _saleRepository = ref.read(saleRepoProvider);

    return OrderDetailsState.initial();
  }

  Future<void> updateSaleStatus(String saleId, String statusId) async {
    try {
      await _saleRepository.updateSaleStatus(saleId, statusId);
    } on AppException catch (e) {
      Alert.showSnackBar(e.message);
    }
  }

  Future<void> updateSaleEmployee(String saleId, String employeeId) async {
    try {
      await _saleRepository.updateSaleEmployee(saleId, employeeId);
    } on AppException catch (e) {
      Alert.showSnackBar(e.message);
    }
  }

  Future<void> updateSale(SaleView sale, Map<String, dynamic> data) async {
    try {
      state = state.copyWith(status: OrderDetailsStatus.loading);
      await _saleRepository.updateSale(sale, data);
      state = state.copyWith(status: OrderDetailsStatus.success);
      Alert.showSnackBar(AppRouter.l10n.orderUpdatedSuccessfully, type: SnackBarType.success);
    } catch (e) {
      state = state.copyWith(status: OrderDetailsStatus.error);
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }
}
