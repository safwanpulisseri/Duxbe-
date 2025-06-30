import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart' hide DropdownButton;
import 'package:hancod_theme/hancod_theme.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

/// A custom date picker widget that provides a horizontal scrollable list of dates
/// and a calendar popup for date selection.
///
/// This widget offers two ways to select dates:
/// 1. A horizontal scrollable list showing dates for the next 365 days
/// 2. A calendar icon that opens a standard date picker dialog
///
/// Features:
/// * Horizontal scrollable date list with day and date
/// * Calendar popup for selecting distant dates
/// * Reset to current date functionality
/// * Visual indication of selected date
/// * Smooth scrolling animation
///
/// Example:
/// ```dart
/// CustomDatePicker(
///   onDateSelected: (DateTime selectedDate) {
///     print('Selected date: $selectedDate');
///   },
/// )
/// ```
class CustomDatePicker extends StatefulWidget {
  /// Creates a custom date picker widget.
  ///
  /// The [onDateSelected] callback must not be null and will be called whenever
  /// a new date is selected, either through the scrollable list or calendar popup.
  const CustomDatePicker({required this.onDateSelected, super.key});

  /// Callback function that is called when a date is selected.
  ///
  /// This function receives the selected [DateTime] as its parameter.
  final void Function(DateTime) onDateSelected;

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

/// The state for the [CustomDatePicker] widget.
///
/// Manages the selected date and scroll controllers for the horizontal date list.
class _CustomDatePickerState extends State<CustomDatePicker> {
  /// The currently selected date.
  late DateTime selectedDate;

  /// Controller for scrolling to specific items in the date list.
  final ItemScrollController _itemScrollController = ItemScrollController();

  /// Controller for managing scroll offset in the date list.
  final ScrollOffsetController _scrollOffsetController = ScrollOffsetController();

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppRouter.l10n.selectDateRange,
              style: AppText.m20.copyWith(color: AppColors.greyText),
            ),
            InkWell(
              child: Row(
                children: [
                  Text(
                    'Reset to Current Date',
                    style: AppText.m20.copyWith(color: AppColors.primaryColor, height: 1),
                  ),
                ],
              ),
              onTap: () {
                final today = DateTime.now();
                setState(() {
                  selectedDate = today;
                });
                widget.onDateSelected(today);
                final daysDifference = selectedDate.difference(today).inDays;
                _itemScrollController.scrollTo(
                  index: daysDifference,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Horizontal date list
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xffE4E4E4)),
          ),
          clipBehavior: Clip.hardEdge,
          height: 60,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: () {
                  showDatePicker(
                    context: context,
                    firstDate: DateTime(2025),
                    lastDate: DateTime(2050),
                    initialDate: selectedDate,
                  ).then((value) {
                    if (value != null) {
                      setState(() {
                        selectedDate = value;
                      });
                      widget.onDateSelected(value);
                      // Calculate the difference in days between start date and selected date
                      final startDate = selectedDate.isBefore(DateTime.now())
                          ? DateTime(selectedDate.year, selectedDate.month, selectedDate.day)
                          : DateTime.now();

                      final daysDifference = selectedDate.difference(startDate).inDays;
                      _itemScrollController.scrollTo(
                        index: daysDifference,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: const BoxDecoration(
                    border: Border.symmetric(vertical: BorderSide(color: Color(0xffE4E4E4), width: .5)),
                  ),
                  child: const Icon(Icons.calendar_month, color: AppColors.primaryColor),
                ),
              ),
              Expanded(
                child: ScrollablePositionedList.builder(
                  itemCount: 365,
                  itemScrollController: _itemScrollController,
                  scrollOffsetController: _scrollOffsetController,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    // Determine start date based on whether selected date is before today
                    final startDate = selectedDate.isBefore(DateTime.now())
                        ? DateTime(selectedDate.year, selectedDate.month, selectedDate.day)
                        : DateTime.now();

                    final date = startDate.add(Duration(days: index));
                    final isSelected = date.year == selectedDate.year &&
                        date.month == selectedDate.month &&
                        date.day == selectedDate.day;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedDate = date;
                        });
                        widget.onDateSelected(date);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.red : Colors.transparent,
                          border: const Border.symmetric(
                            vertical: BorderSide(color: Color(0xffE4E4E4), width: .5),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('E').format(date),
                              style: TextStyle(
                                color: isSelected ? AppColors.primaryColor : AppColors.grey,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                            Text(
                              date.day.toString(),
                              style: TextStyle(
                                color: isSelected ? AppColors.primaryColor : Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
