import 'package:duxbe/features/purchase/presentation/purchase_presentation.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';

export 'purchase_payment_mobile.dart';
export 'purchase_payment_web.dart';

class PurchasePaymentScreen extends ConsumerWidget {
  const PurchasePaymentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      backgroundColor: AppColors.scaffoldBgColor,
      body: ResponsiveWidget(
        smallScreen: PurchasePaymentScreenMobile(),
        largeScreen: PurchasePaymentScreenWeb(),
      ),
    );
  }
}
