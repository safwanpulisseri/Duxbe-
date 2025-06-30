import 'package:duxbe/features/invoice/invoice.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'payment_refund_mobile.dart';
export 'payment_refund_web.dart';

class PaymentRefundScreen extends ConsumerWidget {
  const PaymentRefundScreen({super.key, this.paymentReceivedId, this.sourceCreditId});
  final String? paymentReceivedId;
  final String? sourceCreditId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveWidget(
      smallScreen: const PaymentRefundScreenMobile(),
      largeScreen: PaymentRefundScreenWeb(
        sourceId: paymentReceivedId,
        creditSourceId: sourceCreditId,
      ),
    );
    // ref.watch(paymentReceivedProvider(paymentReceivedId)).when(
    //       data: (paymentReceived) => ResponsiveWidget(
    //         smallScreen: const PaymentRefundScreenMobile(),
    //         largeScreen:
    //             PaymentRefundScreenWeb(paymentReceived: paymentReceived),
    //       ),
    //       error: (error, stackTrace) => Center(child: Text(error.toString())),
    //       loading: Loader.new,
    //     );
  }
}
