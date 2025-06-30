import 'package:duxbe/features/invoice/invoice.dart';
import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/shared/utils/alert.dart';
import 'package:duxbe/shared/utils/router.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hancod_theme/alert.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_quote_notifier.freezed.dart';
part 'create_quote_notifier.g.dart';
part 'create_quote_state.dart';

@Riverpod(keepAlive: false)
Future<Quote?> editQuote(
  EditQuoteRef ref,
  String? quoteId,
) async =>
    quoteId == null ? null : ref.watch(quoteRepoProvider).getQuoteWithId(quoteId: quoteId);

@Riverpod(keepAlive: false)
class CreateQuoteNotifier extends _$CreateQuoteNotifier {
  @override
  CreateQuoteState build() {
    return CreateQuoteState.initial();
  }

  void setCustomer({required Customer customer}) {
    state = state.copyWith(customer: customer);
  }

  Future<Quote?> getQuoteWithId(String quoteId) async {
    try {
      final quote = await ref.read(quoteRepoProvider).getQuoteWithId(quoteId: quoteId);
      state = state.copyWith(editQuoteData: quote);
      return quote;
    } catch (e) {
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  void setAddress({required CustomerAddress address, required String type}) {
    if (type == 'billing') {
      state = state.copyWith(billingAddress: address);
    } else {
      state = state.copyWith(shippingAddress: address);
    }
  }

  void setEditQuoteData({required Quote quote}) {
    state = state.copyWith(editQuoteData: quote);
  }

  Future<void> insertNewQuote({required Map<String, dynamic> quote}) async {
    try {
      state = state.copyWith(status: CreateQuoteStatus.loading);
      await ref.read(quoteRepoProvider).insertNewQuote(quote: quote);
      state = state.copyWith(status: CreateQuoteStatus.success);
      ref.read(quoteNotifierProvider.notifier).setFilter();
      AppRouter.pop();
      Alert.showSnackBar(
        AppRouter.l10n.quoteCreatedSuccessfully,
        type: SnackBarType.success,
      );
    } catch (e) {
      state = state.copyWith(status: CreateQuoteStatus.error);
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
    }
  }

  Future<void> updateQuote({
    required Map<String, dynamic> quote,
    required String quoteId,
  }) async {
    try {
      state = state.copyWith(status: CreateQuoteStatus.loading);
      await ref.read(quoteRepoProvider).updateQuote(quote: quote, quoteId: quoteId);
      state = state.copyWith(status: CreateQuoteStatus.success);
      ref.read(quoteNotifierProvider.notifier).setFilter();
      AppRouter.pop();
      Alert.showSnackBar(
        '${AppRouter.l10n.quote} ${AppRouter.l10n.updatedSuccessfully}',
        type: SnackBarType.success,
      );
    } catch (e) {
      print(e);
      state = state.copyWith(status: CreateQuoteStatus.error);
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
    }
  }

  Future<List<CustomerAddress>> getCustomerAddresses({
    required String customerId,
  }) async {
    try {
      final addresses = await ref.read(quoteRepoProvider).getCustomerAddresses(customerId: customerId);
      return addresses;
    } catch (e) {
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  void reset() {
    state = CreateQuoteState.initial();
  }
}
