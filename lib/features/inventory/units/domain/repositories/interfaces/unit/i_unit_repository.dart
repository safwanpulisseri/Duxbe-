import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';

abstract class IUnitRepository {
  Future<Unit?> getUnitWithId({required String unitId});
  Future<void> deleteUnit(String unitId);
  Future<Unit> upsertUnit(Unit unit);
  Future<PaginatedResponse<Unit>> getUnits({
    required int pageSize,
    required int pageNumber,
    String query = '',
  });
}
