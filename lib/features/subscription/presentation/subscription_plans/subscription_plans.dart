import 'package:duxbe/features/subscription/subscription.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'subscription_plans_mobile.dart';
export 'subscription_plans_web.dart';

class SubscriptionPlansScreen extends ConsumerWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: ResponsiveWidget(
        smallScreen: SubscriptionPlansScreenMobile(),
        largeScreen: SubscriptionPlansScreenWeb(),
      ),
    );
  }
}
