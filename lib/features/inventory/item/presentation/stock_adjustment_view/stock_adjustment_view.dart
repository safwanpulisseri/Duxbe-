import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';

export 'stock_adjustment_view_mobile.dart';
export 'stock_adjustment_view_web.dart';

class StockAdjustmentViewScreen extends ConsumerWidget {
  const StockAdjustmentViewScreen({super.key, this.adjustmentId});
  final String? adjustmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: ref.watch(stockAdjustmentProvider(adjustmentId)).when(
            data: (adjustment) => ResponsiveWidget(
              smallScreen: StockAdjustmentViewScreenMobile(adjustment: adjustment),
              largeScreen: StockAdjustmentViewScreenWeb(adjustment: adjustment),
            ),
            error: (error, stackTrace) => Center(child: Text(error.toString())),
            loading: Loader.new,
          ),
    );
  }
}
