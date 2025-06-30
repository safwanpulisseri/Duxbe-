import 'package:duxbe/features/reservations/reservations.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';

class ReservationTabsScreenWeb extends ConsumerStatefulWidget {
  const ReservationTabsScreenWeb({super.key});

  @override
  ConsumerState<ReservationTabsScreenWeb> createState() =>
      _ReservationTabsScreenWebState();
}

class _ReservationTabsScreenWebState
    extends ConsumerState<ReservationTabsScreenWeb> {
  @override
  Widget build(BuildContext context) {
    final tabIndex = GoRouter.of(context)
            .routerDelegate
            .currentConfiguration
            .uri
            .queryParameters['tab_index'] ??
        '0';
    ref.listen(selectNotificationStreamProvider, (previous, next) {
      if (next.hasValue) {
        debugPrint('Notification: $next');
        ref.read(reservationNotifierProvider.notifier).getTableReservations();
        Alert.showSnackBar('You have a new notification');
      }
    });
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: AppStyles.boxDecoration,
      child: DefaultTabController(
        length: 2,
        initialIndex: int.tryParse(tabIndex) ?? 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ColoredBox(
                  color: const Color(0xffF8F8F8),
                  child: TabBar(
                    isScrollable: true,
                    indicator: BoxDecoration(
                      color: AppColors.secondaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    tabAlignment: TabAlignment.start,
                    indicatorColor: Colors.transparent,
                    overlayColor: WidgetStateColor.resolveWith(
                      (states) {
                        if (states.contains(WidgetState.disabled)) {
                          return AppColors.secondaryBackgroundColor;
                        } else {
                          return AppColors.secondaryBackgroundColor;
                        }
                      },
                    ),
                    labelStyle: AppText.sb24.copyWith(
                      color: AppColors.white,
                      fontFamily: 'Lato',
                    ),
                    unselectedLabelStyle: AppText.n20.copyWith(
                      color: const Color(0xff6B7283),
                      fontFamily: 'Lato',
                    ),
                    tabs: [
                      'Reservation',
                      'All table',
                    ].map((e) => Tab(text: e)).toList(),
                  ),
                ),
                //TODO: Need this?
                // Expanded(
                //   child: AppToggleForm(
                //     mainAxisAlignment: MainAxisAlignment.end,
                //     name: 'auto_assign',
                //     hint: AppRouter.l10n.autoAssignTable,
                //     initialValue: ref
                //         .watch(authNotifierProvider)
                //         .autoAssignTable,
                //     onChanged: (val) {
                //       if (val == null) return;
                //       ref
                //           .read(authNotifierProvider.notifier)
                //           .setAutoAssignTable(val);
                //     },
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: 20),
            const Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                children: [
                  ReservationsScreen(),
                  TablesScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
