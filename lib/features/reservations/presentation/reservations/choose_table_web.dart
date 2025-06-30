import 'package:collection/collection.dart';
import 'package:duxbe/features/reservations/presentation/reservations/widget/add_reservation.dart';
import 'package:duxbe/features/reservations/reservations.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';

/// A web-specific screen for selecting tables for a reservation.
///
/// This widget provides an interactive floor plan view that allows users to:
/// * View available and reserved tables
/// * Select tables for a new reservation
/// * View existing table reservations
/// * Submit table selections
///
/// Features:
/// * Interactive floor plan with zoom and pan
/// * Floor filtering
/// * Table status indicators (available, reserved, available soon)
/// * Selected table list with removal option
/// * Capacity validation against party size
class ChooseTableScreenWeb extends ConsumerStatefulWidget {
  /// Creates a table selection screen.
  ///
  /// Parameters:
  /// * [details]: Reservation details from previous steps
  /// * [returnToPrevious]: Whether to return selected tables to previous screen
  /// * [date]: Reservation date (required if not using details)
  /// * [time]: Reservation time (required if not using details)
  /// * [partySize]: Number of guests (required if not using details)
  /// * [viewOnly]: Whether the screen is in view-only mode
  /// * [currentSlot]: Whether to use the current time slot
  /// * [tables]: Pre-selected tables
  /// * [customerId]: ID of the customer making the reservation
  ///
  /// Either [details] or ([date] and [time]) must be provided unless [currentSlot] is true.
  const ChooseTableScreenWeb({
    this.details,
    this.returnToPrevious,
    this.date,
    this.time,
    this.partySize,
    this.viewOnly = true,
    this.currentSlot = false,
    this.tables,
    this.customerId,
    super.key,
  }) : assert(
          currentSlot == true || ((date != null && time != null) || details != null),
          'date and time must not be null when currentSlot is false',
        );

  /// Reservation details from previous steps.
  final ReservationPageData? details;

  /// Whether to return selected tables to previous screen.
  final bool? returnToPrevious;

  /// Reservation date (required if not using details).
  final String? date;

  /// Reservation time (required if not using details).
  final String? time;

  /// Number of guests (required if not using details).
  final int? partySize;

  /// Whether the screen is in view-only mode.
  final bool viewOnly;

  /// Whether to use the current time slot.
  final bool currentSlot;

  /// Pre-selected tables.
  final List<String>? tables;

  /// ID of the customer making the reservation.
  final String? customerId;

  @override
  ConsumerState<ChooseTableScreenWeb> createState() => _ChooseTableScreenWebState();
}

/// The state class for [ChooseTableScreenWeb].
///
/// Manages:
/// * Table selection state
/// * Time slot determination
/// * Table availability checking
class _ChooseTableScreenWebState extends ConsumerState<ChooseTableScreenWeb> {
  /// Checks if a table will be available soon.
  ///
  /// A table is considered "available soon" if its reservation ends
  /// within the next 10 minutes.
  ///
  /// Parameters:
  /// * [endTimeStr]: The end time of the current reservation in HH:MM format
  ///
  /// Returns true if the table will be available within 10 minutes.
  bool isAvailableSoon(String? endTimeStr, DateTime? date) {
    if (endTimeStr == null) return false;

    // Get current date
    final now = DateTime.now();
    final reservationDate = date ?? now;

    // Parse the HH:MM time into a DateTime for the reservation date
    final endTime = DateTime(
      reservationDate.year,
      reservationDate.month,
      reservationDate.day,
      int.parse(endTimeStr.split(':')[0]),
      int.parse(endTimeStr.split(':')[1]),
    );

    // Calculate the difference
    final difference = endTime.difference(now);

    return difference.inMinutes <= 10 && // Within next 10 minutes
        difference.inMinutes > 0; // In the future
  }

