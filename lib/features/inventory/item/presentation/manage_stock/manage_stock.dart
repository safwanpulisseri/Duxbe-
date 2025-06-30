import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'manage_stock_mobile.dart';
export 'manage_stock_web.dart';

class ManageStockScreen extends ConsumerWidget {
  const ManageStockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: ResponsiveWidget(
        smallScreen: ManageStockScreenMobile(),
        largeScreen: ManageStockScreenWeb(),
      ),
    );
  }
}
