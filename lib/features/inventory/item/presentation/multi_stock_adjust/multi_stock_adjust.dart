import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'multi_stock_adjust_mobile.dart';
export 'multi_stock_adjust_web.dart';

class MultiStockAdjustScreen extends ConsumerWidget {
  const MultiStockAdjustScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: ResponsiveWidget(
        smallScreen: MultiStockAdjustScreenMobile(),
        largeScreen: MultiStockAdjustScreenWeb(),
      ),
    );
  }
}
