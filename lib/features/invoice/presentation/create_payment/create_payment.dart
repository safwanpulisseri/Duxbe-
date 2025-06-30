import 'package:duxbe/features/invoice/invoice.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'create_payment_mobile.dart';
export 'create_payment_web.dart';

class CreatePaymentScreen extends ConsumerWidget {
  const CreatePaymentScreen({super.key, this.paymentId, this.isUpdate});
  final String? paymentId;
  final String? isUpdate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(invoiceDataProvider(paymentId)).when(
          data: (invoice) => ResponsiveWidget(
            smallScreen: const CreatePaymentScreenMobile(),
            largeScreen: CreatePaymentScreenWeb(
              invoice: invoice,
              isUpdate: isUpdate,
            ),
          ),
          error: (error, stackTrace) => Center(child: Text(error.toString())),
          loading: Loader.new,
        );
  }
}
