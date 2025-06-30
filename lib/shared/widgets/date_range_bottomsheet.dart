import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
// Use flutter_riverpod for ConsumerStatefulWidget
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Keep hancod_theme import if needed, ensure it exists
import 'package:hancod_theme/hancod_theme.dart';

enum PredefinedDateRange { last10Days, ninetyDays, sixMonths }

class DateRangeBottomSheet extends ConsumerStatefulWidget {
  const DateRangeBottomSheet({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
  });
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  @override
  ConsumerState<DateRangeBottomSheet> createState() => _DateRangeBottomSheetState();
}

class _DateRangeBottomSheetState extends ConsumerState<DateRangeBottomSheet> {
  PredefinedDateRange? _selectedPredefinedRange;
  final DateTime _now = DateTime.now();
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    // If initial dates are provided, don't select a predefined range initially.
    if (widget.initialStartDate == null || widget.initialEndDate == null) {
      // Optionally set a default predefined range if no initial dates are given
      // _selectedPredefinedRange = PredefinedDateRange.last10Days;
    }
  }

  void _selectPredefinedRange(PredefinedDateRange range) {
    // setState is available in State classes
    setState(() {
      _selectedPredefinedRange = range;
      // Clear the custom date range field when a predefined one is selected
      final end = _now;
      var start = _now;
      switch (range) {
        case PredefinedDateRange.last10Days:
          start = end.subtract(const Duration(days: 10));
        case PredefinedDateRange.ninetyDays:
          start = end.subtract(const Duration(days: 90));
        case PredefinedDateRange.sixMonths:
          start = DateTime(end.year, end.month - 6, end.day);
      }
      _formKey.currentState?.fields['date_range']?.didChange((start, end));
    });
  }

  (DateTime, DateTime)? _calculateResult() {
    // Save the form state to ensure the latest value is available
    _formKey.currentState?.save();

    if (_selectedPredefinedRange != null) {
      final end = _now;
      var start = _now;
      switch (_selectedPredefinedRange!) {
        case PredefinedDateRange.last10Days:
          start = end.subtract(const Duration(days: 10));
        case PredefinedDateRange.ninetyDays:
          start = end.subtract(const Duration(days: 90));
        case PredefinedDateRange.sixMonths:
          start = DateTime(end.year, end.month - 6, end.day);
      }
      return (start, end);
    } else {
      // Get the value directly from the form field
      final dateRange = _formKey.currentState?.fields['date_range']?.value as (DateTime, DateTime)?;
      if (dateRange != null) {
        final startDate = dateRange.$1;
        final endDate = dateRange.$2;

        if (startDate.isAfter(endDate)) {
          // context is available in State classes
          if (mounted) {
            Alert.showSnackBar(
              'Start date must be before end date',
              type: SnackBarType.error,
            );
          }
          return null;
        }
        return (startDate, endDate);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Padding(
      // Access MediaQuery using context
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16) +
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: FormBuilder(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text( context.l10n.dateRange, style: AppText.largeM.copyWith(color: AppColors.black)),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    _formKey.currentState?.reset();
                    setState(() {
                      _selectedPredefinedRange = null;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.brandViolet),
                    ),
                    child: const Icon(Icons.restart_alt_rounded, color: AppColors.brandViolet),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.purple),
                    ),
                    backgroundColor: const Color(0xffEFF1FF),
                    label:  Text(context.l10n.last10Days),
                    selected: _selectedPredefinedRange == PredefinedDateRange.last10Days,
                    onSelected: (selected) => _selectPredefinedRange(PredefinedDateRange.last10Days),
                    selectedColor: primaryColor.withOpacity(0.2),
                    showCheckmark: false,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.purple),
                    ),
                    backgroundColor: const Color(0xffEFF1FF),
                    labelStyle: AppText.mediumN.copyWith(color: AppColors.black),
                    label:  Text('90 ${context.l10n.days}'),
                    selected: _selectedPredefinedRange == PredefinedDateRange.ninetyDays,
                    onSelected: (selected) => _selectPredefinedRange(PredefinedDateRange.ninetyDays),
                    selectedColor: primaryColor.withOpacity(0.2),
                    showCheckmark: false,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.purple),
                    ),
                    backgroundColor: const Color(0xffEFF1FF),
                    label:  Text('6 ${context.l10n.months}'),
                    selected: _selectedPredefinedRange == PredefinedDateRange.sixMonths,
                    onSelected: (selected) => _selectPredefinedRange(PredefinedDateRange.sixMonths),
                    selectedColor: primaryColor.withOpacity(0.2),
                    showCheckmark: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(child: Divider(color: AppColors.purple)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(context.l10n.or, style: AppText.mediumN.copyWith(color: Colors.grey[600])),
                ),
                const Expanded(child: Divider(color: AppColors.purple)),
              ],
            ),
            const SizedBox(height: 20),
            Text(context.l10n.chooseDate, style: AppText.largeM.copyWith(color: AppColors.black)),
            const SizedBox(height: 16),
            FormBuilderField<(DateTime, DateTime)>(
              builder: (field) {
                return IntrinsicWidth(
                  child: InkWell(
                    onTap: () async {
                      final start = await showDatePicker(
                        context: context,
                        initialDate: field.value?.$1 ?? widget.initialStartDate ?? _now,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2040),
                      );
                      if (start == null) return;
                      if (!context.mounted) return;

                      // Then pick closing time
                      final end = await showDatePicker(
                        context: context,
                        initialDate: field.value?.$2 ?? widget.initialEndDate ?? _now,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2040),
                      );
                      if (end != null) {
                        // Validate that end time is after start time
                        // by converting both times to minutes since midnight

                        if (start.isAfter(end)) {
                          // Show error if start time is after or equal to end time
                          Alert.showSnackBar(
                            context.l10n.startDateMustBeBeforeEndDate,
                            type: SnackBarType.error,
                          );
                          return;
                        }

                        // Update form fields with the selected times
                        field.didChange((start, end));
                        // Clear predefined range when custom dates are selected
                        setState(() {
                          _selectedPredefinedRange = null;
                        });
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              suffixIcon: Icon(Icons.calendar_month, color: AppColors.purple),
                            ),
                            child: Text(field.value?.$1.toDateOnlyWithYear ?? '    -   '),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(context.l10n.to),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              suffixIcon: Icon(Icons.calendar_month, color: AppColors.purple),
                            ),
                            child: Text(field.value?.$2.toDateOnlyWithYear ?? '   -   '),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              name: 'date_range',
              initialValue: (widget.initialStartDate != null && widget.initialEndDate != null)
                  ? (widget.initialStartDate!, widget.initialEndDate!)
                  : null,
            ),
            const SizedBox(height: 32),
            AppButton(
              onPress: () {
                final result = _calculateResult();
                // Access Navigator using context
                if (result != null && mounted) {
                  Navigator.pop(context, result);
                }
              },
              label: Text(context.l10n.save),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
