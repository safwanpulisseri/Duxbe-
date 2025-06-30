import 'dart:typed_data';

import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'customer_repository.g.dart';

@Riverpod(keepAlive: true)
ICustomerRepository customerRepo(CustomerRepoRef ref) => CustomerRepository(ref);

class CustomerRepository implements ICustomerRepository {
  CustomerRepository(this.ref) : _supabaseClient = ref.watch(supabaseProvider);
  final CustomerRepoRef ref;
  final SupabaseClient _supabaseClient;

  @override
  Future<void> deleteCustomer(String customerId) async {
    try {
      return await _supabaseClient.rpc(
        RPCConstants.archiveCustomer,
        params: {
          'p_customer_id': customerId,
          'p_business_id': ref.read(businessNotifierProvider)!.businessId,
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
  Future<Customer?> getCustomerWithId({required String customerId}) async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;

      return await _supabaseClient
          .from(DbConstants.businessCustomerView)
          .select()
          .eq('customer_id', customerId)
          .eq('business_id', businessId)
          .single()
          .withConverter(Customer.fromJson);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<PaginatedResponse<Customer>> getCustomers({
    required int pageSize,
    required int pageNumber,
    String query = '',
  }) async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      final offset = (pageNumber - 1) * pageSize;
      final queryFiltered = query.replaceAll(RegExp('[^a-zA-Z0-9-]'), '');
      final response = await _supabaseClient
          .from(DbConstants.businessCustomerView)
          .select()
          .or('name.ilike.%$queryFiltered%,email.ilike.%$queryFiltered%,phone.ilike.%$queryFiltered%')
          .eq('business_id', businessId)
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .range(offset, pageSize + offset - 1)
          .count(CountOption.exact);
      return PaginatedResponse(
        data: response.data.map(Customer.fromJson).toList(),
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
  Future<Customer> upsertCustomer(Customer customer, {dynamic image}) async {
    try {
      final business = ref.read(businessNotifierProvider);
      String? url;
      if (image is Uint8List) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
        url = await ref.read(supabaseStorageProvider).uploadImage(
              businessId: business!.businessId,
              fileName: fileName,
              filePath: 'customer',
              file: image,
            );
      }

      return await _supabaseClient.functions
          .invoke(
        'employees/create-customer',
        body: customer
            .copyWith(
              businessId: business!.businessId,
              image: url,
              phone: customer.phone?.replaceAll('+', ''),
            )
            .toJson()
          ..addAll({
            'org_id': business.orgId,
          }),
      )
          .then((value) {
        // ignore: avoid_dynamic_calls
        return customer.copyWith(customerId: value.data['customer_id'] as String);
      });
    } on PostgrestException catch (e) {
      debugPrint(e.message);
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    } on FunctionException catch (e) {
      debugPrint(e.details?['error'].toString());
      debugPrint(e.details?['details'].toString());
      throw AppException(
        e.details?['error'].toString() ?? 'Something went wrong',
        code: e.status,
        details: e.details['details']?.toString(),
      );
    }
  }
}
