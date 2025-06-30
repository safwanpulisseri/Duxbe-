import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:hancod_theme/hancod_theme.dart';

class ReportCard extends StatefulWidget {
  const ReportCard({
    required this.color,
    required this.title,
    required this.value,
    this.textColor = AppColors.white,
    super.key,
  });
  final Color color;
  final Color textColor;
  final String title;
  final String value;

  @override
  State<ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<ReportCard> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (ResponsiveWidget.isSmallScreen(context)) {
          setState(() {
            isExpanded = !isExpanded;
          });
        }
      },
      child: Container(
        padding: ResponsiveWidget.isLargeScreen(context)
            ? const EdgeInsets.all(16)
            : const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: widget.color,
        ),
        child: isExpanded
            ? Column(
                children: [
                  Text(
                    widget.title,
                    style: ResponsiveWidget.isLargeScreen(context)
                        ? AppText.xLargeSB.copyWith(color: widget.textColor)
                        : AppText.largeB.copyWith(color: widget.textColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.value,
                    style: ResponsiveWidget.isLargeScreen(context)
                        ? AppText.b28.copyWith(color: widget.textColor)
                        : AppText.xLargeB.copyWith(color: widget.textColor),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: ResponsiveWidget.isLargeScreen(context)
                        ? AppText.xLargeSB.copyWith(color: widget.textColor)
                        : AppText.largeB.copyWith(color: widget.textColor),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  Flexible(
                    child: Text(
                      overflow: TextOverflow.ellipsis,
                      widget.value,
                      style: ResponsiveWidget.isLargeScreen(context)
                          ? AppText.b28.copyWith(color: widget.textColor)
                          : AppText.xLargeB.copyWith(color: widget.textColor),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
