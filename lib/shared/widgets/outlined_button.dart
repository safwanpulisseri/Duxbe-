import 'package:flutter/material.dart';
import 'package:hancod_theme/hancod_theme.dart';

class CustomOutlinedIconButton extends StatelessWidget {
  const CustomOutlinedIconButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.borderColor,
    required this.backgroundColor,
    required this.textColor,
    super.key,
  });

  final String label;
  final Widget icon;
  final VoidCallback onPressed;
  final Color borderColor;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: borderColor,
        ),
        backgroundColor: backgroundColor,
      ),
      icon: icon,
      onPressed: onPressed,
      label: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        child: Text(
          label,
          style: AppText.mediumSB.copyWith(color: textColor),
        ),
      ),
    );
  }
}
