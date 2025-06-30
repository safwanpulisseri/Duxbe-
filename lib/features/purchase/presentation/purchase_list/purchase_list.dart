import 'package:duxbe/features/purchase/purchase.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'purchase_list_mobile.dart';
export 'purchase_list_web.dart';

class PurchaseListScreen extends ConsumerWidget {
  const PurchaseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: ResponsiveWidget(
        smallScreen: PurchaseListScreenMobile(),
        largeScreen: PurchaseListScreenWeb(),
      ),
    );
  }
}
