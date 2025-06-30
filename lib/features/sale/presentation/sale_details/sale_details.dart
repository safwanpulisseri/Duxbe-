import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'sale_details_mobile.dart';
export 'sale_details_web.dart';

class SaleDetailsScreen extends ConsumerWidget {
  const SaleDetailsScreen({super.key, this.saleId});
  final String? saleId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ref.watch(saleProvider(saleId)).when(
            data: (sale) => sale == null
                ? Center(child: Text(context.l10n.saleNotFound))
                : ResponsiveWidget(
                    smallScreen: SaleDetailsScreenMobile(sale: sale),
                    largeScreen: SaleDetailsScreenWeb(sale: sale),
                  ),
            error: (error, stackTrace) => Center(child: Text(error.toString())),
            loading: Loader.new,
          ),
    );
  }
}
