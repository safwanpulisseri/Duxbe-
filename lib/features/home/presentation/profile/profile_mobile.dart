import 'package:duxbe/features/branch/branch.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';

class ProfileScreenMobile extends ConsumerStatefulWidget {
  const ProfileScreenMobile({super.key});

  @override
  ConsumerState<ProfileScreenMobile> createState() => _ProfileScreenMobileState();
}

class _ProfileScreenMobileState extends ConsumerState<ProfileScreenMobile> {
  @override
  Widget build(BuildContext context) {
    final tiles = <DetailsTile>[
      DetailsTile(
        title: context.l10n.personalDetails,
        onTap: () {
          AppRouter.pushNamed(AppRouter.profile);
        },
      ),
      DetailsTile(
        title: context.l10n.changePassword,
        onTap: () {
          AppRouter.pushNamed(AppRouter.changePassword);
        },
      ),
    ];
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(context.l10n.branchDetails),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        itemCount: tiles.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final tile = tiles[index];
          return InkWell(
            borderRadius: AppStyles.boxDecoration.borderRadius!.resolve(TextDirection.ltr),
            splashColor: Colors.transparent,
            onTap: tile.onTap,
            child: Ink(
              decoration: AppStyles.boxDecoration,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                          Text(tile.title, style: AppText.mediumSB.copyWith(color: AppColors.black)),
                          if (tile.subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(tile.subtitle!, style: AppText.smallN.copyWith(color: AppColors.stormyBlue)),
                          ],
                        ],
                      ),
                    ),
                    const Icon(CupertinoIcons.chevron_right, color: AppColors.brandViolet),
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