  /// Finds the nearest time slot to a specified time.
  ///
  /// This method is used to find an appropriate slot when the exact
  /// requested time might not be available.
  ///
  /// Parameters:
  /// * [slots]: Available time slots
  /// * [widgetTime]: Target time in HH:MM format
  ///
  /// Returns the nearest slot that starts at or after the target time,
  /// or null if no suitable slot is found.
  Slot? findNearestTimeSlot(List<Slot> slots, String? widgetTime) {
    if (widgetTime == null || slots.isEmpty) return null;

    // Convert widget time to minutes since midnight for easier comparison
    final timeParts = widgetTime.substring(0, 5).split(':');
    final targetMinutes = int.parse(timeParts[0]) * 60 + int.parse(timeParts[1]);

    // Round up to nearest 30 minutes
    final roundedMinutes = ((targetMinutes + 29) ~/ 30) * 30;

    // Find the slot that matches or comes after the rounded time
    return slots.firstWhereOrNull((spot) {
      final spotTimeParts = spot.time.split(':');
      final spotMinutes = int.parse(spotTimeParts[0]) * 60 + int.parse(spotTimeParts[1]);
      return spotMinutes >= roundedMinutes;
    });
  }

  /// Current date and time.
  final now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final tablesState = ref.watch(tableNotifierProvider);
    final tablesNotifer = ref.watch(tableNotifierProvider.notifier);
    final reservationState = ref.watch(reservationNotifierProvider);
    final reservationNotifer = ref.watch(reservationNotifierProvider.notifier);

    final availableProvider = widget.currentSlot
        ? availableSpotsProvider(now, currentSlot: true)
        : availableSpotsProvider(widget.date == null ? null : DateTime.tryParse(widget.date!));
    final slotAsync = ref.watch(availableProvider);

    ref.listen(
      availableProvider,
      (previous, next) {
        if (next.hasError) {
          Alert.showSnackBar(AppRouter.l10n.couldnTFindTheSlot, type: SnackBarType.warning);
        }
        if (next.hasValue) {
          reservationNotifer.resetTables();
          final selectedSlot = widget.currentSlot
              ? next.value?.currentSlot ?? widget.details?.selectedSpot
              : next.value?.slots == null
                  ? widget.details?.selectedSpot
                  : findNearestTimeSlot(next.value!.slots, widget.time);
          for (final tableId in widget.tables!) {
            try {
              final table = selectedSlot?.tables.firstWhere((table) => table.tableId == tableId);
              if (table != null) {
                reservationNotifer.toggleTable(table);
              }
            } catch (e) {
              // Table not found in the current slot
              continue;
            }
          }
        }
      },
    );

