import 'package:another_flushbar/flushbar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A widget to display the offline alert dialog.
class NewOrderDialog extends ConsumerStatefulWidget {
  const NewOrderDialog({
    super.key,
    this.navigatorKey,
    this.child,
  });

  final GlobalKey<NavigatorState>? navigatorKey;
  final Widget? child;

  @override
  NewOrderDialogState createState() => NewOrderDialogState();
}

/// The [NewOrderDialog] widget state.
class NewOrderDialogState extends ConsumerState<NewOrderDialog> {
  bool displayed = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      ref
          .watch(supabaseProvider)
          .channel('sales')
          .onPostgresChanges(
            table: 'sales',
            event: PostgresChangeEvent.insert,
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'business_id',
              value: ref.watch(businessNotifierProvider)?.businessId ?? '00000000-0000-0000-0000-000000000000',
            ),
            callback: (payload) {
              final businessId = ref.read(businessNotifierProvider)?.businessId;
              if (!displayed &&
                  payload.newRecord['order_mode'] == true &&
                  payload.newRecord['platform'] != 'Duxbe' &&
                  businessId == payload.newRecord['business_id']) {
                ref.read(audioPlayerProvider).play(AssetSource('sounds/notif.mp3'));
                displayed = true;

                Flushbar<void>(
                  messageText: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xff8068EB),
                        child: Icon(Icons.notifications_on_outlined, color: AppColors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.l10n.newOrder, style: AppText.largeB.copyWith(color: AppColors.black)),
                          const SizedBox(height: 4),
                          Text(
                            payload.newRecord['sale_invoice'].toString(),
                            style: AppText.mediumN.copyWith(color: AppColors.black),
                          ),
                        ],
                      ),
                    ],
                  ),
                  margin: EdgeInsets.only(left: MediaQuery.of(context).size.width - 800, right: 20, bottom: 20),
                  maxWidth: 400,
                  backgroundColor: const Color(0xFFF9F3F9),
                  borderRadius: BorderRadius.circular(10),
                  borderColor: const Color(0xff8068EB),
                  duration: const Duration(seconds: 3),
                  animationDuration: const Duration(milliseconds: 700),
                ).show(widget.navigatorKey?.currentContext ?? context).then((_) {
                  setState(() {
                    displayed = false;
                  });
                });
              }
            },
          )
          .subscribe();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ?? const SizedBox.shrink();
  }
}
