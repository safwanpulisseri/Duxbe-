import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/shared/shared.dart';

abstract class ICustomerRepository {
  Future<Customer?> getCustomerWithId({required String customerId});
  Future<void> deleteCustomer(String customerId);
  Future<Customer> upsertCustomer(Customer customer, {dynamic image});
  Future<PaginatedResponse<Customer>> getCustomers({
    required int pageSize,
    required int pageNumber,
    String query = '',
  });
}
