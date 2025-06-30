import 'dart:convert';
import 'dart:developer';

import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'sale_repository.g.dart';

@Riverpod(keepAlive: true)
ISaleRepository saleRepo(SaleRepoRef ref) => SaleRepository(ref);

class SaleRepository implements ISaleRepository {
  SaleRepository(this.ref) : _supabaseClient = ref.watch(supabaseProvider);
  final SaleRepoRef ref;
  final SupabaseClient _supabaseClient;

  @override
  Future<SaleView> createSaleTransaction(SalePageData data) async {
    try {
      final business = ref.read(businessNotifierProvider);
      log(
        JsonEncoder.withIndent(' ' * 2).convert(
          data
              .copyWith(
                businessId: business!.businessId,
              )
              .toCreateModel()
              .toJson(),
        ),
      );
      return await _supabaseClient.rpc<Map<String, dynamic>>(
        RPCConstants.createSale,
        params: {
          'p_sale_json': data
              .copyWith(
                businessId: business.businessId,
              )
              .toCreateModel()
              .toJson()
            ..addAll({
              'org_id': business.orgId,
            }),
        },
      ).then(SaleView.fromJson);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<void> deleteSaleTransaction(String saleId) {
    throw UnimplementedError();
  }

  @override
  Future<SaleView?> getSaleWithId({required String saleId}) async {
    try {
      return await _supabaseClient
          .from(DbConstants.saleView)
          .select()
          .eq('sale_id', saleId)
          .single()
          .withConverter(SaleView.fromJson);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<List<SaleView>> getDueSalesWithCustomerId({required String customerId, String query = ''}) async {
    try {
      return await _supabaseClient
          .from(DbConstants.saleView)
          .select()
          .eq('customer_id', customerId)
          .gt('due_amount', 0)
          .ilike('sale_invoice', '%$query%')
          .order('created_at', ascending: false)
          .limit(100)
          .withConverter((data) => data.map(SaleView.fromJson).toList());
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<PaginatedResponse<SaleView>> getSales({
    required int pageSize,
    required int pageNumber,
    String query = '',
    bool? orderMode,
    String? customerId,
    bool? paidOrDueList,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final businessId = ref.read(businessNotifierProvider)?.businessId;
      print(businessId);
      if (businessId == null) return PaginatedResponse.empty();
      final offset = (pageNumber - 1) * pageSize;
      var queryBuilder = _supabaseClient
          .from(DbConstants.saleView)
          .select()
          .or('sale_invoice.ilike.%$query%,customer->>name.ilike.%$query%')
          .eq('business_id', businessId);

      if (orderMode != null) queryBuilder = queryBuilder.eq('order_mode', orderMode);
      if (customerId != null) queryBuilder = queryBuilder.eq('customer_id', customerId);
      if (paidOrDueList != null) {
        if (!paidOrDueList) {
          queryBuilder = queryBuilder.gt('due_amount', 0);
        } else {
          queryBuilder = queryBuilder.lte('due_amount', 0);
        }
      }
      if (fromDate != null) {
        queryBuilder = queryBuilder.gte('sale_date', fromDate.toIso8601String());
      }
      if (toDate != null) {
        queryBuilder = queryBuilder.lte('sale_date', toDate.toIso8601String());
      }

      final response =
          await queryBuilder.range(offset, pageSize + offset - 1).order('created_at').count(CountOption.exact);
      return PaginatedResponse(
        data: response.data.map(SaleView.fromJson).toList(),
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
  Future<List<CustomField>> getCustomFields() async {
    try {
      final businessId = ref.read(businessNotifierProvider)?.businessId;
      if (businessId == null) return [];
      final response =
          await _supabaseClient.from(DbConstants.saleCustomFieldDefinitions).select().eq('business_id', businessId);
      return response.map(CustomField.fromJson).toList();
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<void> settleSale({
    required String saleId,
    required double amount,
    required PaymentMode mode,
    required DateTime date,
    required String customerId,
  }) async {
    try {
      await _supabaseClient.rpc<void>(
        RPCConstants.settleSalePayment,
        params: {
          'p_sale_id': saleId,
          'p_amount': amount,
          'p_payment_mode': mode.name,
          'p_payment_date': date.toIso8601String(),
        },
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
  Future<SaleReturn?> getSaleReturnWithId({required String saleReturnId}) async {
    try {
      return await _supabaseClient
          .from(DbConstants.vSaleReturns)
          .select()
          .eq('return_id', saleReturnId)
          .single()
          .withConverter(SaleReturn.fromJson);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<PaginatedResponse<SaleReturn>> getSaleReturns({
    required int pageSize,
    required int pageNumber,
    String query = '',
  }) async {
    try {
      final businessId = ref.read(businessNotifierProvider)?.businessId;
      if (businessId == null) return PaginatedResponse.empty();
      final offset = (pageNumber - 1) * pageSize;
      final response = await _supabaseClient
          .from(DbConstants.vSaleReturns)
          .select()
          .or('return_invoice.ilike.%$query%')
          .eq('business_id', businessId)
          .range(offset, pageSize + offset - 1)
          .count(CountOption.exact);
      return PaginatedResponse(
        data: response.data.map(SaleReturn.fromJson).toList(),
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
  Future<String> getNextSaleReturnCode() async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      final response = await _supabaseClient.rpc<String>(
        RPCConstants.getNextSaleReturnCode,
        params: {'business_id': businessId},
      );
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
  Future<void> createSaleReturnTransaction(CreateSaleReturn data) async {
    try {
      await _supabaseClient.rpc<void>(
        RPCConstants.createSaleReturn,
        params: {'p_data': data.toJson()},
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
  Future<List<SaleAudit>> getSaleAudits(String saleId) async {
    try {
      final response = await _supabaseClient.from(DbConstants.saleAudits).select().eq('sale_id', saleId);
      return response.map(SaleAudit.fromJson).toList();
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<List<Status>> getSaleStatuses() async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      final response =
          await _supabaseClient.from(DbConstants.statuses).select().eq('type', 'sale').eq('business_id', businessId);
      return response.map(Status.fromJson).toList();
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<void> updateSaleStatus(String saleId, String statusId) async {
    try {
      await _supabaseClient.from(DbConstants.sales).update({'status_id': statusId}).eq('sale_id', saleId);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<void> updateSale(SaleView sale, Map<String, dynamic> data) async {
    final business=ref.read(businessNotifierProvider);
    log(JsonEncoder.withIndent(' ' * 2).convert(data));
    log(
      JsonEncoder.withIndent(' ' * 2).convert({
        'p_sale_id': sale.saleId,
        'p_data': {
          'customer_id': sale.customer?.customerId,
          'sale_id': sale.saleId,
          'shipping': data['shipping'],
          'discount_percent': data['discount-percent'],
          'discount_amount': data['discount-amount'],
          'sale_items': (data['items'] as List<Item>)
              .map(
                (item) => {
                  'item_id': item.itemId,
                  'quantity': data['quantity-${item.itemId}'],
                  'unit_price': data['unit-price-${item.itemId}'],
                  'subservices': item.selectedSubServices
                      .map(
                        (service) => {
                          'sub_service_id': service.subServiceId,
                          'additional_price': service.additionalPrice,
                          'quantity': service.quantity,
                        },
                      )
                      .toList(),
                },
              )
              .toList(),
          'business_id': sale.businessId,
          'transaction_id': sale.transactionId,
          'tax_total': data['tax_total'],
          'subtotal': data['subtotal'],
          'grand_total': data['grand_total'],
        },
      }),
    );
    try {
      await _supabaseClient.rpc<void>(
        RPCConstants.updateSale,
        params: {
          'p_sale_json': {
            'customer_id': sale.customer?.customerId,
            'sale_id': sale.saleId,
            'shipping': data['shipping'],
            'discount_percent': data['discount-percent'],
            'discount_amount': data['discount-amount'],
            'sale_items': (data['items'] as List<Item>)
                .map(
                  (item) => {
                    'item_id': item.itemId,
                    'quantity': data['quantity-${item.itemId}'],
                    'unit_price': data['unit-price-${item.itemId}'],
                    'subservices': item.selectedSubServices
                        .map(
                          (service) => {
                            'sub_service_id': service.subServiceId,
                            'additional_price': service.additionalPrice,
                            'quantity': service.quantity,
                          },
                        )
                        .toList(),
                  },
                )
                .toList(),
            'business_id': sale.businessId,
             'org_id':business?.orgId??'' ,
            'transaction_id': sale.transactionId,
            'tax_total': data['tax_total'],
            'subtotal': data['subtotal'],
            'grand_total': data['grand_total'],
          },
        },
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
  Future<void> updateSaleEmployee(String saleId, String employeeId) async {
    try {
      await _supabaseClient.from(DbConstants.sales).update({'created_by': employeeId}).eq('sale_id', saleId);
    } on PostgrestException catch (e) {
      throw AppException(e.message, code: e.code, details: e.details?.toString());
    }
  }
}
