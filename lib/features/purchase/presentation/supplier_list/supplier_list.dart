import 'package:duxbe/features/purchase/presentation/purchase_presentation.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'supplier_list_mobile.dart';
export 'supplier_list_web.dart';

class SupplierListScreen extends ConsumerWidget {
  const SupplierListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: ResponsiveWidget(
        smallScreen: SupplierListScreenMobile(),
        largeScreen: SupplierListScreenWeb(),
      ),
    );
  }
}
