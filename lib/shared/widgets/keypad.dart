import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:hancod_theme/hancod_theme.dart';

class Keypad extends StatelessWidget {
  const Keypad({
    required this.onAmountEntered,
    required this.child,
    super.key,
  });
  final Widget child;

  static const _keys = [
    ['7', '4', '3', '00'],
    ['8', '5', '2', '0'],
    ['9', '6', '1', '.'],
  ];

  final void Function(String amount) onAmountEntered;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveWidget.isSmallScreen(context);

    if (isMobile) {
      return Row(
        children: [
          ..._keys.map(
            (e) => Expanded(
              child: Column(
                children: [
                  ...e.map(
                    (e) => Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Material(
                                clipBehavior: Clip.hardEdge,
                                borderRadius: BorderRadius.circular(18),
                                color: AppColors.textfield,
                                child: InkWell(
                                  onTap: () {
                                    onAmountEntered(e);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Text(
                                      e,
                                      style: AppText.xLargeB,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          child,
        ],
      );
    }

    return SizedBox(
      height: 300,
      child: Row(
        children: [
          ..._keys.map(
            (e) => Expanded(
              child: Column(
                children: [
                  ...e.map(
                    (e) => Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Material(
                              clipBehavior: Clip.hardEdge,
                              borderRadius: BorderRadius.circular(18),
                              color: AppColors.textfield,
                              child: InkWell(
                                onTap: () {
                                  onAmountEntered(e);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 36,
                                    vertical: 12,
                                  ),
                                  child: Text(
                                    e,
                                    style: AppText.heading3,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
