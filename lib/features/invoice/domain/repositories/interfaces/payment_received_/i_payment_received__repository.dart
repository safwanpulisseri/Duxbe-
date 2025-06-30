import 'package:duxbe/features/invoice/domain/models/payment_received_/payment_received__model.dart';
import 'package:duxbe/shared/shared.dart';

abstract class IPaymentReceivedRepository {
  Future<String> getNextPaymentCode();
  Future<void> createPayment(Map<String, dynamic> paymentReceived);
  Future<PaginatedResponse<PaymentReceived>> getPaymentReceived({
    required int pageSize,
    required int pageNumber,
    String? query,
  });
  Future<void> createRefund(Map<String, dynamic> refund);
  Future<PaymentReceived?> getPaymentReceivedWithId({
    required String paymentId,
  });

  Future<void> editPayment(
      String paymentId, Map<String, dynamic> paymentReceived,);

  Future<void> deletePayment(
    String paymentId,
  );
}
