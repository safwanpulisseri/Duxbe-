import 'package:duxbe/features/purchase/purchase.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'supplier_details_mobile.dart';
export 'supplier_details_web.dart';

class SupplierDetailsScreen extends ConsumerWidget {
  const SupplierDetailsScreen({super.key, this.supplierId});
  final String? supplierId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ref.watch(supplierProvider(supplierId)).when(
            data: (supplier) => ResponsiveWidget(
              smallScreen: SupplierDetailsScreenMobile(supplier: supplier),
              largeScreen: SupplierDetailsScreenWeb(supplier: supplier),
            ),
            error: (error, stackTrace) => Center(child: Text(error.toString())),
            loading: Loader.new,
          ),
    );
  }
}
