import 'package:duxbe/features/reservations/reservations.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';

class AddAreaDialog extends ConsumerStatefulWidget {
  const AddAreaDialog({this.floor, super.key});
  final Floor? floor;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddAreaDialogState();
}

class _AddAreaDialogState extends ConsumerState<AddAreaDialog> {
  final _areaController = TextEditingController();
  final _key = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    if (widget.floor != null) {
      _areaController.text = widget.floor!.name;
    }
    super.initState();
  }

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
                    Text(AppRouter.l10n.addNewArea, style: AppText.heading5.copyWith(color: AppColors.black)),
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
                      label: 'Area Name',
                      name: 'name',
                      validator: FormBuilderValidators.required(),
                      controller: _areaController,
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
                        label: Text(context.l10n.submit),
                        isLoading: ref.watch(tableNotifierProvider).status == TableStatus.loading,
                        onPress: () {
                          if (_key.currentState!.saveAndValidate()) {
                            ref
                                .read(tableNotifierProvider.notifier)
                                .upsertFloor(Floor(name: _areaController.text, floorId: widget.floor?.floorId))
                                .then((value) {
                              if (context.mounted) context.pop();
                            });
                          }
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
