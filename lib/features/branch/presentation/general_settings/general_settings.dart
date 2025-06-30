import 'package:duxbe/features/branch/branch.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';

export 'general_settings_mobile.dart';
export 'general_settings_web.dart';

class GeneralSettingsScreen extends ConsumerWidget {
  const GeneralSettingsScreen({super.key, this.businessId});
  final String? businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBgColor,
      body: ref.watch(businessProvider(businessId)).when(
            data: (business) => ProviderScope(
              overrides: [branchProvider.overrideWith((ref) => business)],
              child: const ResponsiveWidget(
                smallScreen: GeneralSettingsScreenMobile(),
                largeScreen: GeneralSettingsScreenWeb(),
              ),
            ),
            error: (error, stackTrace) => Center(child: Text(error.toString())),
            loading: Loader.new,
          ),
    );
  }
}
