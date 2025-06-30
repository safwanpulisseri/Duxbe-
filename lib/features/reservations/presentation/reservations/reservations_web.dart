import 'package:duxbe/features/reservations/presentation/reservations/widget/add_reservation.dart';

/// A web-specific screen for managing restaurant reservations.
///
/// This widget provides a comprehensive interface for:
/// * Viewing and filtering existing reservations
/// * Adding new reservations
/// * Selecting date ranges for reservation viewing
/// * Viewing table availability by time slot
///
/// Features:
/// * Custom date picker for date selection
/// * Search functionality for finding specific reservations
/// * Status filtering (All, Reserved, Waiting list)
/// * Table view option to see table availability
/// * Data table with sortable columns for reservation management
import 'package:duxbe/features/reservations/reservations.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:duxbe/shared/widgets/date_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide DropdownButton, Table;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

/// A web-specific screen for managing restaurant reservations.
class ReservationsScreenWeb extends ConsumerStatefulWidget {
  const ReservationsScreenWeb({super.key});

  @override
  ConsumerState<ReservationsScreenWeb> createState() => _ReservationsScreenWebState();
}

/// The state class for [ReservationsScreenWeb].
///
/// Manages:
/// * Reservation data loading and filtering
/// * Date selection
/// * Search functionality
/// * Table view navigation
class _ReservationsScreenWebState extends ConsumerState<ReservationsScreenWeb> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final reservationsNotifer = ref.watch(reservationNotifierProvider.notifier);
    final reservationsState = ref.watch(reservationNotifierProvider);
    return ColoredBox(
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomDatePicker(
            onDateSelected: (date) {
              reservationsNotifer.getTableReservations(date: date);
            },
          ),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              text: 'Selected Date: ',
              style: AppText.n20.copyWith(color: AppColors.black),
              children: [
                TextSpan(
                  text: '${reservationsState.date?.toDateOnly}',
                  style: AppText.b32.copyWith(color: AppColors.black),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: AppTextForm<String>(
                  name: 'Search',
                  hintText: context.l10n.search,
                  onChanged: (value) {
                    reservationsNotifer.getTableReservations(search: value);
                  },
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 200,
                child: AppDropDownForm<String?>(
                  name: 'status',
                  label: null,
                  items: const [
                    DropDownItems(child: Text('All')),
                    DropDownItems(value: 'reserved', child: Text('Reserved')),
                    DropDownItems(value: 'waiting', child: Text('Waiting list')),
                  ],
                  onClear: () {
                    reservationsNotifer.getTableReservations(status: null);
                  },
                  onChanged: (p0) {
                    reservationsNotifer.getTableReservations(status: p0);
                  },
                ),
              ),
              const SizedBox(width: 10),
              AppButton(
                style: ButtonStyles.secondary,
                onPress: () {
                  showDialog<bool>(
                    context: context,
                    useRootNavigator: false,
                    builder: (context) => const ChooseSlotDialog(),
                  );
                },
                label: Text(AppRouter.l10n.showTables),
              ),
              const SizedBox(width: 10),
              AppButton(
                onPress: () {
                  showDialog<bool>(
                    context: context,
                    useRootNavigator: false,
                    builder: (context) => const AddReservationDialog(),
                  ).then((value) {
                    if (context.mounted && value != null) {
                      reservationsNotifer.getTableReservations(date: reservationsState.date);
                    }
                  });
                },
                label: Text(AppRouter.l10n.addNewReservations),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              text: 'Reservations',
              style: AppText.sb24,
              children: [
                TextSpan(
                  text: ' (${reservationsState.tables.length})',
                  style: AppText.sb24.copyWith(color: AppColors.secondaryColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: PlutoGrid(
              mode: PlutoGridMode.readOnly,
              columns: reservationsNotifer.columns,
              // ignore: prefer_const_literals_to_create_immutables
              rows: [],
              noRowsWidget: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    Assets.images.duxbeLogo.image(height: 300),
                    const SizedBox(height: 16),
                    Text(
                      'No reservations at the moment. Keep an eye here for upcoming bookings.',
                      style: AppText.mediumB.copyWith(color: AppColors.black),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              onLoaded: (PlutoGridOnLoadedEvent event) {
                reservationsNotifer.setStateManager(event.stateManager);
              },
              configuration: AppStylesX.dataTableConfig,
            ),
          ),
        ],
      ),
    );
  }
}

/// A dialog for selecting time slots to view table availability.
///
/// This dialog allows users to:
/// * View available time slots for the selected date
/// * Select a time slot to see table availability
/// * Navigate to the table selection screen for the chosen slot
class ChooseSlotDialog extends ConsumerStatefulWidget {
  const ChooseSlotDialog({super.key});

  @override
  ConsumerState<ChooseSlotDialog> createState() => _ChooseSlotDialogState();
}

/// The state class for [ChooseSlotDialog].
///
/// Manages:
/// * Time slot selection
/// * Navigation to table view
class _ChooseSlotDialogState extends ConsumerState<ChooseSlotDialog> {
  /// The currently selected time slot.
  Slot? selectedSpot;
  @override
  Widget build(BuildContext context) {
    final reservationsState = ref.watch(reservationNotifierProvider);

    return CommonDialog(
      title: AppRouter.l10n.chooseSlot,
      children: [
        Text(
          AppRouter.l10n.timeSlotAvailable,
          style: AppText.n20.copyWith(color: AppColors.grey),
        ),
        const SizedBox(height: 12),
        ref.watch(availableSpotsProvider(reservationsState.date)).when(
              loading: () => const Center(child: CupertinoActivityIndicator()),
              error: (error, stackTrace) => Text(error.toString()),
              data: (data) {
                if (data?.slots.isEmpty ?? true) {
                  return Center(child: Text(context.l10n.noSlotsAvailable));
                }

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineGrey),
                  ),
                  clipBehavior: Clip.antiAlias, // This ensures the grid items don't overflow the rounded corners
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: data!.slots.length,
                    itemBuilder: (context, index) {
                      final spot = data.slots[index];
                      final isSelected = spot == selectedSpot;
                      return InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          setState(() {
                            selectedSpot = spot;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 0.5,
                              color: AppColors.outlineGrey,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${spot.time} - ${spot.endTime}',
                            style: AppText.n20.copyWith(
                              color: isSelected ? AppColors.primaryColor : AppColors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      ],
      onPositive: (ref) {
        if (selectedSpot == null) {
          Alert.showSnackBar('Please select a slot', type: SnackBarType.warning);
          return;
        }
        context.pushNamed(
          AppRouter.chooseReservationTable,
          queryParameters: {
            'date': reservationsState.date!.toApiDateFormat,
            'time': selectedSpot!.time,
            'party_size': '0',
            'return': 'false',
            'view_only': 'true',
          },
        );
      },
    );
  }
}
