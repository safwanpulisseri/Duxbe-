class AmountToWordsConverter {
  // --- Reusing the same helper lists and functions ---
  static final List<String> _ones = [
    '',
    'One',
    'Two',
    'Three',
    'Four',
    'Five',
    'Six',
    'Seven',
    'Eight',
    'Nine',
  ];
  static final List<String> _teens = [
    'Ten',
    'Eleven',
    'Twelve',
    'Thirteen',
    'Fourteen',
    'Fifteen',
    'Sixteen',
    'Seventeen',
    'Eighteen',
    'Nineteen',
  ];
  static final List<String> _tens = [
    '',
    '',
    'Twenty',
    'Thirty',
    'Forty',
    'Fifty',
    'Sixty',
    'Seventy',
    'Eighty',
    'Ninety',
  ];
  static final List<String> _thousands = [
    '',
    'Thousand',
    'Million',
    'Billion',
    'Trillion',
  ];

  static String _numberToWordsLessThanThousand(int number) {
    if (number == 0) return '';
    if (number < 10) return _ones[number];
    if (number < 20) return _teens[number - 10];
    if (number < 100) return _tens[number ~/ 10] + (_ones[number % 10].isNotEmpty ? ' ${_ones[number % 10]}' : '');
    final prefix = '${_ones[number ~/ 100]} Hundred';
    final suffix = _numberToWordsLessThanThousand(number % 100);
    return prefix + (suffix.isNotEmpty ? ' and $suffix' : '');
  }

  static String _integerToWords(int number) {
    if (number == 0) return 'Zero'; // Base case for "Zero"
    if (number < 0) return 'Minus ${_integerToWords(number.abs())}'; // Handle negatives
    var words = '';
    var i = 0;
    while (number > 0) {
      if (number % 1000 != 0) {
        final segmentWords = _numberToWordsLessThanThousand(number % 1000);
        if (segmentWords.isNotEmpty) {
          words = segmentWords +
              (_thousands[i].isNotEmpty ? ' ${_thousands[i]}' : '') +
              (words.isNotEmpty ? ' $words' : '');
        }
      }
      number ~/= 1000;
      i++;
    }
    return words.trim();
  }
  // --- End of reused helper functions ---

  // --- NEW SIMPLIFIED FUNCTION ---
  /// Converts a double amount to words only, without currency or minor units.
  /// Example: 123.45 -> "One Hundred and Twenty Three and Forty Five"
  /// Example: 100.00 -> "One Hundred"
  /// Example: 0.50   -> "Fifty"
  static String convertToWordsOnly(double amount) {
    if (amount.isInfinite || amount.isNaN) {
      return 'Invalid Amount';
    }

    var sign = '';
    if (amount < 0) {
      sign = 'Minus ';
      amount = amount.abs();
    }

    final integerPart = amount.truncate();
    final decimalPart = ((amount - integerPart) * 100).round();

    if (integerPart == 0 && decimalPart == 0) {
      return '${sign.isNotEmpty ? sign : ''}Zero'; // Handles 0.0 and -0.0
    }

    var integerWords = '';
    if (integerPart > 0) {
      integerWords = _integerToWords(integerPart);
    }

    var decimalWords = '';
    if (decimalPart > 0) {
      decimalWords = _integerToWords(decimalPart);
    }

    var result = '';
    if (integerWords.isNotEmpty && decimalWords.isNotEmpty) {
      result = '$integerWords and $decimalWords';
    } else if (integerWords.isNotEmpty) {
      result = integerWords; // Only integer part (e.g., 100.00)
    } else {
      // Only decimal part (e.g., 0.50)
      result = decimalWords;
    }

    return (sign + result).trim();
  }

  // --- The previous more complex function is still available if needed ---
  // (Keep the convertAmountToWordsWithCode method from the previous answer
  // if you might need it elsewhere)
  // For brevity, I'm omitting it here, but you can have both in the same class.
}
