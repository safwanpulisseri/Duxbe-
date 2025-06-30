import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'single_stock_adjust_mobile.dart';
export 'single_stock_adjust_web.dart';

class SingleStockAdjustScreen extends ConsumerWidget {
  const SingleStockAdjustScreen({this.itemId, super.key});
  final String? itemId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ref.watch(itemProvider(itemId)).when(
            data: (item) => ResponsiveWidget(
              smallScreen: SingleStockAdjustScreenMobile(item: item),
              largeScreen: SingleStockAdjustScreenWeb(item: item),
            ),
            error: (error, stackTrace) => Center(child: Text(error.toString())),
            loading: Loader.new,
          ),
    );
  }
}
