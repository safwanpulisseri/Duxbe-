import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/branch/branch.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'business_repository.g.dart';

@Riverpod(keepAlive: true)
IBusinessRepository businessRepo(BusinessRepoRef ref) => BusinessRepository(ref);

class BusinessRepository implements IBusinessRepository {
  BusinessRepository(this.ref) : _supabaseClient = ref.watch(supabaseProvider);
  final BusinessRepoRef ref;
  final SupabaseClient _supabaseClient;

  @override
  Future<void> deleteBusiness(String businessId) async {
    try {
      return await _supabaseClient.from(DbConstants.businesses).delete().eq('business_id', businessId);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<PaginatedResponse<Business>> getBusinesses({
    required int pageSize,
    required int pageNumber,
    String query = '',
  }) async {
    try {
      final offset = (pageNumber - 1) * pageSize;
      final response = await _supabaseClient
          .from(DbConstants.businesses)
          .select('*, whatsapp_integration(*)')
          .ilike('name', '%$query%')
          .eq('org_id', ref.read(authNotifierProvider).user!.orgId)
          .range(offset, pageSize + offset - 1)
          .count(CountOption.exact);
      return PaginatedResponse(
        data: response.data.map(Business.fromJson).toList(),
        count: response.count,
      );
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<Business?> getBusinessWithId({required String businessId}) async {
    try {
      return await _supabaseClient
          .from(DbConstants.businesses)
          .select('*, whatsapp_integration(*)')
          .eq('business_id', businessId)
          .single()
          .withConverter(Business.fromJson);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<Business> upsertBusiness(Map<String, dynamic> data, {dynamic image}) async {
    try {
      var businessId = data['business_id']?.toString();

      // This RPC adds the user and business to respective tables
      businessId ??= await _supabaseClient.rpc<String>(
        RPCConstants.generateBusinessDependencies,
        params: {
          'business_data': {
            'name': data['name'],
            'org_id': data['org_id'],
            'business_type': data['business_type'],
            'currency': data['currency'],
          },
        },
      );

      data['business_id'] = businessId;

      data.removeWhere((key, value) => value == null);

      final business = await _supabaseClient
          .from(DbConstants.businesses)
          .upsert(data)
          .select('*, whatsapp_integration(*)')
          .single()
          .withConverter(Business.fromJson);
      String? url;
      if (image is Uint8List) {
        final fileName = '${_supabaseClient.auth.currentUser!.id}.png';
        url = await ref.read(supabaseStorageProvider).uploadImage(
              businessId: business.businessId,
              fileName: fileName,
              filePath: 'business-logo',
              file: image,
            );
      } else if (image is String) {
        url = image;
      }

      final updatedBusiness = await _supabaseClient
          .from(DbConstants.businesses)
          .update({
            'logo': url,
          })
          .eq('business_id', business.businessId)
          .select('*, whatsapp_integration(*)')
          .single()
          .withConverter(Business.fromJson);

      return updatedBusiness;
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<List<FiscalYear>> getFiscalYears() async {
    try {
      return await _supabaseClient.from(DbConstants.fiscalYears).select().withConverter(
            (data) => data.map(FiscalYear.fromJson).toList(),
          );
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<WhatsappIntegration> editWhatsappIntegration(WhatsappIntegration settings) async {
    try {
      final response = await _supabaseClient
          .from(DbConstants.whatsappIntegration)
          .upsert(settings.toJson())
          .select()
          .single()
          .withConverter(WhatsappIntegration.fromJson);

      return response;
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<List<Country>> getCountries({String? query}) async {
    try {
      return await _supabaseClient
          .from(DbConstants.countries)
          .select()
          .ilike('name', '%$query%')
          .limit(10)
          .withConverter(
            (data) => data.map(Country.fromJson).toList(),
          );
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<Country> getCountryByIso({required String id}) async {
    try {
      return await _supabaseClient
          .from(DbConstants.countries)
          .select()
          .eq('iso_code', id)
          .single()
          .withConverter(Country.fromJson);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<List<CountryState>> getStates({String? query, String? country}) async {
    try {
      Country? countryData;
      if (country != null) {
        countryData =
            await _supabaseClient.from(DbConstants.countries).select().eq('name', country).maybeSingle().withConverter(
                  (data) => data == null ? null : Country.fromJson(data),
                );
      }

      if (countryData == null) {
        return [];
      }

      return await _supabaseClient
          .from(DbConstants.states)
          .select()
          .ilike('name', '%$query%')
          .eq('country_id', countryData.id)
          .limit(10)
          .withConverter(
            (data) => data.map(CountryState.fromJson).toList(),
          );
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<(DateTime, DateTime)?> getCurrentFiscalPeriod(String? businessId) async {
    try {
      if (businessId == null) {
        return null; // Business ID is required
      }
      final response = await _supabaseClient.rpc<PostgrestMap>(
        RPCConstants.getCurrentFiscalPeriod,
        params: {'p_business_id': businessId},
      );

      final startDateStr = response['start_date'] as String?;
      final endDateStr = response['end_date'] as String?;

      if (startDateStr == null || endDateStr == null) {
        return null; // Missing dates in response
      }

      final startDate = DateTime.tryParse(startDateStr);
      final endDate = DateTime.tryParse(endDateStr);

      if (startDate == null || endDate == null) {
        return null; // Could not parse dates
      }

      return (startDate, endDate);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<Business> updateGeneralSettings({required Map<String, dynamic> data}) async {
    try {
      return await _supabaseClient
          .from(DbConstants.businesses)
          .update(data)
          .eq('business_id', data['business_id'].toString())
          .select('*, whatsapp_integration(*)')
          .single()
          .withConverter(Business.fromJson);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<Business> updatePrintSettings({required Map<String, dynamic> data}) async {
    try {
      return await _supabaseClient
          .from(DbConstants.businesses)
          .update(data)
          .eq('business_id', data['business_id'].toString())
          .select('*, whatsapp_integration(*)')
          .single()
          .withConverter(Business.fromJson);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<Business> updateTaxSettings({required Map<String, dynamic> data}) async {
    try {
      return await _supabaseClient
          .from(DbConstants.businesses)
          .update(data)
          .eq('business_id', data['business_id'].toString())
          .select('*, whatsapp_integration(*)')
          .single()
          .withConverter(Business.fromJson);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }
}
