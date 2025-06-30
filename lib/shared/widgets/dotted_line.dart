import 'package:flutter/material.dart';

/// A widget that displays a horizontal dotted line.
///
/// This widget can be customized with different colors, dash widths,
/// dash gaps, and stroke width.
class DottedLine extends StatelessWidget {
  /// Creates a dotted line widget.
  ///
  /// The [color] defaults to Colors.grey.
  /// The [dashWidth] defaults to 5.0.
  /// The [dashGap] defaults to 3.0.
  /// The [strokeWidth] defaults to 1.0.
  /// The [height] defaults to 1.0.
  const DottedLine({
    super.key,
    this.color = Colors.grey,
    this.dashWidth = 5.0,
    this.dashGap = 3.0,
    this.strokeWidth = 1.0,
    this.height = 1.0,
  });

  /// The color of the dotted line.
  final Color color;

  /// The width of each dash in the dotted line.
  final double dashWidth;

  /// The gap between each dash in the dotted line.
  final double dashGap;

  /// The stroke width of the dotted line.
  final double strokeWidth;

  /// The height of the dotted line widget.
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: CustomPaint(
        painter: _DottedLinePainter(
          color: color,
          dashWidth: dashWidth,
          dashGap: dashGap,
          strokeWidth: strokeWidth,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  _DottedLinePainter({
    required this.color,
    required this.dashWidth,
    required this.dashGap,
    required this.strokeWidth,
  });
  final Color color;
  final double dashWidth;
  final double dashGap;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    const startX = 0.0;
    final endX = size.width;
    final y = size.height / 2;

    var currentX = startX;
    final dashLength = dashWidth + dashGap;

    while (currentX < endX) {
      canvas.drawLine(
        Offset(currentX, y),
        Offset(currentX + dashWidth, y),
        paint,
      );
      currentX += dashLength;
    }
  }

  @override
  bool shouldRepaint(_DottedLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashGap != dashGap ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
