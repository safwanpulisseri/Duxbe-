import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'unit_list_mobile.dart';
export 'unit_list_web.dart';

class UnitListScreen extends ConsumerWidget {
  const UnitListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: ResponsiveWidget(
        smallScreen: UnitListScreenMobile(),
        largeScreen: UnitListScreenWeb(),
      ),
    );
  }
}
