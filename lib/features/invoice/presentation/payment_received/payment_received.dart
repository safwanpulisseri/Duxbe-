import 'package:duxbe/features/invoice/invoice.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'payment_received_mobile.dart';
export 'payment_received_web.dart';

class PaymentReceivedScreen extends ConsumerWidget {
  const PaymentReceivedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: ResponsiveWidget(
        smallScreen: PaymentReceivedScreenMobile(),
        largeScreen: PaymentReceivedScreenWeb(),
      ),
    );
  }
}
