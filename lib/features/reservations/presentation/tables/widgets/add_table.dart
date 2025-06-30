import 'package:duxbe/features/reservations/reservations.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart' hide Table;
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';

class AddTableDialog extends ConsumerStatefulWidget {
  const AddTableDialog({this.table, this.selectedFloor, super.key});
  final Table? table;
  final Floor? selectedFloor;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddTableDialogState();
}

class _AddTableDialogState extends ConsumerState<AddTableDialog> {
  final _key = GlobalKey<FormBuilderState>();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: FormBuilder(
        key: _key,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
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
                    Text(context.l10n.addNewArea, style: AppText.b28.copyWith(color: AppColors.black)),
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
                    AppTextForm<String>(
                      label: 'Table Name',
                      name: 'name',
                      initialValue: widget.table?.name,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.maxLength(5),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    AppTextForm<int>(
                      label: 'Seating Capacity',
                      name: 'no_of_seats',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.min(1),
                        FormBuilderValidators.max(20),
                      ]),
                      initialValue: widget.table?.noOfSeats,
                    ),
                    const SizedBox(height: 12),
                    AppDropDownForm<String>(
                      name: 'floor_id',
                      label: 'Choose Area',
                      initialValue: widget.table?.floorId ?? widget.selectedFloor?.floorId,
                      validator: FormBuilderValidators.required(),
                      items: ref
                          .watch(tableNotifierProvider)
                          .floors
                          .map(
                            (e) => DropDownItems(
                              value: e.floorId,
                              child: Text(e.name),
                            ),
                          )
                          .toList(),
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
                        isLoading: ref.watch(tableNotifierProvider).status == TableStatus.loading,
                        label: Text(context.l10n.submit),
                        onPress: () {
                          if (!_key.currentState!.saveAndValidate()) return;
                          ref
                              .read(tableNotifierProvider.notifier)
                              .upsertTable(
                                Table.fromJson({
                                  ..._key.currentState!.value,
                                  'table_id': widget.table?.tableId,
                                  'x': widget.table?.x,
                                  'y': widget.table?.y,
                                  'turns': widget.table?.turns,
                                }),
                              )
                              .then((value) {
                            if (context.mounted) context.pop();
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
