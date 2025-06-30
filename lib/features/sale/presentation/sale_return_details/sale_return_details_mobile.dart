import 'package:duxbe/features/sale/sale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SaleReturnDetailsScreenMobile extends ConsumerStatefulWidget {
  const SaleReturnDetailsScreenMobile({required this.sale, super.key});
  final SaleView? sale;
  @override
  ConsumerState<SaleReturnDetailsScreenMobile> createState() => _SaleReturnDetailsScreenMobileState();
}

class _SaleReturnDetailsScreenMobileState extends ConsumerState<SaleReturnDetailsScreenMobile> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
