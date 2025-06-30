import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'income_category_mobile.dart';
export 'income_category_web.dart';

class IncomeCategoryScreen extends ConsumerWidget {
  const IncomeCategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: ResponsiveWidget(
        smallScreen: IncomeCategoryScreenMobile(),
        largeScreen: IncomeCategoryScreenWeb(),
      ),
    );
  }
}
