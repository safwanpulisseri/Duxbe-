import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'sale_return_list_mobile.dart';
export 'sale_return_list_web.dart';

class SaleReturnListScreen extends ConsumerWidget {
  const SaleReturnListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: ResponsiveWidget(
        smallScreen: SaleReturnListScreenMobile(),
        largeScreen: SaleReturnListScreenWeb(),
      ),
    );
  }
}
