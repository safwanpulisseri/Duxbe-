import 'package:duxbe/features/reservations/reservations.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'choose_table_mobile.dart';
export 'choose_table_web.dart';

class ChooseTableScreen extends ConsumerWidget {
  const ChooseTableScreen({
    this.details,
    this.date,
    this.time,
    this.partySize,
    this.returnToPrevious,
    this.viewOnly = true,
    this.currentSlot = false,
    this.tables,
    this.customerId,
    super.key,
  });
  final ReservationPageData? details;
  final String? date;
  final String? time;
  final int? partySize;
  final bool? returnToPrevious;
  final bool viewOnly;
  final bool currentSlot;
  final List<String>? tables;
  final String? customerId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ResponsiveWidget(
        smallScreen: const ChooseTableScreenMobile(),
        largeScreen: ChooseTableScreenWeb(
          details: details,
          date: date,
          time: time,
          partySize: partySize,
          returnToPrevious: returnToPrevious,
          viewOnly: viewOnly,
          currentSlot: currentSlot,
          tables: tables,
          customerId: customerId,
        ),
      ),
    );
  }
}
