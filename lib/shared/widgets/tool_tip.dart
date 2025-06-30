import 'package:flutter/material.dart';
import 'package:hancod_theme/hancod_theme.dart';

class AppToolTip extends StatelessWidget {
  const AppToolTip({required this.child, super.key});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      padding: const EdgeInsets.all(12),
      richMessage: WidgetSpan(child: child),
      decoration: BoxDecoration(
        color: AppColors.brandViolet,
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 30),
            blurRadius: 50,
            color: AppColors.white,
          ),
        ],
      ),
      child: const Icon(
        Icons.question_mark,
        size: 18,
        color: AppColors.brandViolet,
      ),
    );
  }
}
