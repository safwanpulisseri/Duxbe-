import 'package:duxbe/features/reservations/presentation/reservations/widget/add_reservation_customer.dart';
import 'package:duxbe/features/reservations/reservations.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:duxbe/shared/widgets/date_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'add_reservation.g.dart';

@Riverpod(keepAlive: false)
Future<AvailableSpots?> availableSpots(AvailableSpotsRef ref, DateTime? date, {bool currentSlot = false}) async =>
    date == null
        ? null
        : currentSlot
            ? ref.watch(reservationRepoProvider).getCurrentTimeSlot(date: date)
            : ref.watch(reservationRepoProvider).getReservations(date: date);

class AddReservationDialog extends ConsumerStatefulWidget {
  const AddReservationDialog({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddReservationDialogState();
}

class _AddReservationDialogState extends ConsumerState<AddReservationDialog> {
  int partySize = 1;
  DateTime date = DateTime.now();
  Slot? selectedSpot;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppRouter.l10n.newReservation, style: AppText.b32.copyWith(color: AppColors.black)),
                    IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.close)),
                  ],
                ),
              ),
              const Divider(color: AppColors.outlineGrey),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(AppRouter.l10n.selectPartySize, style: AppText.n20.copyWith(color: AppColors.grey)),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xffE4E4E4)),
                      ),
                      clipBehavior: Clip.hardEdge,
                      height: 60,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: List.generate(
                          50,
                          (index) {
                            final isSelected = partySize == index + 1;
                            return InkWell(
                              borderRadius: index == 0
                                  ? const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      bottomLeft: Radius.circular(16),
                                    )
                                  : index == 7
                                      ? const BorderRadius.only(
                                          topRight: Radius.circular(16),
                                          bottomRight: Radius.circular(16),
                                        )
                                      : BorderRadius.zero,
                              onTap: () {
                                setState(() {
                                  partySize = index + 1;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.red : Colors.transparent,
                                  border: const Border.symmetric(
                                    vertical: BorderSide(color: Color(0xffE4E4E4), width: .5),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: isSelected ? AppColors.primaryColor : Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomDatePicker(
                      onDateSelected: (date) {
                        setState(() {
                          this.date = date;
                          selectedSpot = null;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(AppRouter.l10n.timeSlotAvailables, style: AppText.n20.copyWith(color: AppColors.grey)),
                    const SizedBox(height: 12),
                    ref.watch(availableSpotsProvider(date)).when(
                          loading: () => const Center(child: CupertinoActivityIndicator()),
                          error: (error, stackTrace) => Text(error.toString()),
                          data: (data) {
                            if (data?.slots.isEmpty ?? true) {
                              return Center(child: Text(AppRouter.l10n.noSlotsAvailable));
                            }

                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.outlineGrey),
                              ),
                              clipBehavior:
                                  Clip.antiAlias, // This ensures the grid items don't overflow the rounded corners
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
                                      final now = DateTime.now();
                                      final slotDateTime = DateTime(
                                        date.year,
                                        date.month,
                                        date.day,
                                        int.parse(spot.time.split(':')[0]),
                                        int.parse(spot.time.split(':')[1]),
                                      );

                                      if (slotDateTime.isBefore(now)) {
                                        Alert.showSnackBar(
                                          'Cannot select a past time slot',
                                          type: SnackBarType.warning,
                                        );
                                        return;
                                      }

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
                ),
              ),
              const SizedBox(height: 12),
              const Divider(color: AppColors.outlineGrey),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: AppButton(
                        style: ButtonStyles.cancel,
                        label: Text(context.l10n.cancel),
                        onPress: () => context.pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: Text(context.l10n.continu),
                        onPress: () {
                          if (selectedSpot == null) {
                            Alert.showSnackBar(AppRouter.l10n.pleaseSelectATimeSlot, type: SnackBarType.error);
                            return;
                          }
                          showDialog<bool>(
                            useRootNavigator: false,
                            context: context,
                            builder: (context) =>
                                AddReservationCustomer(partySize: partySize, date: date, selectedSpot: selectedSpot!),
                          ).then((value) {
                            if (context.mounted && value != null) {
                              context.pop(value);
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
