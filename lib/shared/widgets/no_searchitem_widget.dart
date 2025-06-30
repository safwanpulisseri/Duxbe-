import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:hancod_theme/hancod_theme.dart';

class NoSearchItemWidget extends StatelessWidget {
  const NoSearchItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Custom egg illustration
            Text(
              context.l10n.ooops,
              style: AppText.heading3,
            ),
            const SizedBox(height: 8),
            Assets.icons.noResults.svg(
              height: MediaQuery.of(context).size.height * 0.3,
              width: double.infinity,
            ),
            const SizedBox(height: 28),
            Text(
              context.l10n.noResults,
              style: AppText.heading5,
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n
                  .sorryThereAreNoResultsForThisSearchPleaseTryAnotherPhrase,
              style: AppText.largeM.copyWith(
                height: 1.5,
                letterSpacing: 0.1,
                wordSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
