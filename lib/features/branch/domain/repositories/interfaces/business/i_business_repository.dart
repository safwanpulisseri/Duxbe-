import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/branch/branch.dart';
import 'package:duxbe/shared/shared.dart';

abstract class IBusinessRepository {
  Future<Business?> getBusinessWithId({required String businessId});
  Future<void> deleteBusiness(String businessId);
  Future<Business> upsertBusiness(Map<String, dynamic> data, {dynamic image});
  Future<PaginatedResponse<Business>> getBusinesses({
    required int pageSize,
    required int pageNumber,
    String query = '',
  });
  Future<List<FiscalYear>> getFiscalYears();
  Future<WhatsappIntegration> editWhatsappIntegration(WhatsappIntegration settings);
  Future<List<Country>> getCountries({String? query});
  Future<List<CountryState>> getStates({String? query, String? country});
  Future<(DateTime, DateTime)?> getCurrentFiscalPeriod(String? businessId);
  Future<Country> getCountryByIso({required String id});
  Future<Business> updateTaxSettings({required Map<String, dynamic> data});
  Future<Business> updatePrintSettings({required Map<String, dynamic> data});
  Future<Business> updateGeneralSettings({required Map<String, dynamic> data});
}
