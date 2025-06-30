import 'package:duxbe/features/invoice/invoice.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'credit_note_details_mobile.dart';
export 'credit_note_details_web.dart';

class CreditNoteDetailsScreen extends ConsumerWidget {
  const CreditNoteDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: ResponsiveWidget(
        smallScreen: CreditNoteDetailsScreenMobile(),
        largeScreen: CreditNoteDetailsScreenWeb(),
      ),
    );
  }
}
