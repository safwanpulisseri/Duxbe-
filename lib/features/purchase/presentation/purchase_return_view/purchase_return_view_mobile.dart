import 'package:duxbe/features/purchase/purchase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PurchaseReturnViewScreenMobile extends ConsumerStatefulWidget {
  const PurchaseReturnViewScreenMobile({required this.purchaseReturn, super.key});
  final PurchaseReturn purchaseReturn;
  @override
  ConsumerState<PurchaseReturnViewScreenMobile> createState() => _PurchaseReturnViewScreenMobileState();
}

class _PurchaseReturnViewScreenMobileState extends ConsumerState<PurchaseReturnViewScreenMobile> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
