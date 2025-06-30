import 'package:flutter/material.dart';
import 'package:hancod_theme/hancod_theme.dart';

class NameAbbrWidget extends StatelessWidget {
  const NameAbbrWidget({
    required this.name,
    super.key,
    this.size,
    this.textSize = 50,
  });

  final String name;
  final double? size;
  final double? textSize;

  String getInitials(String name) {
    final words = name.trim().split(' ').where((word) => word.isNotEmpty).toList();
    var initials = '';
    if (words.isNotEmpty) {
      if (words[0].isNotEmpty) {
        initials += words[0][0].toUpperCase(); // Add the first letter of the first word
      }
      if (words.length > 1 && words[1].isNotEmpty) {
        initials += words[1][0].toUpperCase(); // Add the first letter of the second word
      }
    }

    return initials;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      alignment: Alignment.center,
      color: AppColors.lightPurple, // Background color for the initials
      child: Center(
        child: Text(
          getInitials(name),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 30, // Adjust the size as needed
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor, // Text color for the initials
          ),
        ),
      ),
    );
  }
}
