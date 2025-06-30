import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'chart_of_accounts_mobile.dart';
export 'chart_of_accounts_web.dart';

class ChartOfAccountsScreen extends ConsumerWidget {
  const ChartOfAccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: ResponsiveWidget(
        smallScreen: ChartOfAccountsScreenMobile(),
        largeScreen: ChartOfAccountsScreenWeb(),
      ),
    );
  }
}
