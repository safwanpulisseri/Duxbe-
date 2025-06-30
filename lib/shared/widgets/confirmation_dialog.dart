import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';

class ConfirmationDialog extends ConsumerWidget {
  const ConfirmationDialog({
    required this.children,
    required this.title,
    super.key,
    this.onPositive,
    this.onNegative,
    this.negativeText,
    this.positiveText,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.isLoading = false,
    this.icon,
  });
  final List<Widget> children;
  final String title;
  final String? negativeText;
  final String? positiveText;
  final void Function(WidgetRef ref)? onPositive;
  final void Function(WidgetRef ref)? onNegative;
  final CrossAxisAlignment crossAxisAlignment;
  final bool isLoading;
  final Widget? icon;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSmallScreen = ResponsiveWidget.isSmallScreen(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: crossAxisAlignment,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xffEBF4FF),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: icon ??
                          const Icon(
                            Icons.delete_forever_outlined,
                            color: AppColors.primaryColor,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: AppText.heading5.copyWith(color: AppColors.primaryColor),
                ),
                const SizedBox(height: 12),
                ...children,
                const SizedBox(height: 12),
              ],
            ),
            if (!isSmallScreen)
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      style: ButtonStyles.cancel,
                      onPress: () {
                        onNegative?.call(ref);
                        context.pop(false);
                      },
                      label: Text(negativeText ?? context.l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      isLoading: isLoading,
                      onPress: () {
                        onPositive?.call(ref);
                      },
                      label: Text(positiveText ?? context.l10n.save),
                    ),
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppButton(
                    style: ButtonStyles.cancel,
                    onPress: () {
                      onNegative?.call(ref);
                      context.pop(false);
                    },
                    label: Text(negativeText ?? context.l10n.cancel),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    isLoading: isLoading,
                    onPress: () {
                      onPositive?.call(ref);
                    },
                    label: Text(positiveText ?? context.l10n.save),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
