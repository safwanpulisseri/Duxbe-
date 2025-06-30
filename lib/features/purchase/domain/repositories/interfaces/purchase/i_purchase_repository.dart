import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/features/purchase/purchase.dart';
import 'package:duxbe/shared/shared.dart';

abstract class IPurchaseRepository {
  Future<PurchaseView> createPurchaseTransaction(PurchasePageData data);
  Future<void> deletePurchaseTransaction(String purchaseId);
  Future<PurchaseView?> getPurchaseWithId({required String purchaseId});
  Future<PaginatedResponse<PurchaseView>> getPurchases({
    required int pageSize,
    required int pageNumber,
    String query = '',
    String? supplierId,
    bool? paidOrDueList,
    DateTime? fromDate,
    DateTime? toDate,
  });
  Future<List<CustomField>> getCustomFields();
  Future<List<PurchaseView>> getDuePurchasesWithSupplierId({required String supplierId, String query = ''});
  Future<void> settlePurchase({
    required String purchaseId,
    required double amount,
    required PaymentMode mode,
    required DateTime date,
    required String supplierId,
  });
  Future<String> getNextPurchaseReturnCode();
  Future<PurchaseReturn?> getPurchaseReturnWithId({required String purchaseReturnId});
  Future<PaginatedResponse<PurchaseReturn>> getPurchaseReturns({
    required int pageSize,
    required int pageNumber,
    String query = '',
  });
  Future<void> createPurchaseReturnTransaction(CreatePurchaseReturn data);
  Future<List<PurchaseAudit>> getPurchaseAudits(String purchaseId);
}
