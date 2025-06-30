import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'sale_return_view_mobile.dart';
export 'sale_return_view_web.dart';

class SaleReturnViewScreen extends ConsumerWidget {
  const SaleReturnViewScreen({super.key, this.saleReturnId});
  final String? saleReturnId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ref.watch(saleReturnProvider(saleReturnId)).when(
            data: (saleReturn) => saleReturn == null
                ? Center(child: Text(context.l10n.saleNotFound))
                : ResponsiveWidget(
                    smallScreen: SaleReturnViewScreenMobile(saleReturn: saleReturn),
                    largeScreen: SaleReturnViewScreenWeb(saleReturn: saleReturn),
                  ),
            error: (error, stackTrace) => Center(child: Text(error.toString())),
            loading: Loader.new,
          ),
    );
  }
}
