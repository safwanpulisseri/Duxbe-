import 'package:duxbe/features/purchase/purchase.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'purchase_return_view_mobile.dart';
export 'purchase_return_view_web.dart';

class PurchaseReturnViewScreen extends ConsumerWidget {
  const PurchaseReturnViewScreen ({super.key, this.purchaseReturnId});
  final String? purchaseReturnId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ref.watch(purchaseReturnProvider(purchaseReturnId)).when(
            data: (purchaseReturn) => purchaseReturn == null
                ? Center(child: Text(context.l10n.purchaseNotFound))
                : ResponsiveWidget(
                    smallScreen: PurchaseReturnViewScreenMobile(purchaseReturn: purchaseReturn),
                    largeScreen: PurchaseReturnViewScreenWeb(purchaseReturn: purchaseReturn),
                  ),
            error: (error, stackTrace) => Center(child: Text(error.toString())),
            loading: Loader.new,
          ),
    );
  }
}

