import 'package:duxbe/features/invoice/presentation/quote_details/quote_details.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'quote_details_mobile.dart';
export 'quote_details_web.dart';

class QuoteDetailsScreen extends ConsumerWidget {
  const QuoteDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: ResponsiveWidget(
        smallScreen: QuoteDetailsScreenMobile(),
        largeScreen: QuoteDetailsScreenWeb(),
      ),
    );
  }
}
