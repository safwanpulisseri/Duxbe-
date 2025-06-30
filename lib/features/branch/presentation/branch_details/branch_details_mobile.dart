import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/branch/branch.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';

class BranchDetailsScreenMobile extends ConsumerStatefulWidget {
  const BranchDetailsScreenMobile({super.key});
  @override
  ConsumerState<BranchDetailsScreenMobile> createState() =>
      _BranchDetailsScreenMobileState();
}

class _BranchDetailsScreenMobileState
    extends ConsumerState<BranchDetailsScreenMobile> {
  @override
  Widget build(BuildContext context) {
    final branch = ref.watch(branchProvider);
    final businessId = branch?.businessId ??
        ref.read(businessNotifierProvider)?.businessId ??
        '';
    final tiles = <DetailsTile>[
      DetailsTile(
        icon: Container(
            padding: const EdgeInsets.all(7),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.lightBlue,
            ),
            child: Assets.icons.saleList.svg(height: 25,
              width: 25,
              colorFilter: const ColorFilter.mode(AppColors.black, BlendMode.srcIn),),),
        title: context.l10n.businessSettings,
        onTap: () {
          AppRouter.pushNamed(AppRouter.businessSettings,
            pathParameters: {'business_id': businessId},
          );
        },
      ),
      DetailsTile(
          icon: Container(
            padding: const EdgeInsets.all(7),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.lightBlue,
            ),
            child: Assets.icons.percent.svg(height: 25,
              width: 25,
              colorFilter: const ColorFilter.mode(AppColors.black, BlendMode.srcIn),),),
        title: context.l10n.taxSettings,
        onTap: () {
          AppRouter.pushNamed(AppRouter.taxSettings,
            pathParameters: {'business_id': businessId},
          );
        },
      ),
      DetailsTile(
        icon: Container(
            padding: const EdgeInsets.all(7),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.lightBlue,
            ),
            child: Assets.icons.printSettings.svg(height: 25,
              width: 25,
              colorFilter: const ColorFilter.mode(AppColors.black, BlendMode.srcIn),),),
        title: context.l10n.printSettings,
        onTap: () {
          AppRouter.pushNamed(AppRouter.printSettings,
            pathParameters: {'business_id': businessId},
          );
        },
      ),
      DetailsTile(
        icon: Container(
            padding: const EdgeInsets.all(7),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.lightBlue,
            ),
            child: Assets.icons.generalSettings.svg(height: 25,
              width: 25,
              colorFilter: const ColorFilter.mode(AppColors.black, BlendMode.srcIn),),),
        title: context.l10n.generalSettings,
        onTap: () {
          AppRouter.pushNamed(AppRouter.generalSettings,
            pathParameters: {'business_id': businessId},
          );
        },
      ),
      // BranchDetailsTile(
      //   title: 'Notification Settings',
      //   onTap: () {
      //     AppRouter.pushNamed(AppRouter.notificationSettings, pathParameters: {'business_id': businessId});
      //   },
      // ),
      // BranchDetailsTile(
      //   title: 'Integration Settings',
      //   onTap: () {
      //     AppRouter.pushNamed(AppRouter.integrationSettings, pathParameters: {'business_id': businessId});
      //   },
      // ),
    ];
    print('${branch?.businessId ?? ''}branch details');
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(context.l10n.menuSettings),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        itemCount: tiles.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final tile = tiles[index];
          return InkWell(
            borderRadius: AppStyles.boxDecoration.borderRadius!
                .resolve(TextDirection.ltr),
            splashColor: Colors.transparent,
            onTap: tile.onTap,
            child: Ink(
              decoration: AppStyles.boxDecoration,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    if (tile.icon != null) ...[
                      tile.icon!,
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(tile.title,
                              style: AppText.mediumSB
                                  .copyWith(color: AppColors.black),
                          ),
                          if (tile.subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(tile.subtitle!,
                                style: AppText.smallN
                                    .copyWith(color: AppColors.stormyBlue),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(CupertinoIcons.chevron_right,
                      color: AppColors.brandViolet,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class DetailsTile {
  DetailsTile({
    required this.title,
    required this.onTap,
    this.icon,
    this.subtitle,
  });
  final Widget? icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
}
