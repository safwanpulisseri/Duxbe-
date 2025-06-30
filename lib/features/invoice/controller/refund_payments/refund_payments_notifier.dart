import 'package:duxbe/features/invoice/domain/invoice_domain.dart';
import 'package:duxbe/shared/utils/alert.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hancod_theme/alert.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'refund_payments_notifier.freezed.dart';
part 'refund_payments_notifier.g.dart';
part 'refund_payments_state.dart';

@Riverpod(keepAlive: false)
class RefundPaymentsNotifier extends _$RefundPaymentsNotifier {
  @override
  RefundPaymentsState build() {
    return RefundPaymentsState.initial();
  }

  Future<void> createRefund(Map<String, dynamic> refund) async {
    try {
      state = state.copyWith(status: RefundPaymentsStatus.loading);
      await ref.read(paymentReceivedRepoProvider).createRefund(refund);
      state = state.copyWith(status: RefundPaymentsStatus.success);
    } catch (e) {
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }
}
