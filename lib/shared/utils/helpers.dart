import 'dart:async';

import 'package:flutter/services.dart';

class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final regExp = RegExp(r'\s');
    final filteredText = newValue.text.replaceAll(regExp, '');

    return TextEditingValue(
      text: filteredText.toLowerCase().trim(),
      selection: newValue.selection,
    );
  }
}

class Debouncer {
  Debouncer({
    required this.milliseconds,
  });
  final int milliseconds;
  // VoidCallback action;
  Timer? _timer;

  void run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }

    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

bool isValidFileSize(Uint8List bytes, double sizeInMB) {
  final sizeInMB = bytes.length / (1024 * 1024);
  return sizeInMB <= sizeInMB;
}

// Helper for parsing numbers that might be strings or actual numbers
double? parseDoubleSafe(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    if (value.isEmpty) return null;
    return double.tryParse(value);
  }
  return null;
}

// Helper for parsing DateTime from String
DateTime? dateTimeFromString(String? dateString) {
  if (dateString == null || dateString.isEmpty) return null;
  try {
    return DateTime.parse(dateString);
  } catch (e) {
    print('Error parsing DateTime: $dateString, $e');
    return null;
  }
}
