import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:hancod_theme/hancod_theme.dart';

class NoDataViewWidget extends StatelessWidget {
  const NoDataViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.l10n.hmmm,
              style: AppText.heading3,
            ),
            const SizedBox(height: 8),
            Assets.images.noData.image(height: 170),
            const SizedBox(height: 8),
            Text(
              context.l10n.noData,
              style: AppText.heading5,
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.noDataAvailable,
              style: AppText.largeM,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
