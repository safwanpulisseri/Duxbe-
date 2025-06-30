import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'sale_list_mobile.dart';
export 'sale_list_web.dart';

class SaleListScreen extends ConsumerWidget {
  const SaleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const ResponsiveWidget(
      smallScreen: SaleListScreenMobile(),
      largeScreen: SaleListScreenWeb(),
    );
  }
}
