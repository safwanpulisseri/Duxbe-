import 'package:duxbe/features/purchase/purchase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PurchaseReturnDetailsScreenMobile extends ConsumerStatefulWidget {
  const PurchaseReturnDetailsScreenMobile({super.key, this.purchase});
  final PurchaseView? purchase;
  @override
  ConsumerState<PurchaseReturnDetailsScreenMobile> createState() => _PurchaseReturnDetailsScreenMobileState();
}

class _PurchaseReturnDetailsScreenMobileState extends ConsumerState<PurchaseReturnDetailsScreenMobile> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
