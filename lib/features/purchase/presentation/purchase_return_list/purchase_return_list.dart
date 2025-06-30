import 'package:duxbe/features/purchase/purchase.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'purchase_return_list_mobile.dart';
export 'purchase_return_list_web.dart';

class PurchaseReturnListScreen extends ConsumerWidget {
  const PurchaseReturnListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: ResponsiveWidget(
        smallScreen: PurchaseReturnListScreenMobile(),
        largeScreen: PurchaseReturnListScreenWeb(),
      ),
    );
  }
}
