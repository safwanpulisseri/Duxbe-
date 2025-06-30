import 'package:duxbe/features/invoice/invoice.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'edit_payment_mobile.dart';
export 'edit_payment_web.dart';

class EditPaymentScreen extends ConsumerWidget {
  const EditPaymentScreen({super.key, this.paymentId});
  final String? paymentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(
          paymentReceivedProvider(paymentId),
        )
        .when(
          data: (data) {
            return Scaffold(
              body: ResponsiveWidget(
                smallScreen:const EditPaymentScreenMobile(),
                largeScreen: EditPaymentScreenWeb(payment: data,),
              ),
            );
          },
          error: (error, stackTrace) => Center(child: Text(error.toString())),
          loading: Loader.new,
        );
  }
}
