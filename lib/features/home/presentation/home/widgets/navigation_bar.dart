part of '../home.dart';

class HomeNavigationBar extends StatefulWidget {
  const HomeNavigationBar({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  State<HomeNavigationBar> createState() => _HomeNavigationBarState();
}

class _HomeNavigationBarState extends State<HomeNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              offset: Offset(0, -6),
              blurRadius: 22,
              spreadRadius: 22,
              color: Colors.black12,
            ),
          ],
        ),
        child: ColoredBox(
          color: Colors.white,
          child: SafeArea(
            maintainBottomViewPadding: true,
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              unselectedFontSize: 10,
              selectedFontSize: 10,
              elevation: 0,
              backgroundColor: Colors.white,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Assets.icons.homeUnselected.svg(),
                  activeIcon: Assets.icons.homeSelected.svg(),
                  label: context.l10n.dashboard,
                ),
                BottomNavigationBarItem(
                  icon: Assets.icons.orderlistUnselected.svg(),
                  activeIcon: Assets.icons.orderlistSelected.svg(),
                  label: context.l10n.orderList,
                ),
                BottomNavigationBarItem(
                  icon: Assets.icons.posUnselected.svg(),
                  activeIcon: Assets.icons.posSelected.svg(),
                  label: context.l10n.pos,
                ),
                BottomNavigationBarItem(
                  icon: Assets.icons.moreUnselected.svg(),
                  activeIcon: Assets.icons.moreSelected.svg(),
                  label: context.l10n.more,
                ),
              ],
              currentIndex: widget.navigationShell.currentIndex,
              onTap: (index) async {
                widget.navigationShell.goBranch(
                  index,
                  initialLocation: true,
                  // initialLocation: RegExp('[^/]*[/]+[^/]*[/]+').hasMatch(
                  //   widget.navigationShell.shellRouteContext.routerState.fullPath ?? '',
                  // ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
