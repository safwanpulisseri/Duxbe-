import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'terms_and_conditions_mobile.dart';
export 'terms_and_conditions_web.dart';

class TermsAndConditionsScreen extends ConsumerWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: ResponsiveWidget(
        smallScreen: TermsAndConditionsScreenMobile(),
        largeScreen: TermsAndConditionsScreenWeb(),
      ),
    );
  }
}
