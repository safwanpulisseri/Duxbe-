import 'package:duxbe/features/sale/sale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SaleReturnViewScreenMobile extends ConsumerStatefulWidget {
  const SaleReturnViewScreenMobile({required this.saleReturn, super.key});
  final SaleReturn saleReturn;

  @override
  ConsumerState<SaleReturnViewScreenMobile> createState() => _SaleReturnViewScreenMobileState();
}

class _SaleReturnViewScreenMobileState extends ConsumerState<SaleReturnViewScreenMobile> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
