import 'package:flutter/material.dart';
import 'package:hancod_theme/hancod_theme.dart';

class Loader extends StatelessWidget {
  const Loader({
    super.key,
    this.color = AppColors.primaryColor,
  });
  final Color color;
  @override
  Widget build(BuildContext context) => Center(
        child: CircularProgressIndicator(color: color),
      );
}
