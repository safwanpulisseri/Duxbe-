import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';

class ServiceSelectionDialog extends ConsumerStatefulWidget {
  const ServiceSelectionDialog({
    required this.item,
    super.key,
  });
  final Item item;
  @override
  ConsumerState<ServiceSelectionDialog> createState() => _ServiceSelectionDialogState();
}

class _ServiceSelectionDialogState extends ConsumerState<ServiceSelectionDialog> {
  final selectedServices = <SubService>[];

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.item.name,
              style: AppText.heading5.copyWith(color: AppColors.primaryColor),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SingleChildScrollView(
                child: ListBody(
                  children: widget.item.subServices.map((service) {
                    return CheckboxListTile(
                      title: Text(service.name),
                      subtitle: Text('$currency ${service.additionalPrice}'),
                      value: selectedServices.contains(service),
                      onChanged: (selected) {
                        setState(() {
                          selected ?? false ? selectedServices.add(service) : selectedServices.remove(service);
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    style: ButtonStyles.secondary,
                    onPress: () {
                      context.pop();
                    },
                    label: Text(context.l10n.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    onPress: () {
                      context.pop(selectedServices);
                    },
                    label: Text(context.l10n.save),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceSelectionBottomSheet extends ConsumerStatefulWidget {
  const ServiceSelectionBottomSheet({
    required this.item,
    super.key,
  });
  final Item item;
  @override
  ConsumerState<ServiceSelectionBottomSheet> createState() => _ServiceSelectionBottomSheetState();
}

class _ServiceSelectionBottomSheetState extends ConsumerState<ServiceSelectionBottomSheet> {
  final selectedServices = <SubService>[];

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);
    return BottomSheet(
      onClosing: () {},
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.item.name,
              style: AppText.heading5.copyWith(color: AppColors.primaryColor),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SingleChildScrollView(
                child: ListBody(
                  children: widget.item.subServices.map((service) {
                    return CheckboxListTile(
                      title: Text(service.name),
                      subtitle: Text('$currency ${service.additionalPrice}'),
                      value: selectedServices.contains(service),
                      onChanged: (selected) {
                        setState(() {
                          selected ?? false ? selectedServices.add(service) : selectedServices.remove(service);
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    style: ButtonStyles.secondary,
                    onPress: () {
                      context.pop();
                    },
                    label: Text(context.l10n.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    onPress: () {
                      context.pop(selectedServices);
                    },
                    label: Text(context.l10n.save),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
