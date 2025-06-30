import 'package:duxbe/features/inventory/inventory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StockAdjustmentViewScreenWeb extends ConsumerStatefulWidget {
  const StockAdjustmentViewScreenWeb({super.key, this.adjustment});

  final StockAdjustments? adjustment;

  @override
  ConsumerState<StockAdjustmentViewScreenWeb> createState() => _StockAdjustmentViewScreenWebState();
}

class _StockAdjustmentViewScreenWebState extends ConsumerState<StockAdjustmentViewScreenWeb> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
