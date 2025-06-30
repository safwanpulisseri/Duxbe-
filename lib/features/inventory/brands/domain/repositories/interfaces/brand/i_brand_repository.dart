import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';

abstract class IBrandRepository {
  Future<Brand?> getBrandWithId({required String brandId});
  Future<void> deleteBrand(String brandId);
  Future<Brand> upsertBrand(Brand brand);
  Future<PaginatedResponse<Brand>> getBrands({
    required int pageSize,
    required int pageNumber,
    String query = '',
  });
}
