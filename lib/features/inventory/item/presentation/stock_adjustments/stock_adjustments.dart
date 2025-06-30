import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'stock_adjustments_mobile.dart';
export 'stock_adjustments_web.dart';

class StockAdjustmentsScreen extends ConsumerWidget {
  const StockAdjustmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: ResponsiveWidget(
        smallScreen: StockAdjustmentsScreenMobile(),
        largeScreen: StockAdjustmentsScreenWeb(),
      ),
    );
  }
}
