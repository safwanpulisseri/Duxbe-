import 'package:duxbe/features/purchase/purchase.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';

export 'purchase_return_details_mobile.dart';
export 'purchase_return_details_web.dart';

class PurchaseReturnDetailsScreen extends ConsumerWidget {
  const PurchaseReturnDetailsScreen({super.key, this.purchaseId});
  final String? purchaseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBgColor,
      body: ref.watch(purchaseProvider(purchaseId)).when(
            data: (purchase) => ResponsiveWidget(
              smallScreen: PurchaseReturnDetailsScreenMobile(purchase: purchase),
              largeScreen: PurchaseReturnDetailsScreenWeb(purchase: purchase),
            ),
            error: (error, stackTrace) => Center(child: Text(error.toString())),
            loading: Loader.new,
          ),
    );
  }
}
