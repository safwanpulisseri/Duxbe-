import 'package:flutter/material.dart';

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 9.0;
    const dashSpace = 5.0;
    var startX = 0.0;
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CustomSvgBorder extends ShapeBorder {
  const CustomSvgBorder({
    this.cornerRadius = 19.0,
    this.borderColor = Colors.white,
    this.borderWidth = 2.0,
  });
  final double cornerRadius;
  final Color borderColor;
  final double borderWidth;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(borderWidth);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return _createCustomPath(rect);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    // Slightly inset the path to create an inner border
    final innerRect = rect.deflate(borderWidth);
    return _createCustomPath(innerRect);
  }

  Path _createCustomPath(Rect rect) {
    final path = Path();
    const cCutoutWidth = 20.0; // Width of the C-shaped cutout
    const cCutoutHeight = 40.0; // Height of the C-shaped cutout
    const cCutoutDepth = 0.0; // How deep the C cutout goes
    final middleY = rect.top + rect.height / 2; // Middle point of the rect height

    // Calculate number of bottom cutouts
    const bottomGap = 6.0; // Gap between bottom cutouts
    const bottomCutoutWidth = 30.0; // Width of bottom cutouts
    const bottomCutoutDepth = 0.0; // Depth of bottom cutouts
    final availableWidth = rect.width - (2 * cornerRadius);
    final numBottomCutouts = ((availableWidth + bottomGap) / (bottomCutoutWidth + bottomGap)).floor();
    final totalCutoutsWidth = numBottomCutouts * bottomCutoutWidth + (numBottomCutouts - 1) * bottomGap;
    final leftMargin = rect.left + cornerRadius + (availableWidth - totalCutoutsWidth) / 2;

    // Start at top-left with rounded corner
    path
      ..moveTo(rect.left + cornerRadius, rect.top)

      // Top line
      ..lineTo(rect.right - cornerRadius, rect.top)

      // Top-right corner
      ..quadraticBezierTo(rect.right, rect.top, rect.right, rect.top + cornerRadius)

      // Right side to the C cutout
      ..lineTo(rect.right, middleY - cCutoutHeight / 2)

      // Right side C cutout (normal C)
      ..lineTo(rect.right - cCutoutDepth, middleY - cCutoutHeight / 2)
      ..arcToPoint(
        Offset(rect.right - cCutoutDepth, middleY + cCutoutHeight / 2),
        radius: const Radius.circular(cCutoutWidth / 2),
        clockwise: false,
      )
      ..lineTo(rect.right, middleY + cCutoutHeight / 2)

      // Continue right side
      ..lineTo(rect.right, rect.bottom - cornerRadius)
      ..quadraticBezierTo(rect.right, rect.bottom, rect.right - cornerRadius, rect.bottom);

    // Bottom edge with C cutouts
    final currentX = rect.right - cornerRadius;
    for (var i = numBottomCutouts - 1; i >= 0; i--) {
      final cutoutX = leftMargin + i * (bottomCutoutWidth + bottomGap);

      // Draw line to the start of cutout
      path
        ..lineTo(cutoutX + bottomCutoutWidth, rect.bottom)

        // Draw C cutout (modified to create normal C shape)
        ..lineTo(cutoutX + bottomCutoutWidth, rect.bottom - bottomCutoutDepth)
        ..arcToPoint(
          Offset(cutoutX, rect.bottom - bottomCutoutDepth),
          radius: const Radius.circular(bottomCutoutWidth / 2),
          clockwise: false, // Changed to false to make normal C shape
        )
        ..lineTo(cutoutX, rect.bottom);
    }

    // Continue to bottom-left corner
    path
      ..lineTo(rect.left + cornerRadius, rect.bottom)
      ..quadraticBezierTo(rect.left, rect.bottom, rect.left, rect.bottom - cornerRadius)

      // Left side with reversed C cutout
      ..lineTo(rect.left, middleY + cCutoutHeight / 2)
      ..lineTo(rect.left + cCutoutDepth, middleY + cCutoutHeight / 2)
      ..arcToPoint(
        Offset(rect.left + cCutoutDepth, middleY - cCutoutHeight / 2),
        radius: const Radius.circular(cCutoutWidth / 2),
        clockwise: false,
      )
      ..lineTo(rect.left, middleY - cCutoutHeight / 2)
      ..lineTo(rect.left, rect.top + cornerRadius)

      // Complete the path
      ..quadraticBezierTo(rect.left, rect.top, rect.left + cornerRadius, rect.top)
      ..close();
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final path = _createCustomPath(rect);
    canvas.drawPath(path, paint);
  }

  @override
  ShapeBorder scale(double t) {
    return CustomSvgBorder(
      cornerRadius: cornerRadius * t,
      borderColor: borderColor,
      borderWidth: borderWidth * t,
    );
  }
}
