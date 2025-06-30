part of '../home.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  Row _titleRow(String title) => Row(
        children: [
          Container(
            height: 16,
            width: 4,
            color: AppColors.brandViolet,
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: AppText.mediumSB.copyWith(color: AppColors.stormyBlue),
          ),
        ],
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionsMap = ref.watch(
      authNotifierProvider.select(
        (value) => value.sidebar.fold<Map<String, Permissions>>(
          {},
          (map, item) {
            map[item.route] = item.permissions;
            for (final subItem in item.subItems) {
              map[subItem.route] = subItem.permissions;
            }
            return map;
          },
        ),
      ),
    );

    final rawSidebarRoutes = <String, List<RouteItem>>{
      AppRouter.l10n.billing: [
        RouteItem(
          route: AppRouter.pos,
          label: AppRouter.l10n.pos,
          selectedIcon: Assets.icons.posUnselected.path,
          permissions: Permissions(),
          visibility: true,
          sortOrder: 1,
        ),
        RouteItem(
          route: AppRouter.saleList,
          label: context.l10n.saleList,
          selectedIcon: Assets.icons.saleList.path,
          permissions: Permissions(),
          visibility: true,
          sortOrder: 2,
        ),
        RouteItem(
          route: AppRouter.orderList,
          label: context.l10n.orderList,
          selectedIcon: Assets.icons.orderlistSelected.path,
          permissions: Permissions(),
          visibility: true,
          sortOrder: 3,
        ),
        RouteItem(
          route: AppRouter.customer,
          label: AppRouter.l10n.customer,
          selectedIcon: Assets.icons.customerListMobile.path,
          permissions: Permissions(),
          visibility: true,
          sortOrder: 1,
        ),
      ],
      AppRouter.l10n.purchase: [
        RouteItem(
          route: AppRouter.purchase,
          label: AppRouter.l10n.purchase,
          selectedIcon: Assets.icons.purchaseMobile.path,
          permissions: Permissions(),
          visibility: true,
          sortOrder: 1,
        ),
        RouteItem(
          route: AppRouter.purchaseList,
          label: AppRouter.l10n.purchaseList,
          selectedIcon: Assets.icons.purchaseListMobile.path,
          permissions: Permissions(),
          visibility: true,
          sortOrder: 1,
        ),
        RouteItem(
          route: AppRouter.supplier,
          label: context.l10n.supplier,
          selectedIcon: Assets.icons.supplierListMobile.path,
          permissions: Permissions(),
          visibility: true,
          sortOrder: 2,
        ),
      ],
      AppRouter.l10n.inventory: [
        RouteItem(
          route: AppRouter.itemList,
          label: AppRouter.l10n.itemList,
          selectedIcon: Assets.icons.itemListMobile.path,
          permissions: Permissions(),
          visibility: true,
          sortOrder: 1,
        ),
        RouteItem(
          route: AppRouter.category,
          label: AppRouter.l10n.category,
          selectedIcon: Assets.icons.categoryMobile.path,
          permissions: Permissions(),
          visibility: true,
          sortOrder: 1,
        ),
        RouteItem(
          route: AppRouter.units,
          label: AppRouter.l10n.units,
          selectedIcon: Assets.icons.unitsMobile.path,
          permissions: Permissions(),
          visibility: true,
          sortOrder: 1,
        ),
        RouteItem(
          route: AppRouter.brands,
          label: AppRouter.l10n.brands,
          selectedIcon: Assets.icons.brandsMobile.path,
          permissions: Permissions(),
          visibility: true,
          sortOrder: 1,
        ),
        RouteItem(
          route: AppRouter.manageStock,
          label: AppRouter.l10n.manageStock,
          selectedIcon: Assets.icons.saleList.path,
          permissions: Permissions(),
          visibility: true,
          sortOrder: 1,
        ),
        RouteItem(
          route: AppRouter.stockAdjusments,
          label: AppRouter.l10n.stockAdjustment,
          selectedIcon: Assets.icons.saleList.path,
          permissions: Permissions(),
          visibility: true,
          sortOrder: 1,
        ),
        RouteItem(
          route: AppRouter.printBarcodeList,
          label: AppRouter.l10n.printBarcode,
          selectedIcon: Assets.icons.saleList.path,
          permissions: Permissions(),
          visibility: true,
          sortOrder: 1,
        ),
      ],
      AppRouter.l10n.accounting: [
        RouteItem(
          route: AppRouter.income,
          label: AppRouter.l10n.income,
          selectedIcon: Assets.icons.incomeMobile.path,
          permissions: Permissions(),
          visibility: true,
          sortOrder: 1,
        ),
        RouteItem(
          route: AppRouter.expense,
          label: AppRouter.l10n.expense,
          selectedIcon: Assets.icons.expenseMobile.path,
          permissions: Permissions(),
          visibility: true,
          sortOrder: 1,
        ),
        RouteItem(
          route: AppRouter.profitAndLoss,
          label: 'Profit and Loss',
          selectedIcon: Assets.icons.ledgerMobile.path,
          permissions: Permissions(),
          visibility: true,
          sortOrder: 1,
        ),
      ],
      AppRouter.l10n.reports: [
        RouteItem(
          route: AppRouter.reports,
          label: AppRouter.l10n.reports,
          selectedIcon: Assets.icons.reportsMobile.path,
          permissions: Permissions(),
          visibility: true,
          sortOrder: 1,
        ),
      ],
      AppRouter.l10n.users: [
        RouteItem(
          route: AppRouter.userList,
          label: AppRouter.l10n.userList,
          selectedIcon: Assets.icons.userListMobile.path,
          permissions: Permissions(),
          visibility: true,
          sortOrder: 1,
        ),
        RouteItem(
          route: AppRouter.userRole,
          label: AppRouter.l10n.userRole,
          selectedIcon: Assets.icons.userRoleMobile.path,
          permissions: Permissions(),
          visibility: true,
          sortOrder: 1,
        ),
      ],
      AppRouter.l10n.settings: [
        RouteItem(
          route: AppRouter.userSettings,
          label: AppRouter.l10n.myProfile,
          selectedIcon: Assets.icons.userListMobile.path,
          permissions: Permissions(),
          visibility: true,
          sortOrder: 1,
        ),
        RouteItem(
          route: AppRouter.branch,
          label: AppRouter.l10n.branch,
          selectedIcon: Assets.icons.purchaseUnselected.path,
          permissions: Permissions(),
          visibility: true,
          sortOrder: 1,
        ),
        RouteItem(
          route: AppRouter.settings,
          label: AppRouter.l10n.settings,
          selectedIcon: Assets.icons.settingsMobile.path,
          permissions: Permissions(),
          visibility: true,
          sortOrder: 1,
        ),
        RouteItem(
          route: AppRouter.privacyPolicy,
          label: AppRouter.l10n.privacyPolicy,
          selectedIcon: Assets.icons.privacyPolicy.path,
          permissions: Permissions(),
          visibility: true,
          sortOrder: 1,
        ),
        RouteItem(
          route: AppRouter.termsAndConditions,
          label: AppRouter.l10n.termsAndConditions,
          selectedIcon: Assets.icons.termsAndConditions.path,
          permissions: Permissions(),
          visibility: true,
          sortOrder: 1,
        ),
      ],
    };
    final user = ref.watch(authNotifierProvider).user;

    // Filter routes based on permissions
    final sidebarRoutes = <String, List<RouteItem>>{};
    for (final entry in rawSidebarRoutes.entries) {
      final filteredRoutes = entry.value.where((route) {
        // Use a default Permissions object if not found, assuming view=false
        route.permissions = permissionsMap[route.route] ?? Permissions();
        return route.permissions.view || true; // Keep the || true logic from sidebar for now
      }).toList();

      if (filteredRoutes.isNotEmpty) {
        sidebarRoutes[entry.key] = filteredRoutes;
      }
    }

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    CircleAvatar(
                      backgroundColor: AppColors.lightPurple,
                      backgroundImage:
                          user?.image != null ? NetworkImage(user!.image!) : Assets.images.photo.provider(),
                    ),
                    Text(
                      user?.name ?? '',
                      style: AppText.xLargeM.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user?.role?.name.displayCase ?? '',
                      style: AppText.mediumN.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 28),
                    ...[
                      for (final item in sidebarRoutes.entries
                          .where((element) => element.value.any((route) => route.permissions.view)))
                        Builder(
                          builder: (context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _titleRow(item.key),
                                const SizedBox(height: 16),
                                GridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: 4,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  children: [
                                    for (final route in item.value.where((route) => route.permissions.view))
                                      GestureDetector(
                                        onTap: () => context.pushNamed(route.route),
                                        child: Column(
                                          children: [
                                            Container(
                                              height: 50,
                                              width: 50,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF9F9F9),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              padding: const EdgeInsets.all(12),
                                              child: SvgPicture.asset(
                                                route.selectedIcon!,
                                                height: 36,
                                                width: 36,
                                                colorFilter: const ColorFilter.mode(
                                                  AppColors.primaryColor,
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              route.label,
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 30),
                              ],
                            );
                          },
                        ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            child: AppButton(
              style: ButtonStyles.secondary,
              color: AppColors.textfieldOutline,
              onPress: () async {
                final logout = await showDialog<bool?>(
                  context: context,
                  builder: (context) => const LogoutDialog(),
                );
                if (logout ?? false) {
                  await ref.read(authNotifierProvider.notifier).signOut();
                }
              },
              label: Text(
                AppRouter.l10n.logout,
                style: AppText.mediumSB.copyWith(color: AppColors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
