import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'profit_and_loss_mobile.dart';
export 'profit_and_loss_web.dart';

class ProfitAndLossScreen extends ConsumerWidget {
  const ProfitAndLossScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: ResponsiveWidget(
        smallScreen: ProfitAndLossScreenMobile(),
        largeScreen: ProfitAndLossScreenWeb(),
      ),
    );
  }
}
