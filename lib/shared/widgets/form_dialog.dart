import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';

class FormAddDialog extends ConsumerStatefulWidget {
  const FormAddDialog({
    required this.children,
    required this.title,
    required this.formKey,
    super.key,
    this.onPositive,
    this.onChanged,
    this.isLoading = false,
    this.onNegative,
    this.negativeLabel,
    this.positiveLabel,
    this.buttonColor,
    this.negativeButtonColor,
  });
  final List<Widget> children;
  final String title;
  final bool isLoading;
  final GlobalKey<FormBuilderState> formKey;
  final String? negativeLabel;
  final String? positiveLabel;
  final Color? buttonColor;
  final Color? negativeButtonColor;

  /// If someone wants to pop manually
  final void Function()? onPositive;
  final void Function()? onChanged;
  final void Function()? onNegative;
  @override
  ConsumerState<FormAddDialog> createState() => _FormAddDialogState();
}

class _FormAddDialogState extends ConsumerState<FormAddDialog> {
  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: widget.formKey,
      onChanged: widget.onChanged,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.title,
                  style: AppText.heading5.copyWith(color: AppColors.primaryColor),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.children,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        style: ButtonStyles.secondary,
                        onPress: () {
                          widget.onNegative?.call();
                          context.pop();
                        },
                        color: widget.negativeButtonColor,
                        label: Text(widget.negativeLabel ?? context.l10n.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        isLoading: widget.isLoading,
                        onPress: () {
                          if (widget.formKey.currentState?.saveAndValidate() ?? false) {
                            widget.onPositive?.call();
                          }
                        },
                        color: widget.buttonColor,
                        label: Text(widget.positiveLabel ?? context.l10n.save),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FormAddButton extends StatelessWidget {
  const FormAddButton({
    super.key,
    this.onTap,
    this.icon,
  });
  final void Function()? onTap;
  final Widget? icon;
  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.hardEdge,
      color: AppColors.textfield,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: icon ??
              const Icon(
                Icons.add,
                color: AppColors.primaryColor,
                size: 24,
              ),
        ),
      ),
    );
  }
}
