import 'package:duxbe/features/reservations/reservations.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'reservation_tabs_mobile.dart';
export 'reservation_tabs_web.dart';

class ReservationTabsScreen extends ConsumerWidget {
  const ReservationTabsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: ResponsiveWidget(
        smallScreen: ReservationTabsScreenMobile(),
        largeScreen: ReservationTabsScreenWeb(),
      ),
    );
  }
}
