import 'package:duxbe/features/purchase/purchase.dart';
import 'package:duxbe/shared/shared.dart';

abstract class ISupplierRepository {
  Future<Supplier?> getSupplierWithId({required String supplierId});
  Future<void> deleteSupplier(String supplierId);
  Future<Supplier> upsertSupplier(Supplier supplier, {dynamic image});
  Future<PaginatedResponse<Supplier>> getSuppliers({
    required int pageSize,
    required int pageNumber,
    String query = '',
  });
}
