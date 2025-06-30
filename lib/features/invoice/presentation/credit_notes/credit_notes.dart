import 'package:duxbe/features/invoice/invoice.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'credit_notes_mobile.dart';
export 'credit_notes_web.dart';

class CreditNotesScreen extends ConsumerWidget {
  const CreditNotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: ResponsiveWidget(
        smallScreen: CreditNotesScreenMobile(),
        largeScreen: CreditNotesScreenWeb(),
      ),
    );
  }
}
