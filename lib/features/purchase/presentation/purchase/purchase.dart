import 'package:duxbe/features/purchase/purchase.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/colors.dart';

export 'purchase_mobile.dart';
export 'purchase_web.dart';

class PurchaseScreen extends ConsumerWidget {
  const PurchaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      backgroundColor: AppColors.scaffoldBgColor,
      body: ResponsiveWidget(
        smallScreen: PurchaseScreenMobile(),
        largeScreen: PurchaseScreenWeb(),
      ),
    );
  }
}
