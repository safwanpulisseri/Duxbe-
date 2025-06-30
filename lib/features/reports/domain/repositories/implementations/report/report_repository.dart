import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/reports/reports.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'report_repository.g.dart';

@Riverpod(keepAlive: true)
IReportRepository reportRepo(ReportRepoRef ref) => ReportRepository(ref);

class ReportRepository implements IReportRepository {
  ReportRepository(this.ref) : _supabaseClient = ref.watch(supabaseProvider);
  final ReportRepoRef ref;
  final SupabaseClient _supabaseClient;

  @override
  Future<PaginatedResponse<Due>> getDueReport({
    required int pageSize,
    required int pageNumber,
    String query = '',
    bool? salesOrPurchase,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      final offset = (pageNumber - 1) * pageSize;
      var queryBuilder = _supabaseClient
          .from(DbConstants.salesPurchasesDueReport)
          .select()
          .ilike('invoice_no', '%$query%')
          .eq('business_id', businessId);

      if (salesOrPurchase != null) {
        if (!salesOrPurchase) {
          queryBuilder = queryBuilder.eq('transaction_type', 'purchase');
        } else {
          queryBuilder = queryBuilder.eq('transaction_type', 'sale');
        }
      }
      if (fromDate != null) {
        queryBuilder = queryBuilder.gte('date', fromDate.toIso8601String());
      }
      if (toDate != null) {
        queryBuilder = queryBuilder.lte('date', toDate.toIso8601String());
      }

      final response = await queryBuilder
          .range(offset, pageSize + offset - 1)
          .count(CountOption.exact);
      return PaginatedResponse(
        data: response.data.map(Due.fromJson).toList(),
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
  Future<PaginatedResponse<DailyTransaction>> getDailyTransactionReport({
    required int pageSize,
    required int pageNumber,
    String query = '',
    bool? payIn,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      final offset = (pageNumber - 1) * pageSize;
      var queryBuilder = _supabaseClient
          .from(DbConstants.dailyTransactionsReport)
          .select()
          .eq('business_id', businessId);

      if (query.isNotEmpty) {
        queryBuilder =
            queryBuilder.or('name.ilike.%$query%,type.ilike.%$query%');
      }

      if (payIn != null) {
        if (payIn) {
          queryBuilder = queryBuilder.gt('payment_in', 0);
        } else {
          queryBuilder = queryBuilder.gt('payment_out', 0);
        }
      }
      if (fromDate != null) {
        queryBuilder = queryBuilder.gte('date', fromDate.toIso8601String());
      }
      if (toDate != null) {
        queryBuilder = queryBuilder.lte('date', toDate.toIso8601String());
      }

      final response = await queryBuilder
          .order('date', ascending: false)
          .range(offset, pageSize + offset - 1)
          .count(CountOption.exact);

      return PaginatedResponse(
        data: response.data.map(DailyTransaction.fromJson).toList(),
        count: response.count,
      );
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  @override
  Future<SalesSummary> getSalesSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      print(startDate);
      print(endDate);
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      print(businessId);
      final response = await _supabaseClient.rpc<PostgrestMap>(
        RPCConstants.getSalesSummary,
        params: {
          'p_business_id': businessId,
          'p_start_date': startDate?.toIso8601String(),
          'p_end_date': endDate?.toIso8601String(),
        },
      ).withConverter(SalesSummary.fromJson);
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
  Future<DailyTransactionSummary> getDailyTransactionSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    print(startDate);
    print(endDate);

    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      print(businessId);
      final response = await _supabaseClient.rpc<PostgrestMap>(
        RPCConstants.getDailyTransactionSummary,
        params: {
          'p_business_id': businessId,
          'p_start_date': startDate?.toIso8601String(),
          'p_end_date': endDate?.toIso8601String(),
        },
      ).withConverter(DailyTransactionSummary.fromJson);
      print(response.toJson());
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
  Future<PurchaseSummary> getPurchaseSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      final response = await _supabaseClient.rpc<PostgrestMap>(
        RPCConstants.getPurchaseSummary,
        params: {
          'p_business_id': businessId,
          'p_start_date': startDate?.toIso8601String(),
          'p_end_date': endDate?.toIso8601String(),
        },
      ).withConverter(PurchaseSummary.fromJson);
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
  Future<TotalDuesSummary> getTotalDuesSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      final response = await _supabaseClient.rpc<PostgrestMap>(
        RPCConstants.getTotalDuesSummary,
        params: {
          'p_business_id': businessId,
          'p_start_date': startDate?.toIso8601String(),
          'p_end_date': endDate?.toIso8601String(),
        },
      ).withConverter(TotalDuesSummary.fromJson);
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
  Future<List<EmployeeSales>> getEmployeeSalesReport({
    required int pageSize,
    required int pageNumber,
    String query = '',
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      final response = await _supabaseClient.rpc<PostgrestList>(
        RPCConstants.getEmployeeSalesReport,
        params: {
          'start_date': fromDate?.toIso8601String(),
          'end_date': toDate?.toIso8601String(),
          'page_number': pageNumber,
          'page_size': pageSize,
          'employee_name_filter': query,
          'p_business_id': businessId,
        },
      ).withConverter((data) => data.map(EmployeeSales.fromJson).toList());

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
  Future<EmployeeSalesSummary> getEmployeeSalesSummary({
    required int pageSize,
    required int pageNumber,
    String query = '',
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      final response = await _supabaseClient.rpc<PostgrestMap>(
        RPCConstants.getEmployeeSalesSummary,
        params: {
          'page_number': pageNumber,
          'page_size': pageSize,
          'p_business_id': businessId,
          'start_date': fromDate?.toIso8601String(),
          'end_date': toDate?.toIso8601String(),
          'employee_name_filter': query,
        },
      ).withConverter(EmployeeSalesSummary.fromJson);
      return response;
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }
}
