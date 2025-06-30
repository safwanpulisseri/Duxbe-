import 'package:duxbe/features/invoice/invoice.dart';
import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_credit_notifier.freezed.dart';
part 'create_credit_notifier.g.dart';
part 'create_credit_state.dart';

@Riverpod(keepAlive: false)
class CreateCreditNotifier extends _$CreateCreditNotifier {
  @override
  CreateCreditState build() {
    return CreateCreditState.initial();
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

  Future<void> createCredit(Map<String, dynamic> credit) async {
    try {
      state = state.copyWith(status: CreateCreditStatus.loading);
      await ref.read(creditNoteRepoProvider).createCredit(credit);
      state = state.copyWith(status: CreateCreditStatus.success);
      ref.read(creditNoteNotifierProvider.notifier).setFilter();
      AppRouter.pop();
      Alert.showSnackBar(
        '${AppRouter.l10n.creditNote} ${AppRouter.l10n.created} ${AppRouter.l10n.successfully}',
        type: SnackBarType.success,
      );
    } catch (e) {
      state = state.copyWith(status: CreateCreditStatus.error);
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }

  Future<void> editCredit(Map<String, dynamic> credit, String creditId) async {
    try {
      state = state.copyWith(status: CreateCreditStatus.loading);
      await ref.read(creditNoteRepoProvider).editCredit(credit, creditId);
      state = state.copyWith(status: CreateCreditStatus.success);
      ref.read(creditNoteNotifierProvider.notifier).setFilter();
      AppRouter.pop();
      Alert.showSnackBar(
        '${AppRouter.l10n.creditNote} ${AppRouter.l10n.updatedSuccessfully} ',
        type: SnackBarType.success,
      );
    } catch (e) {
      state = state.copyWith(status: CreateCreditStatus.error);
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }
}
