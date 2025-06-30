import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';

abstract class ITaxRepository {
  Future<Tax?> getTaxWithId({required String taxId});
  Future<void> deleteTax(String taxId);
  Future<Tax> upsertTax(Tax tax);
  Future<PaginatedResponse<Tax>> getTaxes({
    required int pageSize,
    required int pageNumber,
    String query = '',
    String? businessId,
  });
}
