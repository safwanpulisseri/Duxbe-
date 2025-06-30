import 'package:duxbe/features/purchase/purchase.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'purchase_details_mobile.dart';
export 'purchase_details_web.dart';

class PurchaseDetailsScreen extends ConsumerWidget {
  const PurchaseDetailsScreen({super.key, this.purchaseId});
  final String? purchaseId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ref.watch(purchaseProvider(purchaseId)).when(
            data: (purchase) => purchase == null
                ? Center(child: Text(context.l10n.purchaseNotFound))
                : ResponsiveWidget(
                    smallScreen: PurchaseDetailsScreenMobile(purchase: purchase),
                    largeScreen: PurchaseDetailsScreenWeb(purchase: purchase),
                  ),
            error: (error, stackTrace) => Center(child: Text(error.toString())),
            loading: Loader.new,
          ),
    );
  }
}
