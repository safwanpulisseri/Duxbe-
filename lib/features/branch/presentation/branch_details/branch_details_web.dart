import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/branch/branch.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';

class BranchDetailsScreenWeb extends ConsumerStatefulWidget {
  const BranchDetailsScreenWeb({super.key, this.business});
  final Business? business;

  @override
  ConsumerState<BranchDetailsScreenWeb> createState() => _BranchDetailsScreenWebState();
}

class _BranchDetailsScreenWebState extends ConsumerState<BranchDetailsScreenWeb> with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return switch (ref.watch(authNotifierProvider).status) {
      AuthStatus.success => FormBuilder(
          key: _formKey,
          child: DefaultTabController(
            length: 5,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 200,
                  decoration: AppStyles.boxDecoration,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          context.l10n.settings,
                          style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
                        ),
                      ),
                      Expanded(
                        child: RotatedBox(
                          quarterTurns: 1,
                          child: TabBar(
                            tabAlignment: TabAlignment.start,
                            labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                            isScrollable: true,
                            // indicatorPadding: const EdgeInsets.symmetric(horizontal: 12),
                            indicator: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(8)),
                            labelStyle: AppText.largeSB.copyWith(color: AppColors.white),
                            splashFactory: NoSplash.splashFactory,
                            splashBorderRadius: BorderRadius.circular(8),
                            unselectedLabelStyle: AppText.largeSB.copyWith(color: AppColors.stormyBlue),
                            tabs: [
                              context.l10n.businessSettings,
                              context.l10n.taxSettings,
                              context.l10n.printSettings,
                              context.l10n.generalSettings,
                              context.l10n.whatsappSettings,
                            ]
                                .map(
                                  (e) => RotatedBox(
                                    quarterTurns: -1,
                                    child: Row(
                                      children: [
                                        Text(
                                          '   $e',
                                          textAlign: TextAlign.left,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                const Expanded(
                  child: TabBarView(
                    children: [
                      BusinessSettingsScreenWeb(),
                      TaxSettingsScreenWeb(),
                      PrintSettingsScreenWeb(),
                      GeneralSettingsScreenWeb(),
                      WhatsappSettingsScreenWeb(),
                      // CustomFieldsScreenWeb(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      _ => const SizedBox(),
    };
  }

  @override
  bool get wantKeepAlive => true;
}
