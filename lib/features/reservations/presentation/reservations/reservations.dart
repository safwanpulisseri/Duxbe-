import 'package:duxbe/features/reservations/reservations.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'reservations_mobile.dart';
export 'reservations_web.dart';

class ReservationsScreen extends ConsumerWidget {
  const ReservationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: ResponsiveWidget(
        smallScreen: ReservationsScreenMobile(),
        largeScreen: ReservationsScreenWeb(),
      ),
    );
  }
}
