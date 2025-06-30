import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';

export 'sale_return_details_mobile.dart';
export 'sale_return_details_web.dart';

class SaleReturnDetailsScreen extends ConsumerWidget {
  const SaleReturnDetailsScreen({super.key, this.saleId});
  final String? saleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBgColor,
      body: ref.watch(saleProvider(saleId)).when(
            data: (sale) => ResponsiveWidget(
              smallScreen: SaleReturnDetailsScreenMobile(sale: sale),
              largeScreen: SaleReturnDetailsScreenWeb(sale: sale),
            ),
            error: (error, stackTrace) => Center(child: Text(error.toString())),
            loading: Loader.new,
          ),
    );
  }
}
