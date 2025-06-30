part of '../home.dart';

class Sidebar extends ConsumerStatefulWidget {
  const Sidebar({super.key});

  @override
  ConsumerState<Sidebar> createState() => SidebarState();
}

class SidebarState extends ConsumerState<Sidebar>
    with SingleTickerProviderStateMixin {
  static ValueNotifier<bool> isSidebarExpanded = ValueNotifier(true);

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
    final sidebarRoutes = ref.watch(
      authNotifierProvider.select(
        (value) => value.sidebar.where(
          (element) => element.permissions.view || true,
        ),
      ),
    );
    final organizationState = ref.watch(organizationNotifierProvider);
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final businessType = ref.watch(businessNotifierProvider)?.businessType;

    return DeferredPointerHandler(
      child: AnimatedContainer(
        clipBehavior: Clip.antiAlias,
        width: isSidebarExpanded.value ? 256 : 78,
        duration: AppStyles.animationDuration,
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Directionality(
          textDirection: TextDirection.ltr, // Force LTR for sidebar
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: AppStyles.boxDecoration
                        .copyWith(color: Colors.transparent),
                    padding: const EdgeInsets.symmetric(
                      vertical: 30,
                      horizontal: 22,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isSidebarExpanded.value = !isSidebarExpanded.value;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Assets.icons.duxbeWhiteLogo
                              .svg(height: 38, width: 43),
                          const SizedBox(width: 16),
                          Assets.icons.duxbeWhiteText.svg(height: 30),
                        ],
                      ),
                    ),
                  ),
                  // Positioned(
                  //   right: -14,
                  //   bottom: -8,
                  //   child: DeferPointer(
                  //     paintOnTop: true,
                  //     child: GestureDetector(
                  //       onTap: () {
                  //         setState(() {
                  //           isSidebarExpanded.value = !isSidebarExpanded.value;
                  //         });
                  //       },
                  //       child: AnimatedRotation(
                  //         turns: isSidebarExpanded.value ? 0 : .5,
                  //         duration: AppStyles.animationDuration,
                  //         child: Container(
                  //           decoration: BoxDecoration(
                  //             shape: BoxShape.circle,
                  //             color: AppColors.primaryColor,
                  //             border: Border.all(color: AppColors.darkBlue),
                  //           ),
                  //           padding: const EdgeInsets.all(6),
                  //           child: const Icon(
                  //             Icons.chevron_left,
                  //             color: AppColors.white,
                  //             size: 20,
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: AppStyles.boxDecoration
                      .copyWith(color: Colors.transparent),
                  child: ListView(
                    children: sidebarRoutes
                        .where((route) =>
                            route.route != 'table' ||
                            businessType == BusinessType.foodAndBeverage)
                        .map(SidebarTile.new)
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: InkWell(
                  onTap: () async {
                    context.goNamed(AppRouter.subscriptionPlans);
                  },
                  child: Container(
                    decoration: AppStyles.boxDecoration
                        .copyWith(color: AppColors.darkBlue),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Assets.icons.crown.svg(height: 20, width: 20),
                        const SizedBox(width: 30),
                        if (organizationState
                                ?.activeSubscriptionDetails?.planId ==
                            1)
                          Text(
                            context.l10n.getPro,
                            style: AppText.mediumB
                                .copyWith(color: AppColors.white),
                          )
                        else if (organizationState
                                ?.activeSubscriptionDetails?.planId ==
                            2)
                          Text(
                            context.l10n.getGenius,
                            style: AppText.mediumB
                                .copyWith(color: AppColors.white),
                          )
                        else
                          Text(
                            context.l10n.subscriptionDetails,
                            style: AppText.mediumB
                                .copyWith(color: AppColors.white),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class SidebarTile extends ConsumerStatefulWidget {
  const SidebarTile(
    this.item, {
    super.key,
    this.isSub = false,
  });

  final RouteItem item;
  final bool isSub;
  @override
  ConsumerState<SidebarTile> createState() => _SidebarTileState();
}

class _SidebarTileState extends ConsumerState<SidebarTile> {
  bool _isExpanded = false;
  bool _isHovered = false;
  bool _isSelected = false;

  final debouncer = Debouncer(milliseconds: 500);
  bool _isCardShowing = false;
  bool _isCardHovering = false;
  String? _hoveredRoute;

  @override
  Widget build(BuildContext context) {
    final appRouter = ref.watch(appRouterProvider);
    final isMobile = MediaQuery.sizeOf(context).width < tabletSize;
    final router = isMobile ? appRouter.mobileRouter : appRouter.desktopRouter;
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    final route = widget.item;
    final isFirstLevel = !widget.isSub;
    final hasChildren = route.subItems.isEmpty ||
        !route.subItems.any((element) => element.visibility);
    final routes = router.routerDelegate.currentConfiguration.routes;
    final lastRoute = routes.lastOrNull;
    final secondLastRoute =
        routes.length >= 2 && routes[routes.length - 2] is GoRoute
            ? routes[routes.length - 2] as GoRoute
            : null;
    final secondRouteIsActive = secondLastRoute?.routes.any(
          (element) {
            if (lastRoute is GoRoute && element is GoRoute) {
              return lastRoute.name == element.name;
            }
            return false;
          },
        ) ??
        false;
    final thisIsSecondLastRoute = secondLastRoute?.name == route.route;

    _isSelected = lastRoute is GoRoute && lastRoute.name == route.route ||
        (secondRouteIsActive && thisIsSecondLastRoute);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          clipBehavior: Clip.hardEdge,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            border: isFirstLevel
                ? null
                : _isSelected
                    ? Border(
                        left: const BorderSide(color: AppColors.primaryColor),
                        right: isRTL
                            ? const BorderSide(color: AppColors.primaryColor)
                            : BorderSide.none,
                      )
                    : Border(
                        left: const BorderSide(color: AppColors.white),
                        right: isRTL
                            ? const BorderSide(color: AppColors.white)
                            : BorderSide.none,
                      ),
          ),
          constraints: BoxConstraints(
            // maxHeight: SidebarState.isSidebarExpanded.value
            //     ? _isExpanded
            //         ? 50 + route.subItems.length * 50
            //         : 50
            //     : 50,
            minHeight: 50,
            maxHeight: !_isExpanded ? 50 : 500,
          ),
          duration: AppStyles.animationDuration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                clipBehavior: Clip.hardEdge,
                borderRadius: isFirstLevel ? BorderRadius.circular(6) : null,
                color: _isHovered
                    ? _isSelected
                        ? isFirstLevel
                            ? const Color(0xff221E56)
                            : const Color(0xff221E56)
                        : isFirstLevel
                            ? const Color(0xff221E56)
                            : const Color(0xff221E56)
                    : _isSelected
                        ? isFirstLevel
                            ? AppColors.darkBlue
                            : AppColors.darkBlue
                        : isFirstLevel
                            ? Colors.transparent
                            : Colors.transparent,
                child: InkWell(
                  onHighlightChanged: (value) {
                    _isHovered = value;
                  },
                  onHover: (value) {
                    setState(() {
                      _isHovered = value;
                    });
                    debouncer.run(() {
                      setState(() {
                        _isCardShowing = _isHovered;
                      });
                    });
                  },
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                    if (hasChildren) context.goNamed(route.route);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: SidebarState.isSidebarExpanded.value ? 14 : 8,
                    ),
                    child: Row(
                      textDirection: TextDirection.ltr,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (route.selectedIcon != null &&
                            route.unselectedIcon != null)
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: _isSelected
                                ? SvgPicture.asset(route.selectedIcon!)
                                : SvgPicture.asset(route.unselectedIcon!),
                          ),
                        if (SidebarState.isSidebarExpanded.value) ...[
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              getLocalizedLabel(
                                context,
                                route.route,
                                route.label,
                              ),
                              style: _isSelected
                                  ? widget.isSub
                                      ? AppText.mediumN
                                          .copyWith(color: AppColors.white)
                                      : !hasChildren
                                          ? AppText.mediumN
                                              .copyWith(color: AppColors.white)
                                          : AppText.mediumN
                                              .copyWith(color: AppColors.white)
                                  : AppText.mediumN
                                      .copyWith(color: AppColors.white),
                            ),
                          ),
                          if (route.route == 'branch' ||
                              route.route == 'users' ||
                              route.route == 'print_barcode') ...[
                            Assets.icons.crown.svg(width: 20),
                            const SizedBox(width: 10),
                          ],
                          if (route.route == 'item_list') ...[
                            InkWell(
                              onTap: () {
                                context..goNamed(route.route)
                                ..goNamed(AppRouter.createItem);
                              },
                              child: const Icon(
                                CupertinoIcons.add,
                                color: AppColors.white,
                                size: 24,
                              ),
                            ),
                          ],
                          if (!hasChildren)
                            AnimatedRotation(
                              duration: AppStyles.animationDuration,
                              turns: !_isExpanded ? 0 : .5,
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: _isSelected
                                    ? AppColors.white
                                    : AppColors.white,
                                size: 24,
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (SidebarState.isSidebarExpanded.value)
                Focus(
                  descendantsAreFocusable: _isExpanded,
                  canRequestFocus: _isExpanded,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: AppColors.white.withOpacity(.09),
                          width: 2,
                        ),
                        right: isRTL
                            ? BorderSide(
                                color: AppColors.white.withOpacity(.09),
                                width: 2,
                              )
                            : BorderSide.none,
                      ),
                    ),
                    margin: EdgeInsets.only(
                      left: isRTL ? 0 : 30,
                      right: isRTL ? 30 : 0,
                    ),
                    child: Column(
                      children: route.subItems
                          .where((element) => element.visibility)
                          .map((e) => SidebarTile(e, isSub: true))
                          .toList(),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (!SidebarState.isSidebarExpanded.value)
          if ((!hasChildren && _isCardShowing) || _isCardHovering)
            Positioned(
              left: isRTL ? null : 80,
              right: isRTL ? 80 : null,
              bottom: route.subItems.length * -32 + 16,
              top: 0,
              child: DeferPointer(
                paintOnTop: true,
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: route.subItems
                        .map(
                          (e) => InkWell(
                            onTap: () {
                              context.goNamed(e.route);
                            },
                            onHover: (value) {
                              setState(() {
                                _isCardHovering = !_isCardHovering;
                                _hoveredRoute = e.route;
                              });
                            },
                            child: Builder(
                              builder: (context) {
                                final lastRoute = router.routerDelegate
                                    .currentConfiguration.routes.last;
                                final isSelected = lastRoute is GoRoute &&
                                    lastRoute.name == e.route;
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _isCardHovering &&
                                            _hoveredRoute == e.route
                                        ? AppColors.white.withOpacity(.9)
                                        : isSelected
                                            ? AppColors.white
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    getLocalizedLabel(
                                      context,
                                      e.route,
                                      e.label,
                                    ),
                                    style: AppText.mediumB.copyWith(
                                      color: isSelected
                                          ? AppColors.primaryColor
                                          : AppColors.white,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
      ],
    );
  }
}

String getLocalizedLabel(BuildContext context, String key, String fallback) {
  final l10n = context.l10n;
  final map = {
    'dashboard': l10n.dashboard,
    'sale': l10n.sale,
    'purchase': l10n.purchase,
    'inventory': l10n.inventory,
    'accounting': l10n.accounting,
    'reports': l10n.reports,
    'users': l10n.users,
    'settings': l10n.settings,
    'branch': l10n.branch,
    'pos': l10n.pos,
    'sale_list': l10n.saleList,
    'order_list': l10n.orderList,
    'sale_return': l10n.saleReturn,
    'customer': l10n.customer,
    'purchasing': l10n.purchase,
    'purchase_list': l10n.purchaseList,
    'purchase_return': l10n.purchaseReturn,
    'supplier': l10n.supplier,
    'item_list': l10n.itemList,
    'category': l10n.category,
    'units': l10n.units,
    'brands': l10n.brands,
    'manage_stock': l10n.manageStock,
    'stock_adjustment': l10n.stockAdjustment,
    'expense': l10n.expense,
    'income': l10n.income,
    'ledger': l10n.ledger,
    'user_list': l10n.userList,
    'user_role': l10n.userRole,
    'print_barcode': l10n.printBarcode,
    'profit_and_loss': l10n.profitAndLoss,
    'invoices': l10n.invoices,
    'invoice': l10n.invoice,
    'quote': l10n.quote,
    'payment_received': l10n.paymentReceived,
    'credit_notes': l10n.creditNotes,
    'chart_of_accounts': l10n.chartOfAccounts,
    'add_new_payment': l10n.addNewPayment,
    'add_new_quote': '${l10n.addNew} ${l10n.quote}',
    'edit_quote': '${l10n.edit} ${l10n.quote}',
    'edit_invoice': '${l10n.edit} ${l10n.invoice}',
    'edit_creditNote': '${l10n.edit} ${l10n.creditNote}',
    'add_new_invoice': '${l10n.addNew} ${l10n.invoice}',
    'add_new_credit_note': '${l10n.addNew} ${l10n.creditNote}',
    'quote_details': '${l10n.quote} ${l10n.details}',
    'invoice_details': '${l10n.invoice} ${l10n.details}',
    'credit_note_details': '${l10n.creditNote} ${l10n.details}',
    'create_item': l10n.addItem,
  };
  return map[key] ?? fallback;
}