    return slotAsync.when(
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (_, __) => Center(child: Text(AppRouter.l10n.couldnTFindTheSlot)),
      data: (data) {
        final selectedSlot = widget.currentSlot
            ? data?.currentSlot ?? widget.details?.selectedSpot
            : data?.slots == null
                ? widget.details?.selectedSpot
                : findNearestTimeSlot(data!.slots, widget.time);

        if (selectedSlot == null) {
          return Center(child: Text(AppRouter.l10n.couldnTFindTheSlot));
        }

        return ColoredBox(
          color: AppColors.secondaryBackgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Wrap(
                  runSpacing: 8,
                  spacing: 8,
                  children: [
                    for (final floor in tablesState.floors)
                      FilterChip(
                        side: BorderSide(
                          color: tablesState.selectedFloor == floor ? AppColors.primaryColor : AppColors.outlineGrey,
                        ),
                        backgroundColor: AppColors.white,
                        selectedColor: const Color(0xffFFF5EE),
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        label: Text(floor.name),
                        selected: tablesState.selectedFloor == floor,
                        onSelected: (selected) {
                          if (selected) {
                            tablesNotifer.changeCurrentFloor(floor);
                          } else {
                            tablesNotifer.changeCurrentFloor(null);
                          }
                        },
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.secondaryBackgroundColor,
                child: Row(
                  children: {
                    'Available': AppColors.blue,
                    'Reserved': AppColors.primaryColor,
                    'Available soon': AppColors.lightPurple,
                  }
                      .entries
                      .map(
                        (e) => Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: e.value,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: e.value.withOpacity(0.2),
                                  width: 4,
                                  strokeAlign: BorderSide.strokeAlignOutside,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              e.key,
                              style: AppText.m26.copyWith(height: 1),
                            ),
                            const SizedBox(width: 20),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
              Expanded(
                child: InteractiveViewer(
                  minScale: 0.1,
                  maxScale: 4,
                  child: Stack(
                    children: [
                      // Position each table here using Positioned or dynamically
                      for (final table
                          in selectedSlot.tables.where((table) => table.floorId == tablesState.selectedFloor?.floorId))
                        Positioned(
                          left: table.position.dx,
                          top: table.position.dy,
                          child: GestureDetector(
                            onPanUpdate: (details) {},
                            onTap: () {
                              if (table.reservation != null && table.reservation?.customerId != widget.customerId ||
                                  widget.viewOnly) {
                                return;
                              }
                              reservationNotifer.toggleTable(table);
                            },
                            child: TableWidget(
                              table: table,
                              onRotate: (turns) => {},
                              isSelected: reservationState.selectedTables.contains(table),
                              availableSoon: isAvailableSoon(
                                selectedSlot.endTime,
                                widget.date == null ? null : DateTime.tryParse(widget.date!),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (!widget.viewOnly)
                Container(
                  height: 100,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff19191C).withOpacity(0.29),
                        blurRadius: 30,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xffF8F9FD),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Assets.icons.barcode.svg(),
                      ),
                      const SizedBox(width: 16),
                      const Center(child: Text('Table', style: AppText.b28)),
                      const VerticalDivider(color: AppColors.outlineGrey, thickness: 2, width: 20),
                      Expanded(
                        child: Wrap(
                          runSpacing: 8,
                          spacing: 8,
                          children: [
                            for (final table in reservationState.selectedTables)
                              Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 10, top: 10),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: AppColors.outlineGrey),
                                      color: AppColors.white,
                                    ),
                                    child: Text(table.name, style: AppText.sb24),
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        reservationNotifer.toggleTable(table);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryColor,
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: const Icon(Icons.close, color: AppColors.white, size: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      AppButton(
                        onPress: () async {
                          // {
                          //     'customer_id': '123e4567-e89b-12d3-a456-426614174000',
                          //     'business_id': '987fcdeb-51k2-12d3-a456-426614174000',
                          //     'reservation_date': '2024-12-20',
                          //     'start_time': '18:00',
                          //     'end_time': '20:00',
                          //     'party_size': 6,
                          //     'table_ids': ['table-uuid-1', 'table-uuid-2'],
                          //     'notes': 'Anniversary dinner',
                          //     'priority': 1
                          // }

                          if (reservationState.selectedTables.isEmpty) {
                            Alert.showSnackBar(AppRouter.l10n.pleaseSelectAtleastOneTable, type: SnackBarType.warning);
                            return;
                          }
                          if (widget.returnToPrevious ?? false) {
                            context.pop(reservationState.selectedTables.toList());
                            return;
                          }

                          // Check if the selected tables have enough capacity for the party size
                          if (reservationState.selectedTables
                                  .fold(0, (previous, current) => previous + current.noOfSeats) <
                              widget.details!.partySize) {
                            Alert.showSnackBar(
                             AppRouter.l10n.selectedTablesAreNotEnoughForTheParty,
                              type: SnackBarType.warning,
                            );
                            return;
                          }

                          await reservationNotifer.createReservation({
                            'customer_id': widget.details!.customer.customerId,
                            'business_id': widget.details!.customer.businessId,
                            'reservation_date': widget.details!.date.toIso8601String(),
                            'start_time': widget.details!.selectedSpot.time,
                            'end_time': widget.details!.selectedSpot.endTime,
                            'party_size': widget.details!.partySize,
                            'table_ids': reservationState.selectedTables.map((table) => table.tableId).toList(),
                            'notes': widget.details!.notes,
                          }).then((_) {
                            if (context.mounted) {
                              reservationNotifer.resetTables();
                              context.pop(true);
                            }
                          });
                        },
                        isLoading: reservationState.status == ReservationStatus.loading,
                        label: Text(context.l10n.submit),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
