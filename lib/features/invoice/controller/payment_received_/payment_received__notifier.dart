import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/invoice/invoice.dart';
import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_received__notifier.freezed.dart';
part 'payment_received__notifier.g.dart';
part 'payment_received__state.dart';

@Riverpod(keepAlive: false)
Future<PaymentReceived?> paymentReceived(
  // ignore: deprecated_member_use_from_same_package
  PaymentReceivedRef ref,
  String? paymentId,
) async =>
    paymentId == null ? null : ref.watch(paymentReceivedRepoProvider).getPaymentReceivedWithId(paymentId: paymentId);

@Riverpod(keepAlive: false)
class PaymentReceivedNotifier extends _$PaymentReceivedNotifier {
  late IPaymentReceivedRepository _paymentReceivedRepository;
  @override
  PaymentReceivedState build() {
    _paymentReceivedRepository = ref.watch(paymentReceivedRepoProvider);
    ref.listen(businessNotifierProvider, (previous, next) {
      // Refresh the paging controller when business changes
      setFilter(pageNumber: 1);
    });

    state = PaymentReceivedState.initial();
    return state.copyWith(
      paymentReceivedPagingController: PagingController<int, PaymentReceived>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener((pageKey) async {
          final paymentReceived = await getPaymentReceived(pageNumber: pageKey);
          final isLastPage = paymentReceived.length < state.pageSize;
          if (isLastPage) {
            state.paymentReceivedPagingController?.appendLastPage(paymentReceived);
          } else {
            state.paymentReceivedPagingController?.appendPage(paymentReceived, pageKey + 1);
          }
        }),
    );
  }

  void setCustomer({Customer? customer}) {
    state = state.copyWith(customer: customer);
  }

  void setFilter({
    String? query,
    int? pageNumber,
    String? selectedPaymentReceivedId,
  }) {
    state = state.copyWith(
      pageNumber: pageNumber ?? state.pageNumber,
      query: query ?? state.query,
      selectedPaymentReceivedId: selectedPaymentReceivedId ?? state.selectedPaymentReceivedId,
    );
    state.paymentReceivedPagingController?.refresh();
  }

  Future<void> createPayment({
    required Map<String, dynamic> paymentReceived,
  }) async {
    try {
      state = state.copyWith(status: PaymentReceivedStatus.loading);
      await ref.read(paymentReceivedRepoProvider).createPayment(paymentReceived);
      state = state.copyWith(status: PaymentReceivedStatus.success);
      setFilter();
      AppRouter.pop();
      Alert.showSnackBar(
        AppRouter.l10n.updatedSuccessfully,
        type: SnackBarType.success,
      );
    } on AppException catch (e) {
      state = state.copyWith(status: PaymentReceivedStatus.error);
      if (e.code == 'P0001') {
        print(e.message);
        Alert.showSnackBar(e.message, type: SnackBarType.error);
      } else {
        Alert.showSnackBar(
          AppRouter.l10n.somethingWentWrongTryRefreshingThePageOrCheckingYourInternetConnectionWeLlSeeYouInAMoment,
          type: SnackBarType.error,
        );
      }
      rethrow;
    }
  }

  Future<void> deleteRefund(String refund) async {
    try {
      state = state.copyWith(status: PaymentReceivedStatus.loading);
      await ref.read(creditNoteRepoProvider).deleteRefund(refund);
      state = state.copyWith(status: PaymentReceivedStatus.success, selectedPaymentReceivedId: null);
      state.paymentReceivedPagingController?.refresh();
      // state.pagingController?.refresh();

      AppRouter.pop();
      Alert.showSnackBar(
        '${AppRouter.l10n.refund} ${AppRouter.l10n.delete} ${AppRouter.l10n.successfully}',
        type: SnackBarType.success,
      );
    } on AppException catch (e) {
      state = state.copyWith(status: PaymentReceivedStatus.error);
      Alert.showSnackBar(e.message, type: SnackBarType.error);
    }
  }

  Future<void> editPaymment(
    String paymentId,
    Map<String, dynamic> paymentReceived,
  ) async {
    try {
      state = state.copyWith(status: PaymentReceivedStatus.loading);
      await ref.read(paymentReceivedRepoProvider).editPayment(paymentId, paymentReceived);
      state = state.copyWith(status: PaymentReceivedStatus.success);
      setFilter();
      AppRouter.pop();
      Alert.showSnackBar(
        '${AppRouter.l10n.payment} ${AppRouter.l10n.created} ${AppRouter.l10n.successfully}',
        type: SnackBarType.success,
      );
    } on AppException catch (e) {
      state = state.copyWith(status: PaymentReceivedStatus.error);
      if (e.code == 'P0001') {
        print(e.message);
        Alert.showSnackBar(e.message, type: SnackBarType.error);
      } else {
        Alert.showSnackBar(
          AppRouter.l10n.somethingWentWrongTryRefreshingThePageOrCheckingYourInternetConnectionWeLlSeeYouInAMoment,
          type: SnackBarType.error,
        );
      }
      rethrow;
    }
  }

  Future<void> deletePaymment(String paymentId) async {
    try {
      state = state.copyWith(status: PaymentReceivedStatus.loading);
      await ref.read(paymentReceivedRepoProvider).deletePayment(
            paymentId,
          );
      state = state.copyWith(status: PaymentReceivedStatus.success);
      setFilter(selectedPaymentReceivedId: '');
      AppRouter.pop();
      Alert.showSnackBar(
        '${AppRouter.l10n.payment} ${AppRouter.l10n.delete} ${AppRouter.l10n.successfully}',
        type: SnackBarType.success,
      );
    } on AppException catch (e) {
      state = state.copyWith(status: PaymentReceivedStatus.error);
      if (e.code == 'P0001') {
        Alert.showSnackBar(e.message, type: SnackBarType.error);
      } else {
        Alert.showSnackBar(
          AppRouter.l10n.somethingWentWrongTryRefreshingThePageOrCheckingYourInternetConnectionWeLlSeeYouInAMoment,
          type: SnackBarType.error,
        );
      }
      rethrow;
    }
  }

  Future<List<PaymentReceived>> getPaymentReceived({
    String? query,
    int? pageNumber,
    int? pageSize,
  }) async {
    try {
      final paymentReceived = await _paymentReceivedRepository.getPaymentReceived(
        query: query ?? state.query ?? '',
        pageNumber: pageNumber ?? state.pageNumber,
        pageSize: pageSize ?? state.pageSize,
      );
      return paymentReceived.data;
    } catch (e) {
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }
}
