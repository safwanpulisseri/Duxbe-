import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'expense_category_mobile.dart';
export 'expense_category_web.dart';

class ExpenseCategoryScreen extends ConsumerWidget {
  const ExpenseCategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: ResponsiveWidget(
        smallScreen: ExpenseCategoryScreenMobile(),
        largeScreen: ExpenseCategoryScreenWeb(),
      ),
    );
  }
}
