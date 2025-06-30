import 'package:duxbe/features/invoice/invoice.dart';
import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hancod_theme/alert.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_invoice_notifier.freezed.dart';
part 'create_invoice_notifier.g.dart';
part 'create_invoice_state.dart';

@Riverpod(keepAlive: false)
class CreateInvoiceNotifier extends _$CreateInvoiceNotifier {
  @override
  CreateInvoiceState build() {
    return CreateInvoiceState.initial();
  }

  void setCustomer({required Customer customer}) {
    state = state.copyWith(customer: customer);
  }

  void setAddress({required CustomerAddress address, required String type}) {
    if (type == 'billing') {
      state = state.copyWith(billingAddress: address);
    } else {
      state = state.copyWith(shippingAddress: address);
    }
  }

  Future<List<CustomerAddress>> getCustomerAddresses({required String customerId}) async {
    try {
      final addresses = await ref.read(quoteRepoProvider).getCustomerAddresses(
            customerId: customerId,
          );
      return addresses;
    } catch (e) {
      return [];
    }
  }

  Future<void> insertNewInvoice({required Map<String, dynamic> invoice}) async {
    try {
      await ref.read(invoicesRepoProvider).createInvoice(invoice);
      Alert.showSnackBar(
        '${AppRouter.l10n.invoice} ${AppRouter.l10n.created} ${AppRouter.l10n.successfully}',
        type: SnackBarType.success,
      );
      ref.read(invoiceNotifierProvider.notifier).setFilter();
      AppRouter.pop();
    } catch (e) {
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  void reset() {
    state = CreateInvoiceState.initial();
  }

  Future<CustomerAddress> insertNewAddress({
    required CustomerAddress address,
    required String customerId,
    required String type,
  }) async {
    try {
      state = state.copyWith(status: CreateInvoiceStatus.loading);
      final newaddress = await ref.read(quoteRepoProvider).insertNewAddress(address: address, customerId: customerId);
      if (type == 'billing') {
        state = state.copyWith(
          status: CreateInvoiceStatus.success,
          billingAddress: newaddress,
        );
      } else {
        state = state.copyWith(
          status: CreateInvoiceStatus.success,
          shippingAddress: newaddress,
        );
      }
      print(newaddress.customerAddressesId);
      Alert.showSnackBar(
        AppRouter.l10n.updatedSuccessfully,
        type: SnackBarType.success,
      );
      return newaddress;
    } on AppException catch (e) {
      state = state.copyWith(
        status: CreateInvoiceStatus.error,
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    } catch (e) {
      state = state.copyWith(
        status: CreateInvoiceStatus.error,
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<void> updateInvoice({
    required Map<String, dynamic> invoice,
    required String invoiceId,
  }) async {
    try {
      state = state.copyWith(status: CreateInvoiceStatus.loading);
      await ref.read(invoicesRepoProvider).updateInvoice(invoice: invoice, invoiceId: invoiceId);
      ref.read(invoiceNotifierProvider.notifier).setFilter();
      AppRouter.pop();
      Alert.showSnackBar(
        AppRouter.l10n.updatedSuccessfully,
        type: SnackBarType.success,
      );
    } catch (e) {
      state = state.copyWith(status: CreateInvoiceStatus.error);
      print(e);
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
    }
  }
}
