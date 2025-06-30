import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';

/// A reusable dialog widget with customizable content and actions.
///
/// This dialog provides a consistent layout with a title bar, content area,
/// and action buttons. It's designed to be responsive and adapts its layout
/// based on screen size.
///
/// Features:
/// * Customizable title and content
/// * Responsive layout that adapts to screen size
/// * Optional positive and negative action buttons
/// * Loading state support
/// * Riverpod integration for state management
///
/// Example:
/// ```dart
/// CommonDialog(
///   title: 'Confirm Action',
///   children: [Text('Are you sure you want to proceed?')],
///   onPositive: (ref) => handleConfirm(),
///   onNegative: (ref) => handleCancel(),
/// )
/// ```
class CommonDialog extends ConsumerWidget {
  /// Creates a common dialog widget.
  ///
  /// The [title] and [children] parameters must not be null.
  /// [children] represents the main content of the dialog.
  /// [onPositive] and [onNegative] are optional callbacks for action buttons.
  /// [isLoading] indicates whether the dialog is in a loading state.
  const CommonDialog({
    required this.children,
    required this.title,
    super.key,
    this.onPositive,
    this.onNegative,
    this.negativeText,
    this.positiveText,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.isLoading = false,
  });

  /// The main content widgets to be displayed in the dialog.
  final List<Widget> children;

  /// The title text displayed at the top of the dialog.
  final String title;

  /// Custom text for the negative action button.
  /// If null, defaults to "Cancel".
  final String? negativeText;

  /// Custom text for the positive action button.
  /// If null, defaults to "Save".
  final String? positiveText;

  /// Callback function triggered when the positive action button is pressed.
  final void Function(WidgetRef ref)? onPositive;

  /// Callback function triggered when the negative action button is pressed.
  final void Function(WidgetRef ref)? onNegative;

  /// The cross axis alignment for the dialog's content.
  final CrossAxisAlignment crossAxisAlignment;

  /// Whether the dialog is in a loading state.
  /// When true, shows a loading indicator on the positive action button.
  final bool isLoading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSmallScreen = ResponsiveWidget.isSmallScreen(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: crossAxisAlignment,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: AppText.sb20.copyWith(color: AppColors.black),
                      ),
                      IconButton(
                        onPressed: context.pop,
                        icon: const Icon(Icons.close),
                        constraints: const BoxConstraints(minHeight: 24, minWidth: 24),
                        padding: EdgeInsets.zero,
                        iconSize: 24,
                        splashRadius: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.grey),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
            const SizedBox(height: 12),
            if (!isSmallScreen)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        style: ButtonStyles.cancel,
                        onPress: () {
                          onNegative?.call(ref);
                          context.pop();
                        },
                        label: Text(context.l10n.cancel),
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
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppButton(
                    style: ButtonStyles.secondary,
                    onPress: () {
                      onNegative?.call(ref);
                    },
                    label: Text(negativeText ?? context.l10n.cancel),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
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
