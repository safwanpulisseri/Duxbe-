import 'package:defer_pointer/defer_pointer.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/home/presentation/online_store_dialog.dart';
import 'package:duxbe/features/organization/controller/organization_notifier.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

part 'widgets/chat.dart';
part 'widgets/logout.dart';
part 'widgets/more.dart';
part 'widgets/navigation_bar.dart';
part 'widgets/sidebar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({required this.child, super.key});

  final Widget child;
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _showChat = false;
  @override
  void initState() {
    super.initState();
    SidebarState.isSidebarExpanded.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBgColor,
      body: Padding(
        padding: ResponsiveWidget.isSmallScreen(context) ? EdgeInsets.zero : const EdgeInsets.all(12),
        child: ResponsiveWidget(
          smallScreen: widget.child,
          largeScreen: Stack(
            children: [
              Row(
                children: [
                  AnimatedContainer(
                    duration: AppStyles.animationDuration,
                    width: SidebarState.isSidebarExpanded.value ? 256 : 78,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: [
                        const CustomAppBar(),
                        const SizedBox(height: 12),
                        Expanded(child: widget.child),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text('sales@hancod.com'),
                            const SizedBox(width: 12),
                            // Version number
                            FutureBuilder<PackageInfo>(
                              future: PackageInfo.fromPlatform(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text(
                                    '${context.l10n.version} ${snapshot.data?.version}+${snapshot.data?.buildNumber}',
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Row(
                children: [
                  Sidebar(),
                  SizedBox(width: 20),
                  Spacer(),
                ],
              ),
              if (_showChat)
                const Positioned(
                  bottom: 90,
                  right: 20,
                  height: 800,
                  width: 400,
                  child: ChatScreen(),
                ),
              Positioned(
                bottom: 30,
                right: 0,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _showChat = !_showChat;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(100), bottomLeft: Radius.circular(100)),
                      gradient: LinearGradient(
                        colors: [Color(0xff72EDF2), Color(0xff5151E5)],
                      ),
                    ),
                    child: Assets.images.ai.image(height: 30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomAppBar extends ConsumerStatefulWidget {
  const CustomAppBar({super.key});

  @override
  ConsumerState<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends ConsumerState<CustomAppBar> {
  late final GoRouter router;
  @override
  void initState() {
    super.initState();
    final appRouter = ref.read(appRouterProvider);
    router = appRouter.desktopRouter;

    // Listen to route changes
    router.routerDelegate.addListener(_handleRouteChange);
  }

  void _handleRouteChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    router.routerDelegate.removeListener(_handleRouteChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appRouter = ref.watch(appRouterProvider);
    final isMobile = MediaQuery.sizeOf(context).width < tabletSize;
    final router = isMobile ? appRouter.mobileRouter : appRouter.desktopRouter;

    final currentRoute = router.routerDelegate.currentConfiguration.last.route.name;
    final currentOrg = ref.watch(organizationNotifierProvider);
    final activeSubscriptionDetails = currentOrg?.activeSubscriptionDetails;

    final currentPlan = activeSubscriptionDetails?.planDetails;

    final user = ref.watch(authNotifierProvider).user;
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${context.l10n.pages} / ',
                      style: AppText.mediumN.copyWith(color: AppColors.greyText.withOpacity(.5)),
                    ),
                    TextSpan(
                      text: getLocalizedLabel(context, currentRoute ?? '', currentRoute ?? ''),
                      style: AppText.mediumN.copyWith(color: AppColors.greyText),
                    ),
                  ],
                ),
              ),
              Text(
                getLocalizedLabel(context, currentRoute ?? '', currentRoute ?? ''),
                style: AppText.heading5.copyWith(color: AppColors.primaryColor),
              ),
            ],
          ),
          const Spacer(),
          if (currentOrg?.trialEndDate != null &&
              (currentOrg?.trialEndDate!.isAfter(DateTime.now()) ?? false) &&
              currentPlan == null)
            Builder(
              builder: (context) {
                final difference = currentOrg?.trialEndDate?.difference(DateTime.now());
                String timeText;
                if (difference!.inDays > 0) {
                  timeText = '${difference.inDays} ${context.l10n.days}';
                } else if (difference.inHours > 0) {
                  timeText = '${difference.inHours} ${'Hours'}';
                } else {
                  timeText = '${difference.inMinutes} ${'Minutes'}';
                }
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.only(left: 14, right: 6, top: 12, bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.lightPurple,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${context.l10n.trialPeriod} $timeText',
                    style: AppText.mediumB.copyWith(color: AppColors.brandViolet),
                  ),
                );
              },
            ),
          if (currentPlan != null)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.only(left: 14, right: 6, top: 12, bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.lightPurple,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Text(
                    currentPlan.name,
                    style: AppText.mediumB.copyWith(color: AppColors.brandViolet),
                  ),
                  const SizedBox(width: 12),
                  Assets.icons.crown.svg(height: 20),
                ],
              ),
            ),
          // if (ref.watch(businessNotifierProvider)?.businessType == BusinessType.foodAndBeverage)
          //   InkWell(
          //     onTap: () => context.goNamed(AppRouter.tableManagement),
          //     child: Container(
          //       margin: const EdgeInsets.only(right: 12),
          //       padding: const EdgeInsets.only(left: 12, right: 6, top: 15, bottom: 12),
          //       decoration: BoxDecoration(
          //         color: const Color(0xff25CCAC).withOpacity(.1),
          //         borderRadius: BorderRadius.circular(10),
          //       ),
          //       child: Row(
          //         children: [
          //           Text(context.l10n.table, style: AppText.mediumB.copyWith(color: const Color(0xff25CCAC))),
          //           const SizedBox(width: 12),
          //           const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xff25CCAC), size: 16),
          //         ],
          //       ),
          //     ),
          //   ),

          InkWell(
            onTap: () => showDialog<void>(context: context, builder: (context) => const OnlineStoreDialog()),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.only(left: 12, right: 6, top: 15, bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xff25CCAC).withOpacity(.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Text(context.l10n.goToOnlineStore, style: AppText.mediumB.copyWith(color: const Color(0xff25CCAC))),
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xff25CCAC), size: 16),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.only(left: 14, right: 6, top: 4, bottom: 4),
            decoration: BoxDecoration(
              color: AppColors.scaffoldBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: MenuAnchor(
              builder: (context, controller, widget) {
                return Row(
                  children: [
                    Text(ref.watch(businessNotifierProvider)?.name ?? ''),
                    IconButton(
                      constraints: const BoxConstraints(),
                      splashRadius: 20,
                      padding: const EdgeInsets.all(4),
                      onPressed: () {
                        if (controller.isOpen) return controller.close();
                        controller.open();
                      },
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    ),
                  ],
                );
              },
              menuChildren: ref
                      .watch(authNotifierProvider)
                      .user
                      ?.accessedBrances
                      .map(
                        (e) => MenuItemButton(
                          style: MenuItemButton.styleFrom(
                            foregroundColor: AppColors.primaryColor,
                          ),
                          onPressed: () {
                            ref.read(businessNotifierProvider.notifier).setBusiness(e.businessId);
                          },
                          child: Text(e.name),
                        ),
                      )
                      .toList() ??
                  [],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.only(left: 14, right: 6, top: 4, bottom: 4),
            decoration: BoxDecoration(
              color: AppColors.scaffoldBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: MenuAnchor(
              builder: (context, controller, widget) {
                return Row(
                  children: [
                    if (ref.watch(localeProvider).languageCode == 'en')
                      Row(
                        children: [
                          Assets.icons.usCountry.svg(height: 30),
                          const SizedBox(width: 8),
                          Text(context.l10n.english),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Assets.icons.qatarCountry.svg(height: 30),
                          const SizedBox(width: 8),
                          Text(context.l10n.arabic),
                        ],
                      ),
                    IconButton(
                      constraints: const BoxConstraints(),
                      splashRadius: 20,
                      padding: const EdgeInsets.all(4),
                      onPressed: () {
                        if (controller.isOpen) return controller.close();
                        controller.open();
                      },
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    ),
                  ],
                );
              },
              menuChildren: [
                MenuItemButton(
                  style: MenuItemButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                  ),
                  onPressed: () {
                    ref.read(localeProvider.notifier).state = const Locale('en');
                  },
                  child: Row(
                    children: [
                      Assets.icons.usCountry.svg(height: 30),
                      const SizedBox(width: 8),
                      Text(context.l10n.english),
                    ],
                  ),
                ),
                MenuItemButton(
                  style: MenuItemButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                  ),
                  onPressed: () {
                    ref.read(localeProvider.notifier).state = const Locale('ar');
                  },
                  child: Row(
                    children: [
                      Assets.icons.qatarCountry.svg(height: 30),
                      const SizedBox(width: 8),
                      Text(context.l10n.arabic),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),
          MenuAnchor(
            alignmentOffset: const Offset(40, 0),
            menuChildren: [
              MenuItemButton(
                style: MenuItemButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                ),
                onPressed: () {
                  context.goNamed(AppRouter.profile);
                },
                child: Text(context.l10n.myProfile),
              ),
              MenuItemButton(
                style: MenuItemButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                ),
                onPressed: () async {
                  final logout = await showDialog<bool?>(
                    context: context,
                    builder: (context) => const LogoutDialog(),
                  );
                  if (logout ?? false) {
                    await ref.read(authNotifierProvider.notifier).signOut();
                  }
                },
                child: Text(context.l10n.logout),
              ),
            ],
            builder: (context, controller, widget) {
              return Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? '',
                        style: AppText.xLargeSB.copyWith(color: const Color(0xff4F4F4F)),
                      ),
                      Text(
                        user?.role?.name.displayCase ?? '',
                        style: AppText.smallN.copyWith(color: const Color(0xff4F4F4F)),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  CircleAvatar(
                    backgroundColor: AppColors.lightPurple,
                    backgroundImage: ref.watch(authNotifierProvider).user?.image != null
                        ? NetworkImage(
                            ref.watch(authNotifierProvider).user!.image!,
                          )
                        : Assets.images.photo.image().image,
                  ),
                  IconButton(
                    constraints: const BoxConstraints(),
                    splashRadius: 20,
                    padding: const EdgeInsets.all(4),
                    onPressed: () {
                      if (controller.isOpen) return controller.close();
                      controller.open();
                    },
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
