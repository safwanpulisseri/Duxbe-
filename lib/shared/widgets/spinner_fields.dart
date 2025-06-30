import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hancod_theme/hancod_theme.dart';

/// An integer example of the generic [SpinnerField] that validates input and
/// increments by a delta.
class IntegerSpinnerField extends StatelessWidget {
  const IntegerSpinnerField({
    required this.value,
    super.key,
    this.autofocus = false,
    this.delta = 1,
    this.onChanged,
    this.min,
    this.max,
  });

  final int value;
  final bool autofocus;
  final int delta;
  final ValueChanged<int>? onChanged;
  final int? min;
  final int? max;

  @override
  Widget build(BuildContext context) {
    return SpinnerField<int>(
      value: value,
      onChanged: onChanged,
      autofocus: autofocus,
      fromString: (String stringValue) {
        final parsed = int.tryParse(stringValue) ?? value;
        return parsed.clamp(min ?? parsed, max ?? parsed);
      },
      increment: (int i) =>
          max != null ? (i + delta).clamp(min ?? i, max!) : i + delta,
      decrement: (int i) =>
          min != null ? (i - delta).clamp(min!, max ?? i) : i - delta,
      // Add a text formatter that only allows integer values and a leading
      // minus sign.
      inputFormatters: <TextInputFormatter>[
        TextInputFormatter.withFunction(
          (TextEditingValue oldValue, TextEditingValue newValue) {
            String newString;
            if (newValue.text.startsWith('-')) {
              newString = '-${newValue.text.replaceAll(RegExp(r'\D'), '')}';
            } else {
              newString = newValue.text.replaceAll(RegExp(r'\D'), '');
            }
            return newValue.copyWith(
              text: newString,
              selection: newValue.selection.copyWith(
                baseOffset:
                    newValue.selection.baseOffset.clamp(0, newString.length),
                extentOffset:
                    newValue.selection.extentOffset.clamp(0, newString.length),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// A generic "spinner" field example which adds extra buttons next to a
/// [TextField] to increment and decrement the value.
///
/// This widget uses [TextFieldTapRegion] to indicate that tapping on the
/// spinner buttons should not cause the text field to lose focus.
class SpinnerField<T extends num> extends StatefulWidget {
  SpinnerField({
    required this.value,
    required this.fromString,
    super.key,
    this.autofocus = false,
    String Function(T value)? asString,
    this.increment,
    this.decrement,
    this.onChanged,
    this.showButtons = true,
    this.inputFormatters = const <TextInputFormatter>[],
    this.decoration,
    this.style,
    this.min,
    this.max,
  }) : asString = asString ?? ((T value) => value.toString());

  final T value;
  final T Function(T value)? increment;
  final T Function(T value)? decrement;
  final String Function(T value) asString;
  final T Function(String value) fromString;
  final ValueChanged<T>? onChanged;
  final List<TextInputFormatter> inputFormatters;
  final bool autofocus;
  final InputDecoration? decoration;
  final bool showButtons;
  final TextStyle? style;
  final T? min;
  final T? max;

  @override
  State<SpinnerField<T>> createState() => _SpinnerFieldState<T>();
}

class _SpinnerFieldState<T extends num> extends State<SpinnerField<T>> {
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateText(widget.asString(widget.value));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SpinnerField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asString != widget.asString ||
        oldWidget.value != widget.value) {
      final newText = widget.asString(widget.value);
      _updateText(newText);
    }
  }

  void _updateText(String text, {bool collapsed = true}) {
    if (text != controller.text) {
      controller.value = TextEditingValue(
        text: text,
        selection: collapsed
            ? TextSelection.collapsed(offset: text.length)
            : TextSelection(baseOffset: 0, extentOffset: text.length),
      );
    }
  }

  void _spin(T Function(T value)? spinFunction) {
    if (spinFunction == null) {
      return;
    }
    final newValue = spinFunction(widget.value);
    widget.onChanged?.call(newValue);
    _updateText(widget.asString(newValue), collapsed: false);
  }

  void _increment() {
    _spin(widget.increment);
  }

  void _decrement() {
    _spin(widget.decrement);
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(0),
      borderSide: const BorderSide(color: Color(0xff8B94B2)),
    );
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.arrowUp): _increment,
        const SingleActivator(LogicalKeyboardKey.arrowDown): _decrement,
      },
      child: InputDecorator(
        decoration: widget.decoration ??
            InputDecoration(
              contentPadding: EdgeInsets.zero,
              border: border,
              errorBorder: border,
              focusedBorder: border,
              enabledBorder: border,
              disabledBorder: border,
              isDense: true,
            ),
        child: Row(
          children: <Widget>[
            if (widget.showButtons)
              TextFieldTapRegion(
                child: SizedBox(
                  height: 38,
                  width: 38,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _decrement,
                      child: const Icon(Icons.remove,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: !widget.showButtons
                    ? const EdgeInsets.all(4)
                    : EdgeInsets.zero,
                child: TextField(
                  autofocus: widget.autofocus,
                  inputFormatters: widget.inputFormatters,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    isDense: true,
                  ),
                  style: widget.style ??
                      AppText.largeSB.copyWith(color: AppColors.primaryColor),
                  onChanged: (String value) =>
                      widget.onChanged?.call(widget.fromString(value)),
                  controller: controller,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            if (widget.showButtons)
              TextFieldTapRegion(
                child: SizedBox(
                  height: 38,
                  width: 38,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _increment,
                      child:
                          const Icon(Icons.add, color: AppColors.primaryColor),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DoubleSpinnerField extends StatelessWidget {
  const DoubleSpinnerField({
    required this.value,
    super.key,
    this.autofocus = false,
    this.delta = 1,
    this.onChanged,
    this.showButtons = true,
    this.decoration,
    this.style,
    this.min,
    this.max,
  });

  final double value;
  final bool autofocus;
  final bool showButtons;
  final double delta;
  final ValueChanged<double>? onChanged;
  final InputDecoration? decoration;
  final TextStyle? style;
  final double? min;
  final double? max;

  @override
  Widget build(BuildContext context) {
    return SpinnerField<double>(
      value: value,
      onChanged: onChanged,
      autofocus: autofocus,
      showButtons: showButtons,
      fromString: (String stringValue) {
        final parsed = double.tryParse(stringValue) ?? value;
        return parsed.clamp(min ?? parsed, max ?? parsed);
      },
      increment: (double i) =>
          max != null ? (i + delta).clamp(min ?? i, max!) : i + delta,
      decrement: (double i) =>
          min != null ? (i - delta).clamp(min!, max ?? i) : i - delta,
      decoration: decoration,
      style: style,
      // Add a text formatter that only allows integer values and a leading
      // minus sign.
      inputFormatters: <TextInputFormatter>[
        CurrencyInputFormatter(),
      ],
    );
  }
}

/// A generic "spinner" field example which adds extra buttons next to a
/// [TextField] to increment and decrement the value.
///
/// This widget uses [TextFieldTapRegion] to indicate that tapping on the
/// spinner buttons should not cause the text field to lose focus.
class CartSpinnerField<T> extends StatefulWidget {
  CartSpinnerField({
    required this.value,
    required this.fromString,
    super.key,
    this.autofocus = false,
    String Function(T value)? asString,
    this.increment,
    this.decrement,
    this.keyboardType,
    this.onChanged,
    this.showButtons = true,
    this.inputFormatters = const <TextInputFormatter>[],
    this.style,
  }) : asString = asString ?? ((T value) => value.toString());

  final T value;
  final T Function(T value)? increment;
  final T Function(T value)? decrement;
  final String Function(T value) asString;
  final T Function(String value) fromString;
  final ValueChanged<T>? onChanged;
  final List<TextInputFormatter> inputFormatters;
  final bool autofocus;
  final bool showButtons;
  final TextStyle? style;
  final TextInputType? keyboardType;
  @override
  State<CartSpinnerField<T>> createState() => _CartSpinnerFieldState<T>();
}

class _CartSpinnerFieldState<T> extends State<CartSpinnerField<T>> {
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateText(widget.asString(widget.value));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CartSpinnerField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asString != widget.asString ||
        oldWidget.value != widget.value) {
      final newText = widget.asString(widget.value);
      _updateText(newText);
    }
  }

  void _updateText(String text, {bool collapsed = true}) {
    if (text != controller.text) {
      controller.value = TextEditingValue(
        text: text,
        selection: collapsed
            ? TextSelection.collapsed(offset: text.length)
            : TextSelection(baseOffset: 0, extentOffset: text.length),
      );
    }
  }

  void _spin(T Function(T value)? spinFunction) {
    if (spinFunction == null) {
      return;
    }
    final newValue = spinFunction(widget.value);
    widget.onChanged?.call(newValue);
    _updateText(widget.asString(newValue), collapsed: false);
  }

  void _increment() {
    _spin(widget.increment);
  }

  void _decrement() {
    _spin(widget.decrement);
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.arrowUp): _increment,
        const SingleActivator(LogicalKeyboardKey.arrowDown): _decrement,
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xffEAEAEA)),
          borderRadius: BorderRadius.circular(99),
          color: const Color.fromRGBO(249, 249, 249, 1),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: <Widget>[
            if (widget.showButtons)
              TextFieldTapRegion(
                child: SizedBox(
                  height: 28,
                  width: 28,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xffEAEAEA)),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Material(
                      borderRadius: BorderRadius.circular(99),
                      clipBehavior: Clip.antiAlias,
                      // shape: Border.all(color: const Color(0xffEAEAEA)),
                      color: Colors.white,
                      child: InkWell(
                        onTap: _increment,
                        child:
                            const Icon(Icons.add, color: AppColors.brandViolet),
                      ),
                    ),
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: TextField(
                  keyboardType: widget.keyboardType,
                  autofocus: widget.autofocus,
                  inputFormatters: widget.inputFormatters,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: widget.style ??
                      AppText.largeSB.copyWith(color: AppColors.primaryColor),
                  onChanged: (String value) =>
                      widget.onChanged?.call(widget.fromString(value)),
                  controller: controller,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            if (widget.showButtons)
              TextFieldTapRegion(
                child: SizedBox(
                  height: 28,
                  width: 28,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xffEAEAEA)),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Material(
                      clipBehavior: Clip.antiAlias,
                      borderRadius: BorderRadius.circular(99),
                      color: Colors.white,
                      child: InkWell(
                        onTap: _decrement,
                        child: const Icon(Icons.remove,
                          color: AppColors.brandViolet,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CartDoubleSpinnerField extends StatelessWidget {
  const CartDoubleSpinnerField({
    required this.value,
    super.key,
    this.autofocus = false,
    this.delta = 1,
    this.onChanged,
    this.showButtons = true,
    this.style,
    this.min,
    this.max,
    this.keyboardType,
  });

  final double value;
  final bool autofocus;
  final bool showButtons;
  final double delta;
  final ValueChanged<double>? onChanged;
  final TextStyle? style;
  final double? min;
  final double? max;
  final TextInputType? keyboardType;
  @override
  Widget build(BuildContext context) {
    return CartSpinnerField<double>(
      keyboardType: keyboardType,
      value: value,
      onChanged: onChanged,
      autofocus: autofocus, showButtons: showButtons,
      fromString: (String stringValue) {
        final parsed = double.tryParse(stringValue) ?? value;
        return parsed.clamp(min ?? parsed, max ?? parsed);
      },
      increment: (double i) =>
          max != null ? (i + delta).clamp(min ?? i, max!) : i + delta,
      decrement: (double i) =>
          min != null ? (i - delta).clamp(min!, max ?? i) : i - delta,
      style: style,
      // Add a text formatter that only allows integer values and a leading
      // minus sign.
      inputFormatters: <TextInputFormatter>[
        CurrencyInputFormatter(),
      ],
    );
  }
}
